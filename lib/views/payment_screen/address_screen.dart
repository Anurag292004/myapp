import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/views/payment_screen/payment_screen.dart';

import 'add_address_screen.dart'; // Adjust the import based on your project structure

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _ShowAddressScreenState();
}

class _ShowAddressScreenState extends State<AddressScreen> {
  final Rx<Map<String, String?>> _address = Rx<Map<String, String?>>({});
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _address.value = {
            'address': data['address'],
            'city': data['city'],
            'state': data['state'],
            'zipCode': data['zipCode'],
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'address': FieldValue.delete(),
        'city': FieldValue.delete(),
        'state': FieldValue.delete(),
        'zipCode': FieldValue.delete(),
      });
      setState(() {
        _address.value = {};
      });
      Get.snackbar('Success', 'Address deleted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(title: Text('Address')),
      body: Center(
        child: _isLoading
          ? CircularProgressIndicator() // Loader while fetching data
          : Obx(() {
              if (_address.value.isEmpty || _address.value.values.any((value) => value == null || value!.isEmpty)) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No address found', style: TextStyle(fontSize: 18, color: darkFontGrey)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: redColor),
                      onPressed: () {
                        Get.to(() => const AddAddressScreen());
                      },
                      child: Text('Add Address', style: TextStyle(color: whiteColor)),
                    ),
                  ],
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Address Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkFontGrey)),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteAddress();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('Address: ${_address.value['address'] ?? ''}', style: TextStyle(fontSize: 16, color: darkFontGrey)),
                    SizedBox(height: 8),
                    Text('City: ${_address.value['city'] ?? ''}', style: TextStyle(fontSize: 16, color: darkFontGrey)),
                    SizedBox(height: 8),
                    Text('State: ${_address.value['state'] ?? ''}', style: TextStyle(fontSize: 16, color: darkFontGrey)),
                    SizedBox(height: 8),
                    Text('Zip Code: ${_address.value['zipCode'] ?? ''}', style: TextStyle(fontSize: 16, color: darkFontGrey)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: redColor),
                      onPressed: () {
                        Get.to(() => const AddAddressScreen()); // Navigate to address screen to update
                      },
                      child: Text('Update Address', style: TextStyle(color: whiteColor)),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: lightGolden),
                      onPressed: () {
                        Get.to(() => const PaymentScreen()); // Navigate to payment screen
                      },
                      child: Text('Proceed to Payment', style: TextStyle(color: redColor)),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
