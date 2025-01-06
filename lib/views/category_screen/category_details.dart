import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/views/category_screen/item_details.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class CategoryDetails extends StatelessWidget {
  final String title; // Category name
  final String categoryId; // Category document ID

  const CategoryDetails({super.key, required this.title, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Scaffold(
        appBar: AppBar(
          title: title.text.fontFamily(bold).white.make(),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('categoryId', isEqualTo: categoryId) // Filter products by categoryId
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No products available for this category'));
            }

            var products = snapshot.data!.docs;

            return Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 280,
                ),
                itemBuilder: (context, index) {
                  var productData = products[index];

                  // Extract product details
                  String productId = productData.id; // Fetch the document ID (productId)
                  String productName = productData['name'] ?? 'Unnamed Product';
                  double productPrice = (productData['price'] ?? 0).toDouble();

                  // Retrieve the image URL(s) from the 'images' field
                  List<dynamic>? imageUrls = productData['images'];
                  String productImageUrl = '';

                  if (imageUrls != null && imageUrls.isNotEmpty) {
                    productImageUrl = imageUrls[0]; // Get the first image URL
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the product image if available, otherwise show a placeholder
                      productImageUrl.isNotEmpty
                          ? Image.network(
                        productImageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Center(child: Text('Image not available')),
                          );
                        },
                      )
                          : Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(child: Text('No Image')),
                      ),
                      10.heightBox,
                      productName.text.color(redColor).size(18).align(TextAlign.center).fontFamily(bold).make(),
                      10.heightBox,
                      '\₹${productPrice.toStringAsFixed(2)}'.text.color(redColor).align(TextAlign.center).fontFamily(bold).make(),
                    ],
                  )
                      .box
                      .white
                      .margin(const EdgeInsets.symmetric(horizontal: 4))
                      .rounded
                      .padding(const EdgeInsets.all(12))
                      .make()
                      .onTap(() {
                    // Navigate to the ItemDetails screen, passing product details and productId
                    Get.to(() => ItemDetails(
                      productId: productId, // Pass the product document ID
                      title: productName,
                      price: productPrice,
                      imageUrls: productData['images'] != null && (productData['images'] as List).isNotEmpty
                          ? List<String>.from(productData['images']) // Convert the list to List<String> if it exists and is not empty
                          : ['https://via.placeholder.com/150'], // Fallback placeholder image if no images are available
                      description: productData['description'] ?? 'No description available.',
                      category: productData['category'] ?? 'No category', // Pass the category if available
                    ));
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
