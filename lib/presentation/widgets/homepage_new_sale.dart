import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class HomepageNewSale extends StatefulWidget {
  final List<Product> products;
  final String type;

  HomepageNewSale({required this.products, required this.type});

  @override
  _HomepageNewSaleState createState() => _HomepageNewSaleState();
}

class _HomepageNewSaleState extends State<HomepageNewSale> {
  late List<bool> isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = List.generate(widget.products.length, (_) => false);

    _checkFavorites();
  }

  Future<void> _checkFavorites() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    for (int index = 0; index < widget.products.length; index++) {
      final favoriteRef = FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .doc(widget.products[index].id);

      final snapshot = await favoriteRef.get();
      if (snapshot.exists) {
        setState(() {
          isFavorite[index] = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      child: ListView.builder(
        itemCount: widget.products.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          Product product = widget.products[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('details_screen', arguments: product);
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  width: 200, // Container width
                  height: 195, // Container height
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: product.images[0],
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                        width: 180,
                        height: 180,
                      ),
                      if (widget.type == 'Sale')
                        Container(
                          margin: EdgeInsets.all(9),
                          width: 70,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Text(
                              '${product.discount}% Off',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite[index]
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite[index] ? Colors.red : null,
                            ),
                            onPressed: () async {
                              final userId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              final favoriteRef = FirebaseFirestore.instance
                                  .collection('favorites')
                                  .doc(userId)
                                  .collection('userFavorites')
                                  .doc(product.id);

                              final snapshot = await favoriteRef.get();

                              if (snapshot.exists) {
                                // Remove from favorites
                                await favoriteRef.delete();
                                setState(() {
                                  isFavorite[index] = false; // تحديث الحالة
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Removed from favorites')),
                                );
                              } else {
                                // Add to favorites
                                await favoriteRef.set({
                                  'id': product.id,
                                  'name': product.name,
                                  'price': product.price,
                                  'image': product.images[0],
                                });
                                setState(() {
                                  isFavorite[index] = true; // تحديث الحالة
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Added to favorites')),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: SizedBox(
                  width: 180,
                  child: Text(
                    product.description,
                    style: TextStyle(color: Colors.grey),
                    maxLines: 1, // Limit to 1 line
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: SizedBox(
                  width: 180,
                  child: Text(
                    product.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  '\$${product.price}',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
