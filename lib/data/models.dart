/// Plain data models shared by the Firestore and the demo data sources.
library;

class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price; // unit price actually paid (after discount)
  final String image;
  final String size;
  final String color;
  final int quantity;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.size,
    required this.color,
    required this.quantity,
  });

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        productId: productId,
        name: name,
        price: price,
        image: image,
        size: size,
        color: color,
        quantity: quantity ?? this.quantity,
      );

  /// Field names match the `cart` collection the app has always written.
  Map<String, dynamic> toMap(String userId) => {
        'proid': productId,
        'proname': name,
        'proprice': price,
        'prosize': size,
        'procolor': color,
        'proimage': image,
        'userid': userId,
        'existInCart': true,
        'cartProId': id,
        'quantity': quantity,
      };

  factory CartItem.fromMap(String id, Map<String, dynamic> d) => CartItem(
        id: id,
        productId: (d['proid'] ?? id).toString(),
        name: (d['proname'] ?? '').toString(),
        price: ((d['proprice'] ?? 0) as num).toDouble(),
        image: (d['proimage'] ?? '').toString(),
        size: (d['prosize'] ?? '').toString(),
        color: (d['procolor'] ?? '').toString(),
        quantity: ((d['quantity'] ?? 1) as num).toInt(),
      );
}

enum OrderStatus {
  processing('Processing'),
  shipped('Shipped'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.label);
  final String label;

  static OrderStatus parse(String? s) => OrderStatus.values.firstWhere(
        (e) => e.label.toLowerCase() == (s ?? '').toLowerCase(),
        orElse: () => OrderStatus.processing,
      );
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String image;
  final String color;
  final String size;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.color,
    required this.size,
  });

  double get lineTotal => price * quantity;

  Map<String, dynamic> toMap() => {
        'proid': productId,
        'proname': name,
        'proprice': price,
        'quantity': quantity,
        'proimage': image,
        'procolor': color,
        'prosize': size,
      };

  factory OrderItem.fromMap(Map<String, dynamic> d) => OrderItem(
        productId: (d['proid'] ?? '').toString(),
        name: (d['proname'] ?? '').toString(),
        price: ((d['proprice'] ?? 0) as num).toDouble(),
        quantity: ((d['quantity'] ?? 1) as num).toInt(),
        image: (d['proimage'] ?? '').toString(),
        color: (d['procolor'] ?? '').toString(),
        size: (d['prosize'] ?? '').toString(),
      );
}

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final List<OrderItem> items;

  /// Sum of the items (this is what the original app stored as totalAmount).
  final double itemsTotal;
  final double deliveryFee;
  final DateTime date;
  final OrderStatus status;
  final String deliveryMethod;
  final String paymentLabel;
  final String addressName;
  final String addressLine;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.items,
    required this.itemsTotal,
    required this.deliveryFee,
    required this.date,
    required this.status,
    this.deliveryMethod = 'Standard',
    this.paymentLabel = '',
    this.addressName = '',
    this.addressLine = '',
  });

  double get total => itemsTotal + deliveryFee;
  int get units => items.fold(0, (a, i) => a + i.quantity);

  /// Short human readable order number derived from the document id.
  String get number {
    final clean = id.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
    return '#${clean.length > 6 ? clean.substring(clean.length - 6) : clean}';
  }
}

class Review {
  final String id;
  final String productId;
  final String author;
  final int rating;
  final String text;
  final DateTime date;

  const Review({
    required this.id,
    required this.productId,
    required this.author,
    required this.rating,
    required this.text,
    required this.date,
  });
}

class Address {
  final String id;
  final String name;
  final String line; // street, city, postcode, country
  final String phone;
  final bool isDefault;

  const Address({
    required this.id,
    required this.name,
    required this.line,
    this.phone = '',
    this.isDefault = false,
  });

  Address copyWith({String? name, String? line, String? phone, bool? isDefault}) =>
      Address(
        id: id,
        name: name ?? this.name,
        line: line ?? this.line,
        phone: phone ?? this.phone,
        isDefault: isDefault ?? this.isDefault,
      );
}

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String imageUrl;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.imageUrl = '',
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  UserProfile copyWith({String? name, String? email, String? phone, String? imageUrl}) =>
      UserProfile(
        uid: uid,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        imageUrl: imageUrl ?? this.imageUrl,
      );
}

class DeliveryOption {
  final String id;
  final String label;
  final String eta;
  final double fee;
  const DeliveryOption(this.id, this.label, this.eta, this.fee);

  static const all = [
    DeliveryOption('standard', 'Standard', '3-5 business days', 5),
    DeliveryOption('express', 'Express', '1-2 business days', 12),
    DeliveryOption('nextday', 'Next day', 'Tomorrow by 6 PM', 20),
  ];
}
