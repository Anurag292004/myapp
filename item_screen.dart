import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/item.dart';
import 'cart_controller.dart';

class ItemScreen extends StatelessWidget {
  final String itemId;

  ItemScreen({required this.itemId});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();

    // Example items list
    final item = Item(id: itemId, name: 'Item $itemId', price: double.parse(itemId) * 10.0);

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('\$${item.price}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                cartController.addItem(item);
                Get.snackbar('Added to Cart', '${item.name} added to cart!');
                // Navigate to the CartScreen
                Get.offNamed('/cart');
              },
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
