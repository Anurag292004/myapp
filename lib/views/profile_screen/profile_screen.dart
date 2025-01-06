import 'package:flutter_app_2/consts/consts.dart';
import 'package:flutter_app_2/views/auth_screen/login_screen.dart';
import 'package:flutter_app_2/views/order_screen/order_screen.dart';
import 'package:flutter_app_2/views/order_screen/favourite_screen.dart';
import 'package:flutter_app_2/widgets_common/bg_widget.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        return doc.data();
      } catch (e) {
        // Handle errors
        print(e);
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _fetchUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(child: Text('Error fetching user details.'));
              }

              final userData = snapshot.data!;
              final String userId = FirebaseAuth.instance.currentUser!.uid;  // Get the userId

              return Column(
                children: [
                  // Edit profile button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Icon(Icons.edit, color: whiteColor)
                          .onTap(() {
                        // Handle edit profile action
                      }),
                    ),
                  ),

                  // User details section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Image.asset(imgProfile3, width: 100, fit: BoxFit.cover).box.roundedFull.clip(Clip.antiAlias).make(),
                        10.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              "${userData['name'] ?? 'User Name'}".text.fontFamily(semibold).white.make(),
                              "${userData['email'] ?? 'user@example.com'}".text.white.make(),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: whiteColor),
                          ),
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.signOut();
                              Get.offAll(() => const LoginScreen());
                            } catch (e) {
                              // Handle sign out errors
                              print(e);
                            }
                          },
                          child: logout.text.fontFamily(semibold).white.make(),
                        ),
                      ],
                    ),
                  ),

                  // Button section
                  5.heightBox,
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: lightGolden),
                    onPressed: () {
                      // Use the current userId to navigate to the OrderScreen
                      Get.to(() => OrderScreen(userId: userId)); // Pass userId to OrderScreen
                    },
                    child: Text('Order History', style: TextStyle(color: redColor)),
                  ),

                  5.heightBox,
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: lightGolden),
                    onPressed: () {
                      // Use the current userId to navigate to the OrderScreen
                      Get.to(() => const FavoriteScreen()); // Pass userId to OrderScreen
                    },
                    child: Text('Favourite ', style: TextStyle(color: redColor)),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
