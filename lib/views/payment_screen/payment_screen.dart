import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../cart_screen/cart_controller.dart';
import '../home_screen/home.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final CartController cartController = Get.find<CartController>();

  String _selectedPaymentMethod = ''; // Tracks the selected payment method
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();

  /// Format the card number in `1234-5678-9012-3456` format
  String _formatCardNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters
    final truncated = cleaned.length > 16 ? cleaned.substring(0, 16) : cleaned; // Limit to 16 digits
    return truncated.replaceAllMapped(RegExp(r'.{1,4}'), (match) => '${match.group(0)}-').replaceAll(RegExp(r'-$'), '');
  }

  /// Show a date picker for selecting the expiry date (Day/Month/Year)
  void _pickExpiryDate(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // Prevent selecting past dates
      lastDate: DateTime(now.year + 10, 12, 31), // Limit to 10 years in the future
    );

    if (selectedDate != null) {
      final formattedDate = DateFormat('MM/yy').format(selectedDate); // Format as MM/YY
      setState(() {
        _expiryDateController.text = formattedDate;
      });
    }
  }


  Future<void> _storeOrder() async {
    final cartItems = cartController.cartItems;
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar('Error', 'No user is logged in.');
      return;
    }

    final String userId = user.uid;

    final orderData = {
      'userId': userId,
      'items': cartItems.map((item) => item.toJson()).toList(),
      'totalQuantity': cartItems.fold(0, (sum, item) => sum + item.quantity),
      'totalAmount': cartController.totalAmount,
      'orderDate': FieldValue.serverTimestamp(),
      'paymentMethod': _selectedPaymentMethod,
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);
  }

  void _confirmPayment() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      Get.snackbar('Error', 'Please enter valid payment details.', backgroundColor: Colors.redAccent);
      return;
    }

    // Show confirmation dialog
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Payment'),
        content: const Text('Are you sure you want to proceed with the payment?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirm == true) {
      // Proceed with payment
      try {
        await _storeOrder();
        await cartController.clearCart();

        Get.snackbar('Success', 'Payment and order processing successful', backgroundColor: Colors.greenAccent);
        Get.offAll(() => const Home());
      } catch (e) {
        Get.snackbar('Error', 'Failed to process the order. Please try again.', backgroundColor: Colors.redAccent);
      }
    }
  }

  Razorpay _razorpay = Razorpay();

  @override
  Widget build(BuildContext context) {

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment method selection
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkFontGrey),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedPaymentMethod.isEmpty ? null : _selectedPaymentMethod,
              hint: const Text('Select Payment Method'),
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              items: [
                'Credit Card',
                'Debit Card',
                'UPI',
                'Cash on Delivery',
              ]
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Payment details form
            if (_selectedPaymentMethod == 'Credit Card' || _selectedPaymentMethod == 'Debit Card')
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Card Number', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Enter your card number'),
                      onChanged: (value) {
                        _cardNumberController.text = _formatCardNumber(value);
                        _cardNumberController.selection = TextSelection.collapsed(offset: _cardNumberController.text.length);
                      },
                      validator: (value) => value!.isEmpty || value.length != 19 ? 'Invalid card number' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Expiry Date (MM/YY)', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextFormField(
                                controller: _expiryDateController,
                                readOnly: true,
                                onTap: () => _pickExpiryDate(context),
                                decoration: const InputDecoration(hintText: 'MM/YY'),
                                validator: (value) => value!.isEmpty ? 'Invalid expiry date' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CVV', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextFormField(
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                maxLength: 3, // Limit input to 3 characters
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                                  LengthLimitingTextInputFormatter(3),   // Ensure input is no longer than 3 digits
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'CVV',
                                  counterText: '', // Hide the counter below the field
                                ),
                                validator: (value) => value!.isEmpty || value.length != 3 ? 'Invalid CVV' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            if (_selectedPaymentMethod == 'UPI')
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('UPI ID', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _upiIdController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Enter your UPI ID'),
                      validator: (value) => value!.isEmpty || !value.contains('@') ? 'Invalid UPI ID' : null,
                    ),
                  ],
                ),
              ),
            if (_selectedPaymentMethod == 'Cash on Delivery')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Cash on Delivery selected. No further details required.', style: TextStyle(color: darkFontGrey)),
              ),

            const Spacer(),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: redColor),
                onPressed: () async {
                  var options = {
                    'key': 'rzp_test_YghCO1so2pwPnx',
                    'amount': 1000,
                    'currency':'Rupees',
                    'name': 'Acme Corp.',
                    'description': 'Fine T-Shirt',
                    'prefill': {
                      'contact': '8888888888',
                      'email': 'test@razorpay.com'
                    }
                  };

                  _razorpay.open(options);
                },

                child: const Text('Pay Now', style: TextStyle(color: whiteColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    _storeOrder();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear(); // Removes all listeners
  }
}
