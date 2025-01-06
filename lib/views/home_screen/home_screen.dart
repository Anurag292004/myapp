import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/views/home_screen/components/featured_button.dart';
import 'package:flutter_app_2/widgets_common/home_buttom.dart';
import 'package:get/get.dart';

import '../category_screen/item_details.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Fetch products from the same category from Firestore
    Future<List<Map<String, dynamic>>> fetchSimilarProducts() async {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .limit(6) // Limit to 6 similar products
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id; // Include the document ID as 'productId'
        return data;
      }).toList();
    }

    void toggleFavorite(String productId) async {
      final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
      final productDoc = await productRef.get();
      if (productDoc.exists) {
        bool currentStatus = productDoc['isFavorite'] ?? false;
        await productRef.update({'isFavorite': !currentStatus});
      }
    }


    return Container(
      padding: const EdgeInsets.all(12),
      color: lightGrey,
      width: context.screenWidth,
      height: context.screenHeight,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 60,
              color: lightGrey,
              child: TextFormField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: whiteColor,
                  hintText: searchanything,
                  hintStyle: TextStyle(color: textfieldGrey),
                ),
              ),
            ),

            10.heightBox,
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                                
                //swiper
                VxSwiper.builder(
                  aspectRatio: 16/9,
                  autoPlay: true,
                  height: 150,
                  enlargeCenterPage: true,
                  itemCount: slidersList.length, itemBuilder: (context,index){
                  return Image.asset(
                     slidersList[index],
                     fit: BoxFit.fill, 
                    ).box.rounded.clip(Clip.antiAlias).margin(const EdgeInsets.symmetric(horizontal: 8)).make();
                }),
                
                15.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(2, (index) => homeButtons(
                    height:context.screenHeight *0.15,
                    width: context.screenWidth / 2.5,
                    icon:index == 0 ? icTodaysDeal : icFlashDeal,
                    title: index == 0 ? todayDeal :flashsale,
                  )),
                ),
                
                15.heightBox,
                VxSwiper.builder(
                  aspectRatio: 16/9,
                  autoPlay: true,
                  height: 150,
                  enlargeCenterPage: true,
                  itemCount: slidersList.length, itemBuilder: (context,index){
                  return Image.asset(
                     secondSlidersList[index],
                     fit: BoxFit.fill, 
                    ).box.rounded.clip(Clip.antiAlias).margin(const EdgeInsets.symmetric(horizontal: 8)).make();
                }),
                
                15.heightBox,
                Row(
                  children: List.generate(3, (index) => homeButtons(
                    height:context.screenHeight *0.15,
                    width: context.screenWidth / 3.2,
                    icon:index == 0 ? icTopCategories : index == 1 ? icBrands : icTopSeller,
                    title:index == 0 ? topCategories : index == 1 ? brand : topSellers,
                  )),
                ),
                
                10.heightBox,
                Align(
                  alignment: Alignment.centerLeft,
                  child: featuredCategories.text.color(darkFontGrey).size(20).fontFamily(semibold).make()),
                
                10.heightBox,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(3, (index) => Column(
                      children: [
                        featuredButton(icon: featuredImages1[index], title: freaturedTitles1[index]),
                        10.heightBox,
                        featuredButton(icon: featuredImages2[index], title: freaturedTitles2[index]),
                      ],
                    ),
                    ).toList(),
                  ),
                ),
                
                10.heightBox,
                Container (
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: const BoxDecoration (color: redColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      featuredProduct.text.white.fontFamily(bold).size (18).make(),
                      10.heightBox,
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
                                    bool isFavorite = product['isFavorite'] ?? false; // Check favorite status
                                    return GestureDetector(
                                      onTap: () {
                                        // Navigate to ItemDetails screen with product details
                                        Get.to(() => ItemDetails(
                                          productId: product['id'] ?? '', // Pass product ID
                                          title: product['name'] ?? 'Unnamed Product',
                                          imageUrls: List<String>.from(product['images'] ?? []),
                                          description: product['description'] ?? 'No description available.',
                                          category: product['category'] ?? 'Uncategorized',
                                          price: product['price'] ?? 0.0, // Product price
                                        ));
                                      },
                                        child: Stack(
                                        children: [
                                          Column(
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
                                      ).box.blue50.margin(const EdgeInsets.symmetric(horizontal: 4)).roundedSM.padding(const EdgeInsets.all(8)).make(),

                                      // Favorite Icon
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: GestureDetector(
                                          onTap: () {
                                            // Update favorite status in Firestore or local state
                                            toggleFavorite(product['id'] ?? '');
                                          },
                                          child: Icon(
                                            isFavorite ? Icons.favorite : Icons.favorite_border,
                                            color: isFavorite ? Colors.red : Colors.grey,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      ],
                                        ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
              
              
              10.heightBox,
                VxSwiper.builder(
                  aspectRatio: 16/9,
                  autoPlay: true,
                  height: 150,
                  enlargeCenterPage: true,
                  itemCount: slidersList.length, itemBuilder: (context,index){
                  return Image.asset(
                     secondSlidersList[index],
                     fit: BoxFit.fill, 
                    ).box.rounded.clip(Clip.antiAlias).margin(const EdgeInsets.symmetric(horizontal: 8)).make();
                }),
                
              10.heightBox,
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchSimilarProducts(), // Fetch products from Firestore
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Failed to load products.'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No products available.'));
                        } else {
                          final products = snapshot.data!;
                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: products.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 320,
                            ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              bool isFavorite = product['isFavorite'] ?? false;

                              return GestureDetector(
                                onTap: () {
                                  Get.to(() => ItemDetails(
                                    productId: product['productId'] ?? '',
                                    title: product['name'] ?? 'Unnamed Product',
                                    price: product['price']?.toDouble() ?? 0.0,
                                    imageUrls: List<String>.from(product['images'] ?? []),
                                    description: product['description'] ?? 'No description available.',
                                    category: product['category'] ?? 'No category',
                                  ));
                                },
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          product['images'] != null && product['images'].isNotEmpty
                                              ? product['images'][0]
                                              : 'https://via.placeholder.com/200', // Placeholder image
                                          height: 200,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        const Spacer(),
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
                                    ).box.white.margin(const EdgeInsets.symmetric(horizontal: 4)).rounded.padding(const EdgeInsets.all(12)).make(),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () {
                                          toggleFavorite(product['productId'] ?? '');
                                        },
                                        child: Icon(
                                          isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: isFavorite ? Colors.red : Colors.grey,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                        }
                      },
                    ),


                  ],
          ),
        ),
      ),
          ],
    ),
    ),
    );
  }
}