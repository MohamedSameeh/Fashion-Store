import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depi_final_project/cubits/order_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Order State

// Order Cubit
class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());

  void fetchOrders() {
    emit(OrderLoading());
    final userId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('orders')
        .where('userid', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        emit(OrderLoaded([]));
      } else {
        emit(OrderLoaded(snapshot.docs));
      }
    }, onError: (error) {
      emit(OrderError('Error loading orders: ${error.toString()}'));
    });
  }
}
