import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../cart_screen/cart_controller.dart';
import '../cart_screen/cart_item_model.dart'; // Adjust the import based on your project structure
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/widgets_common/our_button.dart';
import 'package:flutter_app_2/views/cart_screen/cart_screen.dart';

class ItemDetails extends StatelessWidget {
  final String? title;
  final double price;

  const ItemDetails({super.key, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());

    return Scaffold(
      appBar: AppBar(
        title: Text(title!, style: TextStyle(color: darkFontGrey, fontFamily: bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_outline)),
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
                    // Swiper section
                    VxSwiper.builder(
                      autoPlay: true,
                      height: 300,
                      aspectRatio: 16 / 9,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Image.asset(imgFc5, width: double.infinity, fit: BoxFit.cover);
                      },
                    ),
                    10.heightBox,
                    // Title and description
                    Text(title!, style: TextStyle(fontSize: 20, color: redColor, fontFamily: semibold)),
                    10.heightBox,
                    Text("\₹ $price", style: TextStyle(color: redColor, fontFamily: bold, fontSize: 18)),
                    10.heightBox,
                    // Description section
                    10.heightBox,
                    Text("Description", style: TextStyle(color: redColor, fontSize: 18, fontFamily: semibold)),
                    10.heightBox,
                    Text("This is a Dummy Item and Dummy Description here...", style: TextStyle(color: darkFontGrey, fontSize: 16, fontFamily: regular)),
                    20.heightBox,
                    // Similar products
                    Text(productsyomaylike, style: TextStyle(fontFamily: bold, fontSize: 18, color: redColor)),
                    20.heightBox,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          6,
                          (index) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(imgP1, width: 150, fit: BoxFit.cover),
                              10.heightBox,
                              Text("Laptop 4GB/64GB", style: TextStyle(fontFamily: semibold, color: darkFontGrey)),
                              10.heightBox,
                              Text("\₹ 600", style: TextStyle(color: redColor, fontFamily: bold, fontSize: 16)),
                            ],
                          ).box.gray400.margin(const EdgeInsets.symmetric(horizontal: 4)).roundedSM.padding(const EdgeInsets.all(8)).make(),
                        ),
                      ),
                    ),
                    10.heightBox,
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ourButton(
              color: redColor,
              onPress: () {
                // Add item to the cart
                cartController.addItem(CartItem(
                  id: DateTime.now().toString(), // Unique ID for the item
                  title: title!,
                  price: price,
                  quantity: 1,
                ));
                Get.snackbar('Added to Cart', '$title has been added to your cart.', snackPosition: SnackPosition.BOTTOM);
                Future.delayed(const Duration(seconds: 3), () {
                  Get.to(() => const CartScreen()); // Navigate to the Cart Screen
                });
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
