import 'dart:async';
import 'dart:typed_data';

import '../../presentation/models/product_model.dart';
import '../auth_repository.dart';
import '../models.dart';
import '../store_repository.dart';
import 'demo_data.dart';

/// A value that can be watched as a stream (current value first).
class _Live<T> {
  _Live(this._value);
  T _value;
  final _controller = StreamController<T>.broadcast();

  T get value => _value;
  set value(T v) {
    _value = v;
    _controller.add(v);
  }

  Stream<T> watch({Duration delay = Duration.zero}) async* {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    yield _value;
    yield* _controller.stream;
  }
}

/// In-memory store used by `--dart-define=DEMO=true`. Behaves like the real
/// backend (cart, favorites, orders, reviews, addresses all mutate) but
/// nothing leaves the device and everything resets on restart.
class DemoStoreRepository implements StoreRepository {
  static const _latency = Duration(milliseconds: 450);

  final _products = _Live<List<Product>>(DemoData.products());
  final _favorites = _Live<Set<String>>({...DemoData.initialFavorites});
  final _orders = _Live<List<OrderModel>>(DemoData.orders());
  final _addresses = _Live<List<Address>>([...DemoData.addresses]);
  final _profile = _Live<UserProfile?>(DemoData.profile);
  final _reviews = _Live<Map<String, List<Review>>>(
      {for (final e in DemoData.reviews.entries) e.key: [...e.value]});
  final List<CartItem> _cart = [];
  int _seq = 0;

  @override
  Stream<List<Product>> watchProducts() => _products.watch(delay: _latency);

  @override
  Stream<Set<String>> watchFavoriteIds() => _favorites.watch();

  @override
  Future<void> toggleFavorite(Product product) async {
    final next = {..._favorites.value};
    if (!next.remove(product.id)) next.add(product.id);
    _favorites.value = next;
  }

  @override
  Future<List<CartItem>> loadCart() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_cart);
  }

  @override
  Future<void> addToCart(Product product,
      {required String size, required String color, int quantity = 1}) async {
    final id = '${product.id}_${size}_$color';
    final i = _cart.indexWhere((c) => c.id == id);
    if (i >= 0) {
      _cart[i] = _cart[i].copyWith(quantity: _cart[i].quantity + quantity);
    } else {
      _cart.add(CartItem(
        id: id,
        productId: product.id,
        name: product.name,
        price: product.salePrice,
        image: product.image,
        size: size,
        color: color,
        quantity: quantity,
      ));
    }
  }

  @override
  Future<void> setCartQuantity(CartItem item, int quantity) async {
    final i = _cart.indexWhere((c) => c.id == item.id);
    if (i >= 0) _cart[i] = _cart[i].copyWith(quantity: quantity);
  }

  @override
  Future<void> removeFromCart(CartItem item) async =>
      _cart.removeWhere((c) => c.id == item.id);

  @override
  Future<OrderModel> placeOrder({
    required Address address,
    required DeliveryOption delivery,
    required String paymentLabel,
  }) async {
    if (_cart.isEmpty) throw StateError('Your bag is empty.');
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final items = _cart
        .map((c) => OrderItem(
              productId: c.productId,
              name: c.name,
              price: c.price,
              quantity: c.quantity,
              image: c.image,
              color: c.color,
              size: c.size,
            ))
        .toList();
    _seq++;
    final order = OrderModel(
      id: 'FS-10${4400 + _seq * 3}',
      userId: DemoData.userId,
      customerName: _profile.value?.name ?? DemoData.profile.name,
      items: items,
      itemsTotal: items.fold(0, (a, i) => a + i.lineTotal),
      deliveryFee: delivery.fee,
      date: DateTime.now(),
      status: OrderStatus.processing,
      deliveryMethod: delivery.label,
      paymentLabel: paymentLabel,
      addressName: address.name,
      addressLine: address.line,
    );
    _cart.clear();
    _orders.value = [order, ..._orders.value];
    return order;
  }

  @override
  Stream<List<OrderModel>> watchMyOrders() => _orders
      .watch(delay: _latency)
      .map((all) => all.where((o) => o.userId == DemoData.userId).toList());

  @override
  Stream<List<OrderModel>> watchAllOrders() => _orders.watch(delay: _latency);

  @override
  Stream<List<Review>> watchReviews(String productId) => _reviews
      .watch(delay: const Duration(milliseconds: 300))
      .map((m) => m[productId] ?? const []);

  @override
  Future<void> addReview(String productId, int rating, String text) async {
    final review = Review(
      id: 'local-${++_seq}',
      productId: productId,
      author: (_profile.value?.name ?? 'You').split(' ').first,
      rating: rating,
      text: text,
      date: DateTime.now(),
    );
    final list = [review, ...?_reviews.value[productId]];
    _reviews.value = {..._reviews.value, productId: list};
    // keep the product's average in sync with its reviews
    final avg = list.fold<int>(0, (a, r) => a + r.rating) / list.length;
    _products.value = [
      for (final p in _products.value)
        if (p.id == productId)
          Product(
            id: p.id,
            name: p.name,
            description: p.description,
            colors: p.colors,
            discount: p.discount,
            category: p.category,
            price: p.price,
            images: p.images,
            sid: p.sid,
            sizes: p.sizes,
            subcateg: p.subcateg,
            rating: double.parse(avg.toStringAsFixed(1)),
            reviewCount: list.length,
            createdAt: p.createdAt,
          )
        else
          p
    ];
  }

  @override
  Stream<List<Address>> watchAddresses() => _addresses.watch();

  @override
  Future<void> saveAddress(Address address) async {
    final list = [..._addresses.value];
    if (address.id.isEmpty) {
      list.add(Address(
        id: 'addr-local-${++_seq}',
        name: address.name,
        line: address.line,
        phone: address.phone,
        isDefault: list.isEmpty,
      ));
    } else {
      final i = list.indexWhere((a) => a.id == address.id);
      if (i >= 0) list[i] = address;
    }
    _addresses.value = list;
  }

  @override
  Future<void> deleteAddress(String id) async =>
      _addresses.value = _addresses.value.where((a) => a.id != id).toList();

  @override
  Future<void> setDefaultAddress(String id) async => _addresses.value = [
        for (final a in _addresses.value) a.copyWith(isDefault: a.id == id)
      ];

  @override
  Stream<UserProfile?> watchProfile() => _profile.watch();

  @override
  Future<void> updateProfile(
      {required String name,
      required String email,
      required String phone}) async {
    _profile.value =
        _profile.value?.copyWith(name: name, email: email, phone: phone);
  }

  @override
  Future<void> uploadProfileImage(Uint8List bytes) async {
    // Demo mode has no storage bucket; the avatar keeps showing initials.
  }
}

/// Local session for demo mode: any well-formed email + password signs in
/// as the demo customer. Nothing is sent anywhere.
class DemoAuthRepository implements AuthRepository {
  bool _signedIn = false;

  @override
  bool get isSignedIn => _signedIn;

  @override
  String? get uid => _signedIn ? DemoData.userId : null;

  Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 600));

  @override
  Future<bool> signInWithEmail(String email, String password) async {
    await _wait();
    if (password.length < 6) throw AuthFailure('Wrong email or password.');
    _signedIn = true;
    return true;
  }

  @override
  Future<void> signUpWithEmail(
      String name, String email, String password) async {
    await _wait();
  }

  @override
  Future<bool> signInWithGoogle() async {
    await _wait();
    return _signedIn = true;
  }

  @override
  Future<bool> signInWithFacebook() async {
    await _wait();
    return _signedIn = true;
  }

  @override
  Future<void> sendPasswordReset(String email) => _wait();

  @override
  Future<void> updatePassword(String newPassword) => _wait();

  @override
  Future<void> signOut() async => _signedIn = false;
}
