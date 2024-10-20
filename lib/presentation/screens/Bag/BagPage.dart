import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depi_final_project/presentation/screens/Bag/cart_iteam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../cubits/cart/cart_state.dart';
import 'empty_cart.dart';

class BagPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit()..loadCartItems(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 4,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent, Colors.black54],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          title: Text(
            'My Bag',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            } else if (state is CartError) {
              return Center(
                child: Text(state.message),
              );
            } else if (state is CartEmpty) {
              return EmptyCart();
            } else if (state is CartLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = state.cartItems[index];
                        return CartItem(item: item);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTotalAmount(state.totalAmount),
                        SizedBox(height: 16),
                        _buildCheckoutButton(context, state.totalAmount),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildTotalAmount(double totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$${totalAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context, double totalAmount) {
    return ElevatedButton(
      onPressed: totalAmount > 0
          ? () {
              context.read<CartCubit>().handleCheckout();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Your order has been placed'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        backgroundColor: totalAmount > 0 ? Colors.red : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Center(
        child: Text(
          'CHECK OUT',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
