import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models.dart';
import '../../data/store_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit({StoreRepository? repository})
      : _repo = repository ?? Repo.store,
        super(OrderInitial());

  final StoreRepository _repo;
  StreamSubscription<List<OrderModel>>? _sub;

  void fetchOrders() {
    emit(OrderLoading());
    _sub?.cancel();
    try {
      _sub = _repo.watchMyOrders().listen(
            (orders) => emit(OrderLoaded(orders)),
            onError: (error) =>
                emit(OrderError('We could not load your orders.')),
          );
    } catch (_) {
      emit(OrderError('We could not load your orders.'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
