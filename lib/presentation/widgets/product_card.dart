import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import '../models/product_model.dart';

class ProductCard extends StatefulWidget {
  // تغيير إلى StatefulWidget
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false; // متغير لتتبع حالة المفضلة

  @override
  void initState() {
    super.initState();
    _checkIfFavorite(); // التحقق من حالة المفضلة عند التحميل
  }

  Future<void> _checkIfFavorite() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final favoriteRef = FirebaseFirestore.instance
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .doc(widget.product.id); // استخدم product.id مباشرة

    final snapshot = await favoriteRef.get();
    setState(() {
      isFavorite = snapshot.exists; // تحديث الحالة عند التحميل
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.product.images[0],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              // Gradient overlay
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red
                          : null, // تغيير اللون حسب الحالة
                    ),
                    onPressed: () async {
                      final userId = FirebaseAuth.instance.currentUser!.uid;
                      final favoriteRef = FirebaseFirestore.instance
                          .collection('favorites')
                          .doc(userId)
                          .collection('userFavorites')
                          .doc(widget.product.id); // استخدم product.id مباشرة
                      final snapshot = await favoriteRef.get();

                      if (snapshot.exists) {
                        // إزالة من المفضلة
                        await favoriteRef.delete();
                        setState(() {
                          isFavorite = false; // تحديث الحالة
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Removed from favorites')),
                        );
                      } else {
                        // إضافة إلى المفضلة
                        await favoriteRef.set({
                          'id': widget.product.id,
                          'name': widget.product.name,
                          'price': widget.product.price,
                          'image': widget.product.images[0],
                        });
                        setState(() {
                          isFavorite = true; // تحديث الحالة
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to favorites')),
                        );
                      }
                    },
                  ),
                ),
              ),
              if (widget.product.discount > 0)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '-${widget.product.discount.toString()}%', // تأكد من أن الخصم هو رقم
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                if (widget.product.discount > 0)
                  Text(
                    '\$${(widget.product.price + (widget.product.price * widget.product.discount / 100)).toStringAsFixed(2)}', // السعر الأصلي
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  '\$${(widget.product.price - (widget.product.price * widget.product.discount / 100)).toStringAsFixed(2)}', // السعر المخفض
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
