import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'cart_item_model.dart';

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

  // Add method to calculate total price
  double get totalAmount {
    return cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }


  Future<void> addItem(CartItem newItem) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if the item already exists in the cart based on its product ID
      final existingItem = cartItems.firstWhereOrNull((item) => item.id == newItem.id);

      if (existingItem != null) {
        // If the item exists, increment its quantity
        existingItem.quantity += newItem.quantity;
      } else {
        // If the item doesn't exist, add it to the cart
        cartItems.add(newItem);
      }

      // Update Firestore with the modified cart items
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'cart': cartItems.map((item) => item.toJson()).toList(),
      });

      cartItems.refresh(); // Refresh the observable list
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
