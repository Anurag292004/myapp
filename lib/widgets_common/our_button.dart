import 'package:flutter_app_2/consts/consts.dart';

Widget ourButton({onPress, color, textColor,String? title}){
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.all(12)
    ),
    onPressed: onPress,
    child: title!.text.color(textColor).size(18).fontFamily(bold).make(),
  );
}