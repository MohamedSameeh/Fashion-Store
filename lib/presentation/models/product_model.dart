import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final List<String> colors;
  final int discount;

  /// Main category as stored in Firestore: `woman`, `men` or `kids`.
  final String category;

  /// Sub category: `New`, `Clothes`, `Shoes` or `Accessories`.
  final String subcateg;

  final double price;

  /// Image sources. A source is either an http(s) URL (Firebase Storage),
  /// an `assets/...` path, or an `art:<icon>:<hexColor>` drawn tile.
  final List<String> images;
  final String sid;
  final List<String> sizes;

  /// Average rating (0-5) and number of ratings. Optional in Firestore.
  final double rating;
  final int reviewCount;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
    required this.discount,
    required this.category,
    required this.price,
    required this.images,
    required this.sid,
    required this.sizes,
    required this.subcateg,
    this.rating = 0,
    this.reviewCount = 0,
    this.createdAt,
  });

  bool get onSale => discount > 0;

  /// Price the customer pays after the discount.
  double get salePrice => price - (price * discount / 100);

  String get image => images.isNotEmpty ? images.first : '';

  String get categoryLabel => switch (category) {
        'woman' => 'Women',
        'men' => 'Men',
        'kids' => 'Kids',
        _ => category,
      };

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      name: data['proname'] ?? '',
      description: data['prodesc'] ?? '',
      colors: List<String>.from(data['color'] ?? []),
      discount: ((data['discount'] ?? 0) as num).toInt(),
      category: data['maincateg'] ?? '',
      price: (data['price'] as num).toDouble(),
      images: List<String>.from(data['proimages'] ?? []),
      sid: data['sid'] ?? '',
      sizes: List<String>.from(data['size'] ?? []),
      subcateg: data['subcateg'] ?? '',
      rating: ((data['rating'] ?? 0) as num).toDouble(),
      reviewCount: ((data['reviewCount'] ?? 0) as num).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
