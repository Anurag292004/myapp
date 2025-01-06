import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'models/item.dart';
import 'models/cart_item.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
  }

  void addItem(Item item) {
    final existingCartItem = cartItems.firstWhereOrNull((ci) => ci.item.id == item.id);
    if (existingCartItem != null) {
      existingCartItem.quantity++;
    } else {
      cartItems.add(CartItem(item: item));
    }
    saveCartItems();
  }

  void incrementQuantity(Item item) {
    final cartItem = cartItems.firstWhereOrNull((ci) => ci.item.id == item.id);
    if (cartItem != null) {
      cartItem.quantity++;
      saveCartItems();
    }
  }

  void decrementQuantity(Item item) {
    final cartItem = cartItems.firstWhereOrNull((ci) => ci.item.id == item.id);
    if (cartItem != null && cartItem.quantity > 1) {
      cartItem.quantity--;
      saveCartItems();
    } else if (cartItem != null && cartItem.quantity == 1) {
      cartItems.remove(cartItem);
      saveCartItems();
    }
  }

  void saveCartItems() async {
    final userId = 'your_user_id'; // Replace with your actual user ID logic
    final cartData = cartItems.map((ci) => {
      'item': ci.item.id,
      'quantity': ci.quantity,
    }).toList();
    await _firestore.collection('users').doc(userId).collection('cart').doc('cart').set({'items': cartData});
  }

  void fetchCartItems() async {
    final userId = 'your_user_id'; // Replace with your actual user ID logic
    final cartDoc = await _firestore.collection('users').doc(userId).collection('cart').doc('cart').get();
    if (cartDoc.exists) {
      final data = cartDoc.data();
      final items = (data?['items'] as List).map((itemData) {
        final itemId = itemData['item'] as String;
        final quantity = itemData['quantity'] as int;
        return CartItem(item: Item(id: itemId, name: 'Item $itemId', price: double.parse(itemId) * 10.0), quantity: quantity);
      }).toList();
      cartItems.value = items;
    }
  }
}
