import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cart_controller.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(child: Text('Cart is Empty!'));
        }
        return ListView.builder(
          itemCount: cartController.cartItems.length,
          itemBuilder: (context, index) {
            final cartItem = cartController.cartItems[index];
            return ListTile(
              title: Text(cartItem.item.name),
              subtitle: Text('\$${cartItem.item.price}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => cartController.decrementQuantity(cartItem.item),
                  ),
                  Text('${cartItem.quantity}'),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => cartController.incrementQuantity(cartItem.item),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
