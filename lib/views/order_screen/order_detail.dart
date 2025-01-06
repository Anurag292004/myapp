import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../category_screen/item_details.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderDetails;

  const OrderDetailScreen({super.key, required this.orderDetails});

  Future<Map<String, dynamic>?> _fetchProductDetails(String productId) async {
    try {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productDoc.exists) {
        return productDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint("Error fetching product details: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var orderDate = (orderDetails['orderDate'] as Timestamp).toDate();
    var formattedDate = DateFormat('dd MMMM yyyy, h:mm a').format(orderDate);
    var items = orderDetails['items'] as List<dynamic>;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Date: $formattedDate',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Amount: ₹${orderDetails['totalAmount']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Items: ${orderDetails['totalQuantity']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Payment Method: ${orderDetails['paymentMethod'] ?? 'Not specified'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return FutureBuilder<Map<String, dynamic>?>(
                    future: _fetchProductDetails(item['id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError || snapshot.data == null) {
                        return Card(
                          elevation: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text(item['title']),
                              Text(
                                '₹${item['price']} | Qty: ${item['quantity']}',
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      var productDetails = snapshot.data!;
                      var images = productDetails['images'] as List<dynamic>?;
                      var isFavorite = productDetails['isFavorite'] ?? false;

                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ItemDetails(
                            productId: productDetails['productid'],
                            title: productDetails['name'] ?? 'Unnamed',
                            price: productDetails['price']?.toDouble() ?? 0.0,
                            imageUrls:
                            List<String>.from(productDetails['images'] ?? []),
                            description: productDetails['description'] ?? '',
                            category: productDetails['category'] ?? '',
                          ));
                        },
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: images != null && images.isNotEmpty
                                      ? Image.network(
                                    images.first,
                                    fit: BoxFit.cover,
                                  )
                                      : const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₹${item['price']} | Qty: ${item['quantity']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                                      color: isFavorite ? Colors.red : Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
