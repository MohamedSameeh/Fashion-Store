import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/product_model.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/productdetails.dart';

class ClothesWomen extends StatefulWidget {
  const ClothesWomen({super.key});

  @override
  State<ClothesWomen> createState() => _ClothesWomenState();
}

class _ClothesWomenState extends State<ClothesWomen> {
  final productsStream = FirebaseFirestore.instance
      .collection('products')
      .where('maincateg', isEqualTo: 'woman')
      .where('subcateg', isEqualTo: 'Clothes')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Women Clothes'),
      ),
      body: Center(
        child: StreamBuilder<List<Product>>(
          stream: productsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching products'));
            }
            List<Product>? products = snapshot.data;

            if (products == null || products.isEmpty) {
              return const Center(child: Text('No products found'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: snapshot.data!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailsPage(product: products[index]),
                      ),
                    );
                  },
                  child: ProductCard(product: products[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
