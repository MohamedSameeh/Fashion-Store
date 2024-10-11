import 'package:depi_final_project/presentation/widgets/product_card.dart';
import 'package:depi_final_project/presentation/widgets/productdetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class CategoriesDetails extends StatefulWidget {
  final String type;
  const CategoriesDetails({super.key, required this.type});

  @override
  State<CategoriesDetails> createState() => _CategoriesDetailsState();
}

class _CategoriesDetailsState extends State<CategoriesDetails> {
  late Stream<List<Product>> productStream;

  @override
  void initState() {
    super.initState();

    productStream = fetchProductsByType(widget.type);
  }

  Stream<List<Product>> fetchProductsByType(String type) {
    if (type == "New") {
      return FirebaseFirestore.instance
          .collection('products')
          .where('subcateg', isEqualTo: 'New')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
    } else if (type == "Sale") {
      return FirebaseFirestore.instance
          .collection('products')
          .where('discount', isGreaterThan: 0)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
    }
    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type} Products'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: productStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching products'));
          }

          List<Product>? products = snapshot.data;

          if (products == null || products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to product details
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsPage(product: product),
                    ),
                  );
                },
                child: ProductCard(product: product),
              );
            },
          );
        },
      ),
    );
  }
}
