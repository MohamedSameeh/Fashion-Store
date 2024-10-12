import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus
import '../models/product_model.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

enum CartEnum {
  loading,
  error,
  existInCart,
  notExistInCart,
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String selectedSize = 'M';
  String selectedColor = 'Black';

  List<String> sizes = ['S', 'M', 'L', 'XL'];
  List<String> colors = ['Black', 'White', 'Red'];

  List<String> recommendedProducts = [
    'https://example.com/images/8.jpeg',
    'https://example.com/images/10.jpg',
    'https://example.com/images/11.jpg',
  ];

  CartEnum cartEnum = CartEnum.notExistInCart;

  void shareProduct() {
    String shareText = 'Check out this product: ${widget.product.name}\n'
        'Description: ${widget.product.description}\n'
        'Price: \$${widget.product.price}\n';

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference cartStream =
        FirebaseFirestore.instance.collection('cart').doc(widget.product.id);
    final productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('maincateg', isEqualTo: widget.product.category)
        .where('subcateg', isEqualTo: widget.product.subcateg)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: shareProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.product.images[0],
                  height: 350,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.product.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                      Text('\$${widget.product.price}',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 24)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: selectedSize,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSize = newValue!;
                          });
                        },
                        items:
                            sizes.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      DropdownButton<String>(
                        value: selectedColor,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedColor = newValue!;
                          });
                        },
                        items: colors
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      IconButton(
                        icon: Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.product.description,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: StreamBuilder<DocumentSnapshot>(
                        stream: cartStream.snapshots(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error'));
                          }

                          return !snapshot.data!.exists
                              ? StatefulBuilder(builder: (context, setState) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 100,
                                        vertical: 15,
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        cartEnum = CartEnum.loading;
                                      });

                                      CollectionReference cartStream =
                                          FirebaseFirestore.instance
                                              .collection('cart');

                                      await cartStream
                                          .doc(widget.product.id)
                                          .set({
                                        'proname': widget.product.name,
                                        'proprice': widget.product.price,
                                        'prosize': selectedSize,
                                        'procolor': selectedColor,
                                        'proimage': widget.product.images[0],
                                        'userid': FirebaseAuth
                                            .instance.currentUser!.uid,
                                        'existInCart': true,
                                        'cartProId': widget.product.id,
                                        'quantity': 1,
                                      }).then((value) {
                                        setState(() {
                                          cartEnum = CartEnum.existInCart;
                                        });
                                      }).catchError((e) {
                                        setState(() {
                                          cartEnum = CartEnum.error;
                                        });
                                      });
                                    },
                                    child: cartEnum == CartEnum.loading
                                        ? CircularProgressIndicator()
                                        : Text(
                                            'ADD TO CART',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                  );
                                })
                              : ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 100,
                                      vertical: 15,
                                    ),
                                  ),
                                  child: Text("Exist in Cart"),
                                );
                        }),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You can also like this',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: StreamBuilder<List<Product>>(
                        stream: productsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error fetching products'));
                          }
                          List<Product>? products = snapshot.data;

                          if (products == null || products.isEmpty) {
                            return const Center(
                                child: Text('No products found'));
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: SizedBox(
                                  width: 150,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  products[index].images[0],
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                          if (index == 0)
                                            Positioned(
                                              top: 5,
                                              left: 5,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5, vertical: 2),
                                                color: Colors.redAccent,
                                                child: Text(
                                                  "- ${products[index].discount.toString()} %",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          Positioned(
                                            right: 5,
                                            bottom: 0,
                                            child: IconButton(
                                              icon: Icon(Icons.favorite_border),
                                              color: Colors.white,
                                              onPressed: () {},
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        products[index].name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        products[index].price.toString(),
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
