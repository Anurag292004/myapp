import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/item.dart';
import 'cart_controller.dart';

class HomeScreen extends StatelessWidget {
  final List<Item> items = [
    Item(id: '1', name: 'Item 1', price: 10.0),
    Item(id: '2', name: 'Item 2', price: 20.0),
    Item(id: '3', name: 'Item 3', price: 30.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('\$${item.price}'),
            trailing: ElevatedButton(
              onPressed: () => Get.toNamed('/item/${item.id}'),
              child: Text('View'),
            ),
          );
        },
      ),
    );
  }
}

