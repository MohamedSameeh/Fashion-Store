import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final List<String> colors;
  final int discount;

  final String category;
  final String subcateg;

  final double price;
  final List<String> images;
  final String sid;
  final List<String> sizes;

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
  });
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      name: data['proname'] ?? '',
      description: data['prodesc'] ?? '',
      colors: List<String>.from(data['color'] ?? []),
      discount: data['discount'] ?? 0,
      category: data['maincateg'] ?? '',
      price: data['price'].toDouble(),
      images: List<String>.from(data['proimages'] ?? []),
      sid: data['sid'] ?? '',
      sizes: List<String>.from(data['size'] ?? []),
      subcateg: data['subcateg'] ?? '',
    );
  }
}
