import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depi_final_project/presentation/screens/order/order_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/order_cubit.dart';
import '../../../cubits/order_state.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Cubit
    final orderCubit = OrderCubit();
    orderCubit.fetchOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocProvider(
        create: (_) => orderCubit,
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderError) {
              return Center(child: Text(state.message));
            } else if (state is OrderLoaded) {
              if (state.orders.isEmpty) {
                return const Center(
                    child: Text('You have no orders',
                        style: TextStyle(fontSize: 16)));
              }
              return ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return OrderCard(order: order);
                },
              );
            }
            return const SizedBox(); // Default case
          },
        ),
      ),
    );
  }
}
