import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/store_repository.dart';
import '../../presentation/models/product_model.dart';

/// Ids of the favorite products of the signed-in customer.
class FavoritesCubit extends Cubit<Set<String>> {
  FavoritesCubit({StoreRepository? repository})
      : _repo = repository ?? Repo.store,
        super(const {});

  final StoreRepository _repo;
  StreamSubscription<Set<String>>? _sub;

  /// Call after sign in (the Firestore path needs the user id).
  void start() {
    _sub?.cancel();
    try {
      _sub = _repo.watchFavoriteIds().listen(emit, onError: (_) {});
    } catch (_) {}
  }

  /// Returns true when the product is a favorite after the toggle.
  Future<bool> toggle(Product product) async {
    final wasFavorite = state.contains(product.id);
    await _repo.toggleFavorite(product);
    return !wasFavorite;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
