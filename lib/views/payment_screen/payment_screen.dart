import 'package:get/get.dart';
import 'package:flutter_app_2/consts/consts.dart';

import '../cart_screen/cart_controller.dart';
import '../home_screen/home.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(title: Text('Payment')),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: redColor),
          onPressed: () async {
            // Simulate payment processing
            await Future.delayed(Duration(seconds: 2));
            // Clear cart after payment
            await cartController.clearCart();
            Get.snackbar('Success', 'Payment successful and cart cleared');
            Get.offAll(() => const Home()); // Redirect to home screen or another appropriate screen
          },
          child: Text('Pay Now', style: TextStyle(color: whiteColor)),
        ),
      ),
    );
  }
}
