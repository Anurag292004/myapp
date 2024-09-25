import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_2/views/auth_screen/login_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/widgets_common/custom_textfield.dart';
import 'package:flutter_app_2/widgets_common/our_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController();
    final _auth = FirebaseAuth.instance;

    Future<void> _resetPassword() async {
      try {
        await _auth.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        Get.snackbar('Success', 'Password reset email sent.', snackPosition: SnackPosition.TOP);
        // Automatically navigate back to the login screen
        Future.delayed(const Duration(seconds: 5), () {
          Get.to(() => const LoginScreen()); // Navigate back to the previous screen
        });
      } catch (e) {
        Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
      }
    }

    return Scaffold(
      backgroundColor: golden,
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Enter your email address to receive a password reset link".text.size(16).make(),
            20.heightBox,
            customTextField(
              title: email,
              hint: emailHint,
              isPass: false,
              controller: _emailController,
            ),
            20.heightBox,
            ourButton(
              color: redColor,
              title: 'Send Reset Email',
              textColor: whiteColor,
              onPress: _resetPassword,
            ).box.width(context.screenWidth - 50).make(),
          ],
        ),
      ),
    );
  }
}
