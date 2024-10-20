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
        // Update Firestore with the new quantity
        await _firestore.collection('cart').doc(doc.id).update({
          'quantity': newQuantity,
        });

        if (state is CartLoaded) {
          final currentState = state as CartLoaded;
          // Update the specific item in the current list
          final updatedCartItems =
              List<DocumentSnapshot>.from(currentState.cartItems);
          final indexToUpdate =
              updatedCartItems.indexWhere((item) => item.id == doc.id);

          if (indexToUpdate != -1) {
            // Modify the local cart item quantity
            updatedCartItems[indexToUpdate] =
                await _firestore.collection('cart').doc(doc.id).get();
          }

          // Recalculate total amount
          double newTotalAmount = 0;
          for (var item in updatedCartItems) {
            newTotalAmount += item['proprice'] * item['quantity'];
          }

          // Emit new state with updated items
          emit(CartLoaded(
              cartItems: updatedCartItems, totalAmount: newTotalAmount));
        }
      } catch (e) {
        emit(CartError(message: 'Failed to update quantity: ${e.toString()}'));
      }
    }
  }

  // Delete Item
  void deleteItem(DocumentSnapshot doc) async {
    try {
      await _firestore.collection('cart').doc(doc.id).delete();

      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final updatedCartItems =
            List<DocumentSnapshot>.from(currentState.cartItems);

        updatedCartItems.removeWhere((item) => item.id == doc.id);

        double newTotalAmount = 0;
        for (var item in updatedCartItems) {
          newTotalAmount += item['proprice'] * item['quantity'];
        }

        emit(CartLoaded(
            cartItems: updatedCartItems, totalAmount: newTotalAmount));
      }
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
