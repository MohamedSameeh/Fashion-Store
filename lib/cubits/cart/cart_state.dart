import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<DocumentSnapshot> cartItems;
  final double totalAmount;

  CartLoaded({required this.cartItems, required this.totalAmount});
}

class CartEmpty extends CartState {}

class CartError extends CartState {
  final String message;

  CartError({required this.message});
}

class CheckoutSuccess extends CartState {}

class CheckoutFailure extends CartState {
  final String errorMessage;

  CheckoutFailure({required this.errorMessage});
}
