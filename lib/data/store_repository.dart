import 'dart:typed_data';

import '../presentation/models/product_model.dart';
import 'auth_repository.dart';
import 'models.dart';

/// `--dart-define=DEMO=true` swaps Firebase for the in-memory demo store.
const bool kDemoMode = bool.fromEnvironment('DEMO');

/// The single seam between the UI/cubits and the data source.
///
/// Two implementations exist:
///  * `FirestoreStoreRepository` (lib/data/firebase) - the real backend.
///  * `DemoStoreRepository` (lib/data/demo) - in-memory demo catalogue.
abstract class StoreRepository {
  // Catalogue
  Stream<List<Product>> watchProducts();

  // Favorites
  Stream<Set<String>> watchFavoriteIds();
  Future<void> toggleFavorite(Product product);

  // Cart
  Future<List<CartItem>> loadCart();
  Future<void> addToCart(Product product,
      {required String size, required String color, int quantity = 1});
  Future<void> setCartQuantity(CartItem item, int quantity);
  Future<void> removeFromCart(CartItem item);

  // Orders
  Future<OrderModel> placeOrder({
    required Address address,
    required DeliveryOption delivery,
    required String paymentLabel,
  });
  Stream<List<OrderModel>> watchMyOrders();

  /// Every order in the store (owner dashboard). Needs owner read access
  /// to the `orders` collection in the real backend.
  Stream<List<OrderModel>> watchAllOrders();

  // Reviews
  Stream<List<Review>> watchReviews(String productId);
  Future<void> addReview(String productId, int rating, String text);

  // Shipping addresses
  Stream<List<Address>> watchAddresses();
  Future<void> saveAddress(Address address);
  Future<void> deleteAddress(String id);
  Future<void> setDefaultAddress(String id);

  // Profile
  Stream<UserProfile?> watchProfile();
  Future<void> updateProfile(
      {required String name, required String email, required String phone});
  Future<void> uploadProfileImage(Uint8List bytes);
}

/// Tiny service locator, filled once in `main()`.
class Repo {
  Repo._();
  static late StoreRepository store;
  static late AuthRepository auth;
}
