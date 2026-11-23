import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../presentation/models/product_model.dart';
import '../models.dart';
import '../store_repository.dart';

/// Real backend: Cloud Firestore + Firebase Storage.
///
/// Collections and field names are the ones the app has always used:
/// `products`, `cart`, `orders`, `favorites/{uid}/userFavorites`, `users`.
/// `reviews` and `users/{uid}/addresses` are new (those two screens were
/// static before).
class FirestoreStoreRepository implements StoreRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('You must be logged in.');
    return user.uid;
  }

  // ---------------------------------------------------------------- products
  @override
  Stream<List<Product>> watchProducts() =>
      _db.collection('products').snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());

  // --------------------------------------------------------------- favorites
  CollectionReference<Map<String, dynamic>> get _favorites =>
      _db.collection('favorites').doc(_uid).collection('userFavorites');

  @override
  Stream<Set<String>> watchFavoriteIds() =>
      _favorites.snapshots().map((s) => s.docs.map((d) => d.id).toSet());

  @override
  Future<void> toggleFavorite(Product product) async {
    final ref = _favorites.doc(product.id);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'image': product.image,
      });
    }
  }

  // -------------------------------------------------------------------- cart
  @override
  Future<List<CartItem>> loadCart() async {
    final snapshot =
        await _db.collection('cart').where('userid', isEqualTo: _uid).get();
    return snapshot.docs.map((d) => CartItem.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<void> addToCart(Product product,
      {required String size, required String color, int quantity = 1}) async {
    // One line per user + product + size + color.
    final id = '${_uid}_${product.id}_${size}_$color'.replaceAll('/', '-');
    final ref = _db.collection('cart').doc(id);
    final existing = await ref.get();
    if (existing.exists) {
      await ref.update({'quantity': FieldValue.increment(quantity)});
      return;
    }
    await ref.set(CartItem(
      id: id,
      productId: product.id,
      name: product.name,
      price: product.salePrice,
      image: product.image,
      size: size,
      color: color,
      quantity: quantity,
    ).toMap(_uid));
  }

  @override
  Future<void> setCartQuantity(CartItem item, int quantity) =>
      _db.collection('cart').doc(item.id).update({'quantity': quantity});

  @override
  Future<void> removeFromCart(CartItem item) =>
      _db.collection('cart').doc(item.id).delete();

  // ------------------------------------------------------------------ orders
  @override
  Future<OrderModel> placeOrder({
    required Address address,
    required DeliveryOption delivery,
    required String paymentLabel,
  }) async {
    final uid = _uid;
    final cart = await loadCart();
    if (cart.isEmpty) throw StateError('Your bag is empty.');

    final items = cart
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
    final itemsTotal = items.fold<double>(0, (a, i) => a + i.lineTotal);
    final profile = await _db.collection('users').doc(uid).get();
    final customer = (profile.data()?['user_name'] ?? '').toString();
    final now = DateTime.now();

    final ref = await _db.collection('orders').add({
      'userid': uid,
      'customerName': customer,
      'orderItems': items.map((i) => i.toMap()).toList(),
      'totalAmount': itemsTotal,
      'deliveryFee': delivery.fee,
      'deliveryMethod': delivery.label,
      'paymentLabel': paymentLabel,
      'addressName': address.name,
      'addressLine': address.line,
      'orderDate': Timestamp.fromDate(now),
      'status': OrderStatus.processing.label,
    });

    final batch = _db.batch();
    for (final c in cart) {
      batch.delete(_db.collection('cart').doc(c.id));
    }
    await batch.commit();

    return OrderModel(
      id: ref.id,
      userId: uid,
      customerName: customer,
      items: items,
      itemsTotal: itemsTotal,
      deliveryFee: delivery.fee,
      date: now,
      status: OrderStatus.processing,
      deliveryMethod: delivery.label,
      paymentLabel: paymentLabel,
      addressName: address.name,
      addressLine: address.line,
    );
  }

  OrderModel _order(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return OrderModel(
      id: doc.id,
      userId: (d['userid'] ?? '').toString(),
      customerName: (d['customerName'] ?? '').toString(),
      items: ((d['orderItems'] ?? []) as List)
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      itemsTotal: ((d['totalAmount'] ?? 0) as num).toDouble(),
      deliveryFee: ((d['deliveryFee'] ?? 0) as num).toDouble(),
      date: (d['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: OrderStatus.parse(d['status']?.toString()),
      deliveryMethod: (d['deliveryMethod'] ?? 'Standard').toString(),
      paymentLabel: (d['paymentLabel'] ?? '').toString(),
      addressName: (d['addressName'] ?? '').toString(),
      addressLine: (d['addressLine'] ?? '').toString(),
    );
  }

  List<OrderModel> _sorted(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map(_order).toList()..sort((a, b) => b.date.compareTo(a.date));

  @override
  Stream<List<OrderModel>> watchMyOrders() => _db
      .collection('orders')
      .where('userid', isEqualTo: _uid)
      .snapshots()
      .map(_sorted);

  @override
  Stream<List<OrderModel>> watchAllOrders() =>
      _db.collection('orders').snapshots().map(_sorted);

  // ----------------------------------------------------------------- reviews
  @override
  Stream<List<Review>> watchReviews(String productId) => _db
      .collection('reviews')
      .where('productId', isEqualTo: productId)
      .snapshots()
      .map((s) => s.docs.map((doc) {
            final d = doc.data();
            return Review(
              id: doc.id,
              productId: productId,
              author: (d['author'] ?? 'Customer').toString(),
              rating: ((d['rating'] ?? 5) as num).toInt(),
              text: (d['text'] ?? '').toString(),
              date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList()
            ..sort((a, b) => b.date.compareTo(a.date)));

  @override
  Future<void> addReview(String productId, int rating, String text) async {
    final profile = await _db.collection('users').doc(_uid).get();
    await _db.collection('reviews').add({
      'productId': productId,
      'userid': _uid,
      'author': (profile.data()?['user_name'] ?? 'Customer').toString(),
      'rating': rating,
      'text': text,
      'date': Timestamp.now(),
    });
  }

  // --------------------------------------------------------------- addresses
  CollectionReference<Map<String, dynamic>> get _addresses =>
      _db.collection('users').doc(_uid).collection('addresses');

  @override
  Stream<List<Address>> watchAddresses() =>
      _addresses.snapshots().map((s) => s.docs.map((doc) {
            final d = doc.data();
            return Address(
              id: doc.id,
              name: (d['name'] ?? '').toString(),
              line: (d['line'] ?? '').toString(),
              phone: (d['phone'] ?? '').toString(),
              isDefault: d['isDefault'] == true,
            );
          }).toList());

  @override
  Future<void> saveAddress(Address address) async {
    final data = {
      'name': address.name,
      'line': address.line,
      'phone': address.phone,
      'isDefault': address.isDefault,
    };
    if (address.id.isEmpty) {
      final existing = await _addresses.limit(1).get();
      if (existing.docs.isEmpty) data['isDefault'] = true;
      await _addresses.add(data);
    } else {
      await _addresses.doc(address.id).set(data);
    }
  }

  @override
  Future<void> deleteAddress(String id) => _addresses.doc(id).delete();

  @override
  Future<void> setDefaultAddress(String id) async {
    final all = await _addresses.get();
    final batch = _db.batch();
    for (final doc in all.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == id});
    }
    await batch.commit();
  }

  // ----------------------------------------------------------------- profile
  @override
  Stream<UserProfile?> watchProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null);
    return _db.collection('users').doc(user.uid).snapshots().map((doc) {
      final d = doc.data();
      return UserProfile(
        uid: user.uid,
        name: (d?['user_name'] ?? user.displayName ?? '').toString(),
        email: (d?['email'] ?? user.email ?? '').toString(),
        phone: (d?['phone_number'] ?? '').toString(),
        imageUrl: (d?['profile_image'] ?? '').toString(),
      );
    });
  }

  @override
  Future<void> updateProfile(
      {required String name,
      required String email,
      required String phone}) async {
    await _db.collection('users').doc(_uid).set(
        {'user_name': name, 'email': email, 'phone_number': phone},
        SetOptions(merge: true));
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != email) {
      await user.verifyBeforeUpdateEmail(email);
    }
  }

  @override
  Future<void> uploadProfileImage(Uint8List bytes) async {
    final ref =
        FirebaseStorage.instance.ref().child('profile_images/$_uid.jpg');
    await ref.putData(bytes);
    final url = await ref.getDownloadURL();
    await _db
        .collection('users')
        .doc(_uid)
        .set({'profile_image': url}, SetOptions(merge: true));
  }
}
