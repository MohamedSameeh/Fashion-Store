import '../../models/product_model.dart';

enum ProductSort {
  featured('Featured'),
  newest('Newest'),
  priceLow('Price: low to high'),
  priceHigh('Price: high to low'),
  rating('Top rated'),
  discount('Biggest discount');

  const ProductSort(this.label);
  final String label;
}

List<Product> sortProducts(List<Product> list, ProductSort sort) {
  final out = [...list];
  switch (sort) {
    case ProductSort.featured:
      break;
    case ProductSort.newest:
      final epoch = DateTime.fromMillisecondsSinceEpoch(0);
      out.sort((a, b) =>
          (b.createdAt ?? epoch).compareTo(a.createdAt ?? epoch));
    case ProductSort.priceLow:
      out.sort((a, b) => a.salePrice.compareTo(b.salePrice));
    case ProductSort.priceHigh:
      out.sort((a, b) => b.salePrice.compareTo(a.salePrice));
    case ProductSort.rating:
      out.sort((a, b) => b.rating.compareTo(a.rating));
    case ProductSort.discount:
      out.sort((a, b) => b.discount.compareTo(a.discount));
  }
  return out;
}

/// Immutable search + filter criteria. Pure Dart so it is easy to test.
class ProductFilter {
  const ProductFilter({
    this.query = '',
    this.categories = const {},
    this.types = const {},
    this.sizes = const {},
    this.onSaleOnly = false,
    this.minPrice,
    this.maxPrice,
    this.minRating = 0,
    this.sort = ProductSort.featured,
  });

  final String query;

  /// Main categories: `woman`, `men`, `kids`.
  final Set<String> categories;

  /// Sub categories: `Clothes`, `Shoes`, `Accessories`, `New`.
  final Set<String> types;
  final Set<String> sizes;
  final bool onSaleOnly;
  final double? minPrice;
  final double? maxPrice;
  final double minRating;
  final ProductSort sort;

  /// Number of active filters (the query and the sort do not count).
  int get activeCount =>
      categories.length +
      types.length +
      sizes.length +
      (onSaleOnly ? 1 : 0) +
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (minRating > 0 ? 1 : 0);

  ProductFilter copyWith({
    String? query,
    Set<String>? categories,
    Set<String>? types,
    Set<String>? sizes,
    bool? onSaleOnly,
    double? Function()? minPrice,
    double? Function()? maxPrice,
    double? minRating,
    ProductSort? sort,
  }) =>
      ProductFilter(
        query: query ?? this.query,
        categories: categories ?? this.categories,
        types: types ?? this.types,
        sizes: sizes ?? this.sizes,
        onSaleOnly: onSaleOnly ?? this.onSaleOnly,
        minPrice: minPrice != null ? minPrice() : this.minPrice,
        maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
        minRating: minRating ?? this.minRating,
        sort: sort ?? this.sort,
      );

  /// Keeps the query and sort, drops every filter.
  ProductFilter cleared() => ProductFilter(query: query, sort: sort);

  bool matches(Product p) {
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final haystack =
          '${p.name} ${p.description} ${p.categoryLabel} ${p.subcateg} ${p.colors.join(' ')}'
              .toLowerCase();
      // every word of the query must appear somewhere
      for (final word in q.split(RegExp(r'\s+'))) {
        if (!haystack.contains(word)) return false;
      }
    }
    if (categories.isNotEmpty && !categories.contains(p.category)) return false;
    if (types.isNotEmpty && !types.contains(p.subcateg)) return false;
    if (sizes.isNotEmpty && !p.sizes.any(sizes.contains)) return false;
    if (onSaleOnly && !p.onSale) return false;
    if (minPrice != null && p.salePrice < minPrice!) return false;
    if (maxPrice != null && p.salePrice > maxPrice!) return false;
    if (minRating > 0 && p.rating < minRating) return false;
    return true;
  }

  List<Product> apply(List<Product> products) =>
      sortProducts(products.where(matches).toList(), sort);
}

/// Bounds and options derived from the catalogue for the filter sheet.
class FilterOptions {
  FilterOptions(List<Product> products)
      : sizes = _sizes(products),
        priceFloor = products.isEmpty
            ? 0
            : (products
                        .map((p) => p.salePrice)
                        .reduce((a, b) => a < b ? a : b) /
                    10)
                .floorToDouble() *
                10,
        priceCeil = products.isEmpty
            ? 100
            : (products
                        .map((p) => p.salePrice)
                        .reduce((a, b) => a > b ? a : b) /
                    10)
                .ceilToDouble() *
                10;

  final List<String> sizes;
  final double priceFloor;
  final double priceCeil;

  static const _letterOrder = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  static List<String> _sizes(List<Product> products) {
    final all = <String>{for (final p in products) ...p.sizes};
    int rank(String s) {
      final i = _letterOrder.indexOf(s);
      if (i >= 0) return i;
      final n = int.tryParse(s.replaceAll(RegExp('[^0-9]'), ''));
      if (n != null) return 100 + (s.endsWith('Y') ? 0 : 100) + n;
      return 1000;
    }

    return all.toList()..sort((a, b) => rank(a).compareTo(rank(b)));
  }
}
