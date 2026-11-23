import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models.dart';
import '../../data/store_repository.dart';
import '../../presentation/models/product_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({StoreRepository? repository})
      : _repo = repository ?? Repo.store,
        super(CartLoading());

  final StoreRepository _repo;

  void _emitItems(List<CartItem> items) {
    if (items.isEmpty) {
      emit(CartEmpty());
    } else {
      final total = items.fold<double>(0, (a, i) => a + i.lineTotal);
      emit(CartLoaded(cartItems: items, totalAmount: total));
    }
  }

  // Load Cart Items
  Future<void> loadCartItems({bool silent = false}) async {
    if (!silent) emit(CartLoading());
    try {
      _emitItems(await _repo.loadCart());
    } catch (e) {
      emit(CartError(message: 'Failed to load your bag. Please try again.'));
    }
  }

  // Add a product (used by product details and by "reorder")
  Future<bool> add(Product product,
      {required String size, required String color, int quantity = 1}) async {
    try {
      await _repo.addToCart(product,
          size: size, color: color, quantity: quantity);
      await loadCartItems(silent: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Update Quantity
  Future<void> updateQuantity(CartItem item, int quantityChange) async {
    final newQuantity = item.quantity + quantityChange;
    if (newQuantity <= 0) return;
    try {
      await _repo.setCartQuantity(item, newQuantity);
      await loadCartItems(silent: true);
    } catch (e) {
      emit(CartError(message: 'Failed to update quantity.'));
    }
  }

  // Delete Item
  Future<void> deleteItem(CartItem item) async {
    try {
      await _repo.removeFromCart(item);
      await loadCartItems(silent: true);
    } catch (e) {
      emit(CartError(message: 'Failed to remove the item.'));
    }
  }

  // Handle Checkout
  Future<void> handleCheckout({
    required Address address,
    required DeliveryOption delivery,
    required String paymentLabel,
  }) async {
    final current = state;
    if (current is! CartLoaded || current is CheckoutInProgress) return;
    emit(CheckoutInProgress(
        cartItems: current.cartItems, totalAmount: current.totalAmount));
    try {
      final order = await _repo.placeOrder(
          address: address, delivery: delivery, paymentLabel: paymentLabel);
      emit(CheckoutSuccess(order));
      emit(CartEmpty());
    } catch (e) {
      emit(CheckoutFailure(errorMessage: 'Checkout failed. Please try again.'));
      emit(CartLoaded(
          cartItems: current.cartItems, totalAmount: current.totalAmount));
    }
  }
}
