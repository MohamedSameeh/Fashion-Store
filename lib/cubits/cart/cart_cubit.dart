import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartLoading());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Load Cart Items
  Future<void> loadCartItems() async {
    emit(CartLoading());
    try {
      final userId = _auth.currentUser!.uid;
      final cartSnapshot = await _firestore
          .collection('cart')
          .where('userid', isEqualTo: userId)
          .get();

      if (cartSnapshot.docs.isEmpty) {
        emit(CartEmpty());
      } else {
        double totalAmount = 0;
        for (var doc in cartSnapshot.docs) {
          totalAmount += doc['proprice'] * doc['quantity'];
        }
        emit(
            CartLoaded(cartItems: cartSnapshot.docs, totalAmount: totalAmount));
      }
    } catch (e) {
      emit(CartError(message: 'Failed to load cart: ${e.toString()}'));
    }
  }

  // Update Quantity
  void updateQuantity(DocumentSnapshot doc, int quantityChange) async {
    int currentQuantity = doc['quantity'];
    int newQuantity = currentQuantity + quantityChange;

    if (newQuantity > 0) {
      try {
        await _firestore.collection('cart').doc(doc.id).update({
          'quantity': newQuantity,
        });
        loadCartItems();
      } catch (e) {
        emit(CartError(message: 'Failed to update quantity: ${e.toString()}'));
      }
    }
  }

  // Delete Item from Cart
  void deleteItem(DocumentSnapshot doc) async {
    try {
      await _firestore.collection('cart').doc(doc.id).delete();
      loadCartItems();
    } catch (e) {
      emit(CartError(message: 'Failed to delete item: ${e.toString()}'));
    }
  }

  // Handle Checkout
  Future<void> handleCheckout() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final cartSnapshot = await _firestore
            .collection('cart')
            .where('userid', isEqualTo: user.uid)
            .get();

        if (cartSnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> orderItems = cartSnapshot.docs.map((doc) {
            return {
              'proname': doc['proname'],
              'proprice': doc['proprice'],
              'quantity': doc['quantity'],
              'proimage': doc['proimage'],
              'procolor': doc['procolor'],
              'prosize': doc['prosize'],
            };
          }).toList();

          double totalAmount = 0;
          cartSnapshot.docs.forEach((doc) {
            totalAmount += doc['proprice'] * doc['quantity'];
          });

          await _firestore.collection('orders').add({
            'userid': user.uid,
            'orderItems': orderItems,
            'totalAmount': totalAmount,
            'orderDate': Timestamp.now(),
            'status': 'Processing',
          });

          for (var doc in cartSnapshot.docs) {
            await _firestore.collection('cart').doc(doc.id).delete();
          }

          emit(CheckoutSuccess());
        } else {
          emit(CartEmpty());
        }
      } catch (e) {
        emit(CheckoutFailure(errorMessage: 'Checkout failed: ${e.toString()}'));
      }
    } else {
      emit(CheckoutFailure(errorMessage: 'You must be logged in to checkout.'));
    }
  }
}
