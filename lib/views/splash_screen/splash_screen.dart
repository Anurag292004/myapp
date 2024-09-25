import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/views/auth_screen/login_screen.dart';
import 'package:flutter_app_2/views/home_screen/home.dart';
import 'package:flutter_app_2/widgets_common/applogo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate splash screen delay
    
    // Check Firebase initialization and user authentication status
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.offAll(() => const Home()); // Navigate to ProfileScreen if user is logged in
    } else {
      Get.offAll(() => const LoginScreen()); // Navigate to LoginScreen if no user is logged in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: redColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(icSplashBg, width: 300),
            ),
            20.heightBox,
            applogoWidget(),
            10.heightBox,
            appname.text.fontFamily(bold).size(22).white.make(),
            5.heightBox,
            appversion.text.white.make(),
            const Spacer(),
            credits.text.white.fontFamily(semibold).make(),
            30.heightBox,
          ],
        ),
      ),
    );
  }
}
