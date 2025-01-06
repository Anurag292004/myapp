import 'package:flutter_app_2/consts/list.dart';
import 'package:get/get.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/views/category_screen/item_details.dart';
import 'package:flutter_app_2/widgets_common/bg_widget.dart';

class CategoryDetails extends StatelessWidget {
  final String? title;
  const CategoryDetails({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        appBar: AppBar(
          title: title!.text.fontFamily(bold).white.make(),
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    6,
                    (index) => "Baby Clothing"
                        .text
                        .size(12)
                        .fontFamily(semibold)
                        .color(darkFontGrey)
                        .makeCentered()
                        .box
                        .white
                        .rounded
                        .size(120, 60)
                        .margin(const EdgeInsets.symmetric(horizontal: 4))
                        .make(),
                  ),
                ),
              ),
              20.heightBox,
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: productList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 280,
                  ),
                  itemBuilder: (context, index) {
                    final product = productList[index];
                    final price = productPrice[index];
                    final image = categoryImages[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(image, height: 150, width: 200, fit: BoxFit.cover),
                        0.heightBox,
                        product.text.color(redColor).align(TextAlign.center).fontFamily(bold).make(),
                        10.heightBox,
                        price.text.color(redColor).align(TextAlign.center).fontFamily(bold).make(),
                      ],
                    )
                        .box
                        .white
                        .margin(const EdgeInsets.symmetric(horizontal: 4))
                        .rounded
                        .padding(const EdgeInsets.all(12))
                        .make()
                        .onTap(() {
                          Get.to(() => ItemDetails(
                            title: product,
                            price: double.parse(price.replaceAll(RegExp(r'[^\d.]'), '')),
                          ));
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
