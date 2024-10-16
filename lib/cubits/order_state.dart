import 'package:cloud_firestore/cloud_firestore.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<QueryDocumentSnapshot> orders;

  OrderLoaded(this.orders);
}

class OrderError extends OrderState {
  final String message;

  OrderError(this.message);
}
