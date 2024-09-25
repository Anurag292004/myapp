import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/views/auth_screen/signup_screen.dart';
import 'package:flutter_app_2/views/home_screen/home.dart';
import 'package:flutter_app_2/widgets_common/applogo_widget.dart';
import 'package:flutter_app_2/widgets_common/bg_widget.dart';
import 'package:flutter_app_2/widgets_common/custom_textfield.dart';
import 'package:flutter_app_2/widgets_common/our_button.dart';

import 'forget_password_screen.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _auth = FirebaseAuth.instance;

    Future<void> _login() async {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Get.offAll(() => const Home()); // Navigate to home page on successful login
      } catch (e) {
        Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM); // Show error message
      }
    }

    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              (context.screenHeight * 0.15).heightBox,
              applogoWidget(),
              10.heightBox,
              "Log in to $appname".text.fontFamily(bold).white.size(18).make(),
              15.heightBox,
              Column(
                children: [
                  customTextField(
                    title: email,
                    hint: emailHint,
                    isPass: false,
                    controller: _emailController,
                  ),
                  customTextField(
                    title: password,
                    hint: passwordHint,
                    isPass: true,
                    controller: _passwordController,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.to(() => const ForgotPasswordScreen()); // Navigate to forgot password screen
                      },
                      child: forgetPassword.text.make(),
                    ),
                  ),
                  5.heightBox,
                  ourButton(
                    color: redColor,
                    title: login,
                    textColor: whiteColor,
                    onPress: _login,
                  ).box.width(context.screenWidth - 50).make(),
                  15.heightBox,
                  createNewAccount.text.color(fontGrey).size(18).make(),
                  15.heightBox,
                  ourButton(
                    color: lightGolden,
                    title: signup,
                    textColor: redColor,
                    onPress: () {
                      Get.to(() => const SignupScreen());
                    },
                  ).box.width(context.screenWidth - 50).make(),
                ],
              ).box.white.rounded.padding(const EdgeInsets.all(16)).width(context.screenWidth - 70).shadowSm.make(),
            ],
          ),
        ),
      ),
    );
  }
}
