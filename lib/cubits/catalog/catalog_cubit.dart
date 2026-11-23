import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/store_repository.dart';
import '../../presentation/models/product_model.dart';

abstract class CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  CatalogLoaded(this.products);
  final List<Product> products;

  Product? byId(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }
}

class CatalogError extends CatalogState {
  CatalogError(this.message);
  final String message;
}

/// One live subscription to the product catalogue shared by every screen
/// (home, shop, search, favorites, product details).
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit({StoreRepository? repository})
      : _repo = repository ?? Repo.store,
        super(CatalogLoading());

  final StoreRepository _repo;
  StreamSubscription<List<Product>>? _sub;

  void start() {
    if (_sub != null && state is! CatalogError) return;
    emit(CatalogLoading());
    _sub?.cancel();
    try {
      _sub = _repo.watchProducts().listen(
            (p) => emit(CatalogLoaded(p)),
            onError: (_) => emit(CatalogError(
                'We could not load the catalogue. Check your connection.')),
          );
    } catch (_) {
      emit(CatalogError('We could not load the catalogue.'));
    }
  }

  void retry() {
    _sub?.cancel();
    _sub = null;
    start();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
