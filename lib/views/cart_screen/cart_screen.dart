import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../payment_screen/address_screen.dart';
import 'cart_controller.dart';
import 'cart_item_model.dart'; // Adjust the import based on your project structure

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Cart')),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Text('Cart is Empty!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartController.cartItems[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(item.title),
                    subtitle: Text("\₹ ${item.price}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.red),
                          onPressed: () {
                            if (item.quantity > 1) {
                              cartController.addItem(CartItem(id: item.id, title: item.title, price: item.price, quantity: -1));
                            } else {
                              cartController.removeItem(item);
                            }
                          },
                        ),
                        Text("${item.quantity}"),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            cartController.addItem(CartItem(id: item.id, title: item.title, price: item.price, quantity: 1));
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
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
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      Get.back(); // Navigate back to shopping
                    },
                    child: Text('Continue Shopping', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                    onPressed: () {
                      Get.to(() => AddressScreen()); // Navigate to address screen
                    },
                    child: Text('Proceed to Payment', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
