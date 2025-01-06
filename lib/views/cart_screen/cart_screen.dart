import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../payment_screen/address_screen.dart';
import 'cart_controller.dart';
import 'cart_item_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: Obx(() {
          // Display a message if the cart is empty
          if (cartController.cartItems.isEmpty) {
            return const Center(
              child: Text(
                'Cart is Empty!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }

          // Display the list of cart items
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartController.cartItems[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(item.title),
                      subtitle: Text("₹ ${item.price}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              if (item.quantity > 1) {
                                cartController.addItem(
                                  CartItem(
                                      id: item.id,
                                      title: item.title,
                                      price: item.price,
                                      quantity: -1),
                                );
                              } else {
                                cartController.removeItem(item);
                              }
                            },
                          ),
                          Text("${item.quantity}"),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () {
                              cartController.addItem(
                                CartItem(
                                    id: item.id,
                                    title: item.title,
                                    price: item.price,
                                    quantity: 1),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              cartController.removeItem(item);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Display total price
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Obx(() => Text(
                      '₹ ${cartController.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),

              // Bottom section with 'Continue Shopping' and 'Proceed to Payment' buttons
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        Get.back(); // Navigate back to the previous screen (shopping)
                      },
                      child: const Text(
                        'Continue Shopping',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                      onPressed: () {
                        // Navigate to the address screen (Assuming you have an AddressScreen)
                        Get.to(() => const AddressScreen());
                      },
                      child: const Text(
                        'Proceed to Payment',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
