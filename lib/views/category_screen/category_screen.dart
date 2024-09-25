import 'package:get/get.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/consts/list.dart';
import 'package:flutter_app_2/views/category_screen/category_details.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.red,
    child: Scaffold(
      appBar: AppBar(
      title: category.text.fontFamily(bold).white.size(24).make(),
      ),

      body: Container(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8,crossAxisSpacing: 8,mainAxisExtent: 240), 
                  itemBuilder: (context,index) {
                  return Column (
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(categoryImages[index],height: 150,width: 200,fit: BoxFit.cover),
                            0.heightBox,
                            categoriesList[index].text.color(redColor).align(TextAlign.center).fontFamily(bold).make(),
                          ],
                        ).box.white.roundedSM.padding(const EdgeInsets.all(12)).make().onTap(() {
                          Get.to(() => CategoryDetails(title : categoriesList[index]));
                        });
                        }),
                ),
      ),


    );
  }
}