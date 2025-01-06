import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'order_detail.dart';

class OrderScreen extends StatelessWidget {
  final String userId;

  const OrderScreen({Key? key, required this.userId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      // Extract orders and sort them by `orderDate`
      List<Map<String, dynamic>> orders = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      orders.sort((a, b) {
        DateTime dateA = (a['orderDate'] as Timestamp).toDate();
        DateTime dateB = (b['orderDate'] as Timestamp).toDate();
        return dateB.compareTo(dateA); // Ascending order
      });

      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              var orderDate = (order['orderDate'] as Timestamp).toDate();
              var formattedDate =
              DateFormat('dd MMMM yyyy, h:mm a').format(orderDate);

              return Card(
                child: ListTile(
                  title: Text('Order Date: $formattedDate'),
                  subtitle: Text('Total Amount: ₹${order['totalAmount']}'),
                  trailing: Text('Items: ${order['totalQuantity']}'),
                  onTap: () {
                    Get.to(() => OrderDetailScreen(orderDetails: order));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

