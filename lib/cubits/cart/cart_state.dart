import '../../data/models.dart';

abstract class CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> cartItems;
  final double totalAmount;

  CartLoaded({required this.cartItems, required this.totalAmount});

  int get units => cartItems.fold(0, (a, i) => a + i.quantity);
}

class CartEmpty extends CartState {}

class CartError extends CartState {
  final String message;

  CartError({required this.message});
}

/// Checkout is being submitted (the button shows a spinner).
class CheckoutInProgress extends CartLoaded {
  CheckoutInProgress({required super.cartItems, required super.totalAmount});
}

class CheckoutSuccess extends CartState {
  final OrderModel order;
  CheckoutSuccess(this.order);
}

class CheckoutFailure extends CartState {
  final String errorMessage;

  CheckoutFailure({required this.errorMessage});
}
