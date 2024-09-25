import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'cart_item_model.dart'; // Adjust the import based on your project structure

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs; // Observable list of cart items

  @override
  void onInit() {
    super.onInit();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final items = (data?['cart'] as List<dynamic>?)
            ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList() ?? [];
        cartItems.value = items;
      }
    }
  }

  Future<void> addItem(CartItem newItem) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final existingItem = cartItems.firstWhereOrNull((item) => item.id == newItem.id);
      if (existingItem != null) {
        existingItem.quantity += newItem.quantity;
        if (existingItem.quantity <= 0) {
          cartItems.remove(existingItem);
        }
        cartItems.refresh(); // Refresh the observable list
      } else {
        cartItems.add(newItem);
      }
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'cart': cartItems.map((item) => item.toJson()).toList(),
      });
    }
  }

  Future<void> removeItem(CartItem item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      cartItems.remove(item);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'cart': cartItems.map((item) => item.toJson()).toList(),
      });
    }
  }

  Future<void> clearCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      cartItems.clear();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'cart': [],
      });
    }
  }
}
