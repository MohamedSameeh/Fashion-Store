import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../cubits/cart/cart_cubit.dart';

class CartItem extends StatelessWidget {
  final DocumentSnapshot item;

  const CartItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade200], // Subtle gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 6,
                offset: Offset(0, 3), // Soft shadow
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item['proimage'],
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(width: 16),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['proname'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Color: ${item['procolor']} | Size: ${item['prosize']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '\$${item['proprice']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Quantity control and delete button
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quantity control or delete icon
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // If quantity is 1, show delete icon instead of minus
                        IconButton(
                          icon: Icon(
                            item['quantity'] == 1 ? Icons.delete : Icons.remove,
                            size: 20,
                            color: item['quantity'] == 1
                                ? Colors.redAccent
                                : Colors.grey.shade700,
                          ),
                          onPressed: () {
                            if (item['quantity'] == 1) {
                              // Delete item if quantity is 1
                              context.read<CartCubit>().deleteItem(item);
                            } else {
                              // Decrease quantity
                              context
                                  .read<CartCubit>()
                                  .updateQuantity(item, -1);
                            }
                          },
                        ),
                        Text(
                          item['quantity'].toString(),
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        // Increase quantity
                        IconButton(
                          icon: Icon(Icons.add,
                              size: 20, color: Colors.grey.shade700),
                          onPressed: () {
                            context.read<CartCubit>().updateQuantity(item, 1);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
