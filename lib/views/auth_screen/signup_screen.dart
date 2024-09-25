import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_app_2/views/home_screen/home.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/widgets_common/applogo_widget.dart';
import 'package:flutter_app_2/widgets_common/bg_widget.dart';
import 'package:flutter_app_2/widgets_common/custom_textfield.dart';
import 'package:flutter_app_2/widgets_common/our_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  
  // Text controllers
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordRetypeController = TextEditingController();

  Future<void> _signup() async {
    if (passwordController.text != passwordRetypeController.text) {
      VxToast.show(context, msg: 'Passwords do not match');
      return;
    }

    try {
      // Create a new user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Store additional user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      VxToast.show(context, msg: loginSucessfully);
      Get.offAll(() => const Home()); // Navigate to home page on successful signup
    } catch (e) {
      VxToast.show(context, msg: e.toString()); // Show error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              (context.screenHeight * 0.15).heightBox,
              applogoWidget(),
              10.heightBox,
              "Sign up to $appname".text.fontFamily(bold).white.size(18).make(),
              15.heightBox,
              Column(
                children: [
                  customTextField(
                    title: name,
                    hint: nameHint,
                    controller: nameController,
                    isPass: false,
                  ),
                  customTextField(
                    title: email,
                    hint: emailHint,
                    controller: emailController,
                    isPass: false,
                  ),
                  customTextField(
                    title: password,
                    hint: passwordHint,
                    controller: passwordController,
                    isPass: true,
                  ),
                  customTextField(
                    title: confirmPassword,
                    hint: passwordHint,
                    controller: passwordRetypeController,
                    isPass: true,
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                  ),
                  5.heightBox,
                  ourButton(
                    color: redColor,
                    title: signup,
                    textColor: whiteColor,
                    onPress: _signup,
                  ).box.width(context.screenWidth - 50).make(),
                  30.heightBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      alreadyHaveAccount.text.color(fontGrey).make(),
                      login.text.color(redColor).make().onTap(() {
                        Get.back();
                      }),
                    ],
                  ),
                ],
              ).box.white.rounded.padding(const EdgeInsets.all(16)).width(context.screenWidth - 70).shadowSm.make(),
            ],
          ),
        ),
      ),
    );
  }
}
