import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product_model.dart';

class HomepageNewSale extends StatelessWidget {
  final List<Product> products;
  final String type;

  HomepageNewSale({required this.products, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      child: ListView.builder(
        itemCount: products.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          Product product = products[index];
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
                      if (type == 'Sale')
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        margin: EdgeInsets.only(left: 140, top: 150),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.favorite_border),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: SizedBox(
                  width: 180, // Ensure the text doesn't exceed this width
                  child: Text(
                    product.description,
                    style: TextStyle(color: Colors.grey),
                    maxLines: 1, // Limit to 1 line
                    overflow: TextOverflow.ellipsis, // Cut off with ellipsis
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: SizedBox(
                  width: 180, // Ensure the text fits within this width
                  child: Text(
                    product.name,
                    overflow: TextOverflow.ellipsis, // Cut off with ellipsis
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
