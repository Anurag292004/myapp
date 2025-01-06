import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/views/category_screen/category_details.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Scaffold(
        appBar: AppBar(
          title: 'Categories'.text.fontFamily(bold).white.size(24).make(),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('categories')
              .snapshots(), // Fetch categories collection from Firebase
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No categories available'));
            }

            var categories = snapshot.data!.docs;

            return Container(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 240,
                ),
                itemBuilder: (context, index) {
                  var categoryData = categories[index];
                  String categoryId = categoryData.id; // Get the document ID
                  String categoryName = categoryData['name'];
                  String categoryImage = categoryData['imageUrl'] ?? '';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      categoryImage.isNotEmpty
                          ? Image.network(
                        categoryImage,
                        height: 150,
                        width: 200,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        height: 150,
                        width: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('No Image'),
                        ),
                      ),
                      10.heightBox,
                      categoryName.text.color(redColor).align(TextAlign.center).fontFamily(bold).make(),
                    ],
                  )
                      .box
                      .white
                      .roundedSM
                      .padding(const EdgeInsets.all(12))
                      .make()
                      .onTap(() {
                    // Navigate to Category Details Screen with the category name and ID
                    Get.to(() => CategoryDetails(
                      title: categoryName,
                      categoryId: categoryId,
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
