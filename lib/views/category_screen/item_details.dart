import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import '../cart_screen/cart_controller.dart';
import '../cart_screen/cart_item_model.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/widgets_common/our_button.dart';
import 'package:flutter_app_2/views/cart_screen/cart_screen.dart';


class ItemDetails extends StatefulWidget {
  final String? productId; // Product ID
  final String? title;
  final double price;
  final List<String> imageUrls; // List of image URLs
  final String description;
  final String category; // Category of the product

  const ItemDetails({
    super.key,
    required this.productId, // Add productId as a required parameter
    required this.title,
    required this.price,
    required this.imageUrls,
    required this.description,
    required this.category, // Add category as a required parameter
  });

  @override
  _ItemDetailsState createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  bool isFavorite = false; // Tracks if the item is marked as favorite
  static final List<Map<String, dynamic>> favorites = []; // Stores favorite products

  @override
  void initState() {
    super.initState();
    print("Product ID: ${widget.productId}"); // Debug productId
    _checkFavoriteStatus();
  }


  // Method to check if the product is already marked as favorite
  Future<void> _checkFavoriteStatus() async {
    if (widget.productId == null || widget.productId!.isEmpty) {
      print("Error: productId is null or empty");
      return;
    }

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (doc.exists && doc.data() != null) {
        bool favoriteStatus = (doc.data() as Map<String, dynamic>)['isFavorite'] ?? false;
        setState(() {
          isFavorite = favoriteStatus;
        });
      } else {
        print("Product document does not exist.");
      }
    } catch (e) {
      print("Error fetching favorite status: $e");
      Get.snackbar(
        'Error',
        'Failed to check favorite status.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
    }
  }


  void toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      if (isFavorite) {
        // Mark the product as a favorite in Firestore
        await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
          'isFavorite': true,
        });
      } else {
        // Unmark the product as a favorite in Firestore
        await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
          'isFavorite': false,
        });
      }
    } catch (e) {
      print("Error updating favorite status: $e");
      Get.snackbar('Error', 'Could not update favorite status.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());

    // Fetch products from the same category from Firestore
    Future<List<Map<String, dynamic>>> fetchSimilarProducts() async {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: widget.category)
          .limit(6) // Limit to 6 similar products
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!, style: TextStyle(color: darkFontGrey, fontFamily: bold)),
        actions: [
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: isFavorite ? redColor : darkFontGrey,
            ).box.padding(EdgeInsets.all(10)).make(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Swiper section with multiple images
                    VxSwiper.builder(
                      autoPlay: true,
                      height: 300,
                      aspectRatio: 16 / 9,
                      itemCount: widget.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.imageUrls[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(child: Text('Image not available')),
                            );
                          },
                        );
                      },
                    ),
                    10.heightBox,
                    // Title and price
                    Text(widget.title!, style: const TextStyle(fontSize: 20, color: redColor, fontFamily: semibold)),
                    10.heightBox,
                    Text("\₹ ${widget.price.toStringAsFixed(2)}", style: const TextStyle(color: redColor, fontFamily: bold, fontSize: 18)),
                    10.heightBox,
                    // Description section
                    Text("Description", style: const TextStyle(color: redColor, fontSize: 18, fontFamily: semibold)),
                    10.heightBox,
                    Text(
                      widget.description.isNotEmpty ? widget.description : "No description available.",
                      style: const TextStyle(color: darkFontGrey, fontSize: 16, fontFamily: regular),
                    ),
                    20.heightBox,
                    // Similar products section
                    Text(productsyomaylike, style: const TextStyle(fontFamily: bold, fontSize: 18, color: redColor)),
                    20.heightBox,
                    // Display similar products in a horizontal list
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchSimilarProducts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Failed to load similar products.'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No similar products found.'));
                        } else {
                          final products = snapshot.data!;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                products.length,
                                    (index) {
                                  final product = products[index];
                                  return GestureDetector(
                                    onTap: () {
                                      // Navigate to product details when a product is tapped
                                      Get.to(() => ItemDetails(
                                        productId: product['productid'] ?? 'No Id',
                                        title: product['name'] ?? 'No name',
                                        price: product['price']?.toDouble() ?? 0.0,
                                        imageUrls: List<String>.from(product['images'] ?? []),
                                        description: product['description'] ?? 'No description available.',
                                        category: product['category'] ?? 'No category',
                                      ));
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          product['images'] != null && product['images'].isNotEmpty
                                              ? product['images'][0] // Display first image if available
                                              : 'https://via.placeholder.com/150',
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                        10.heightBox,
                                        Text(
                                          product['name'] ?? 'Unnamed Product',
                                          style: const TextStyle(fontFamily: semibold, color: darkFontGrey),
                                        ),
                                        10.heightBox,
                                        Text(
                                          "\₹ ${product['price']?.toStringAsFixed(2) ?? '0.0'}",
                                          style: const TextStyle(color: redColor, fontFamily: bold, fontSize: 16),
                                        ),
                                      ],
                                    ).box.gray400.margin(const EdgeInsets.symmetric(horizontal: 4)).roundedSM.padding(const EdgeInsets.all(8)).make(),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    10.heightBox,
                  ],
                ),
              ),
            ),
          ),
          // Add to Cart button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ourButton(
              color: redColor,
              onPress: () {
                // Check if productId is available and add it to the cart
                if (widget.productId != null) {
                  cartController.addItem(CartItem(
                    id: widget.productId!, // Pass the correct product ID
                    title: widget.title!,
                    price: widget.price,
                    quantity: 1,
                  ));

                  Get.snackbar('Added to Cart', '${widget.title} has been added to your cart.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.greenAccent);

                  Future.delayed(const Duration(milliseconds: 1500), () {
                    Get.to(() => const CartScreen()); // Navigate to the Cart Screen
                  });
                } else {
                  Get.snackbar('Error', 'Product ID not available.', snackPosition: SnackPosition.BOTTOM);
                }
              },
              textColor: whiteColor,
              title: "Add to Cart",
            ),
          ),
        ],
      ),
    ).box.color(whiteColor).make();
  }
}
