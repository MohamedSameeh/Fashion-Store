import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../cubits/catalog/catalog_cubit.dart';
import '../../models/product_model.dart';
import '../../widgets/categoriesDetails.dart';
import '../../widgets/product_card.dart';
import 'product_filter.dart';

/// Product search with filters (category, type, size, price range, rating,
/// on sale) and sorting. Works on the shared catalogue from [CatalogCubit],
/// so it behaves the same on Firestore data and on demo data.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initial = const ProductFilter()});
  final ProductFilter initial;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late ProductFilter _filter = widget.initial;
  late final _controller = TextEditingController(text: widget.initial.query);

  static const _categoryLabels = {
    'woman': 'Women',
    'men': 'Men',
    'kids': 'Kids'
  };

  @override
  void initState() {
    super.initState();
    context.read<CatalogCubit>().start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCategory(String c) {
    final next = {..._filter.categories};
    if (!next.remove(c)) next.add(c);
    setState(() => _filter = _filter.copyWith(categories: next));
  }

  Future<void> _openFilters(List<Product> products) async {
    final result = await showModalBottomSheet<ProductFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FilterSheet(initial: _filter, products: products),
    );
    if (result != null) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(right: AppSpace.lg),
          child: SizedBox(
            height: 46,
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: (v) =>
                  setState(() => _filter = _filter.copyWith(query: v)),
              decoration: InputDecoration(
                hintText: 'Search products',
                contentPadding: EdgeInsets.zero,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _filter.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _controller.clear();
                          setState(
                              () => _filter = _filter.copyWith(query: ''));
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide(color: context.colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide(color: context.colors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide:
                      BorderSide(color: context.colors.primary, width: 1.6),
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          if (state is CatalogError) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<CatalogCubit>().retry(),
            );
          }
          if (state is! CatalogLoaded) {
            return const SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: ProductGridSkeleton());
          }
          final all = state.products;
          final results = _filter.apply(all);

          return Column(
            children: [
              _quickFilters(context, all),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.lg, 0, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                        style: context.text.bodySmall,
                      ),
                    ),
                    SortMenuButton(
                      value: _filter.sort,
                      onChanged: (s) =>
                          setState(() => _filter = _filter.copyWith(sort: s)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No matches',
                        message: _filter.activeCount > 0
                            ? 'Nothing fits these filters. Try removing one or two.'
                            : 'We could not find "${_filter.query.trim()}". Check the spelling or try a broader term.',
                        actionLabel:
                            _filter.activeCount > 0 ? 'Clear filters' : null,
                        onAction: () =>
                            setState(() => _filter = _filter.cleared()),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(AppSpace.lg,
                            AppSpace.sm, AppSpace.lg, AppSpace.xxl),
                        gridDelegate: productGridDelegate,
                        itemCount: results.length,
                        itemBuilder: (context, i) =>
                            ProductCard(product: results[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _quickFilters(BuildContext context, List<Product> all) {
    final n = _filter.activeCount;
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.lg, vertical: AppSpace.sm),
        children: [
          ActionChip(
            avatar: Icon(Icons.tune_rounded,
                size: 18,
                color: n > 0 ? context.colors.onPrimary : null),
            label: Text(n > 0 ? 'Filters ($n)' : 'Filters'),
            backgroundColor: n > 0 ? context.colors.primary : null,
            side: n > 0 ? BorderSide(color: context.colors.primary) : null,
            labelStyle: n > 0
                ? context.text.labelMedium!
                    .copyWith(color: context.colors.onPrimary)
                : null,
            onPressed: () => _openFilters(all),
          ),
          const SizedBox(width: AppSpace.sm),
          FilterChip(
            label: const Text('On sale'),
            selected: _filter.onSaleOnly,
            onSelected: (v) =>
                setState(() => _filter = _filter.copyWith(onSaleOnly: v)),
          ),
          for (final e in _categoryLabels.entries) ...[
            const SizedBox(width: AppSpace.sm),
            FilterChip(
              label: Text(e.value),
              selected: _filter.categories.contains(e.key),
              onSelected: (_) => _toggleCategory(e.key),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet with every filter. Returns the edited [ProductFilter].
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial, required this.products});
  final ProductFilter initial;
  final List<Product> products;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late ProductFilter _f = widget.initial;
  late final FilterOptions _options = FilterOptions(widget.products);

  Set<String> _toggled(Set<String> set, String v) {
    final next = {...set};
    if (!next.remove(v)) next.add(v);
    return next;
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: AppSpace.xl, bottom: AppSpace.sm),
        child: Text(t, style: context.text.titleSmall),
      );

  Widget _chips(Map<String, String> options, Set<String> selected,
          ValueChanged<String> onTap) =>
      Wrap(
        spacing: AppSpace.sm,
        runSpacing: AppSpace.sm,
        children: [
          for (final e in options.entries)
            FilterChip(
              label: Text(e.value),
              selected: selected.contains(e.key),
              onSelected: (_) => onTap(e.key),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final floor = _options.priceFloor;
    final ceil = _options.priceCeil;
    final range = RangeValues(
        (_f.minPrice ?? floor).clamp(floor, ceil),
        (_f.maxPrice ?? ceil).clamp(floor, ceil));
    final count = _f.apply(widget.products).length;

    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.86),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.sm, 0),
            child: Row(
              children: [
                Expanded(
                    child:
                        Text('Filters', style: context.text.headlineSmall)),
                TextButton(
                  onPressed: () => setState(() => _f = _f.cleared()),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Category'),
                  _chips(
                      const {'woman': 'Women', 'men': 'Men', 'kids': 'Kids'},
                      _f.categories,
                      (v) => setState(() => _f = _f.copyWith(
                          categories: _toggled(_f.categories, v)))),
                  _title('Type'),
                  _chips(
                      const {
                        'Clothes': 'Clothes',
                        'Shoes': 'Shoes',
                        'Accessories': 'Accessories',
                        'New': 'New in',
                      },
                      _f.types,
                      (v) => setState(() =>
                          _f = _f.copyWith(types: _toggled(_f.types, v)))),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpace.xl),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text('Price',
                                style: context.text.titleSmall)),
                        Text(
                            '${money(range.start).replaceAll('.00', '')} - ${money(range.end).replaceAll('.00', '')}',
                            style: context.text.labelMedium),
                      ],
                    ),
                  ),
                  RangeSlider(
                    values: range,
                    min: floor,
                    max: ceil,
                    divisions: ((ceil - floor) / 10).round().clamp(1, 100),
                    onChanged: (v) => setState(() => _f = _f.copyWith(
                          minPrice: () => v.start <= floor ? null : v.start,
                          maxPrice: () => v.end >= ceil ? null : v.end,
                        )),
                  ),
                  Text('Size', style: context.text.titleSmall),
                  const SizedBox(height: AppSpace.sm),
                  _chips(
                      {for (final s in _options.sizes) s: s},
                      _f.sizes,
                      (v) => setState(() =>
                          _f = _f.copyWith(sizes: _toggled(_f.sizes, v)))),
                  _title('Rating'),
                  Wrap(
                    spacing: AppSpace.sm,
                    children: [
                      for (final r in const [0.0, 4.0, 4.5])
                        ChoiceChip(
                          label: Text(r == 0
                              ? 'Any'
                              : '${r.toStringAsFixed(r == 4 ? 0 : 1)}+ stars'),
                          selected: _f.minRating == r,
                          onSelected: (_) => setState(
                              () => _f = _f.copyWith(minRating: r)),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('On sale only'),
                    subtitle: const Text('Show discounted items'),
                    value: _f.onSaleOnly,
                    onChanged: (v) =>
                        setState(() => _f = _f.copyWith(onSaleOnly: v)),
                  ),
                ],
              ),
            ),
          ),
          BottomActionBar(
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _f),
                child: Text(count == 0
                    ? 'No results'
                    : 'Show $count ${count == 1 ? 'result' : 'results'}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
