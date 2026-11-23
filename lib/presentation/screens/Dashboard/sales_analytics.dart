import '../../../data/models.dart';

class DayRevenue {
  const DayRevenue(this.day, this.revenue, this.orders);
  final DateTime day;
  final double revenue;
  final int orders;
}

class ProductSales {
  const ProductSales(this.productId, this.name, this.image, this.units, this.revenue);
  final String productId;
  final String name;
  final String image;
  final int units;
  final double revenue;
}

/// Sales figures for the owner dashboard, computed from the order list.
/// Pure Dart: the same code runs on Firestore orders and on demo orders.
///
/// Revenue = item totals + delivery fees of every order that was not
/// cancelled, counted on the day the order was placed.
class SalesAnalytics {
  SalesAnalytics._({
    required this.days,
    required this.revenue,
    required this.previousRevenue,
    required this.orderCount,
    required this.previousOrderCount,
    required this.units,
    required this.byDay,
    required this.statusCounts,
    required this.topProducts,
    required this.recent,
  });

  final int days;
  final double revenue;

  /// Revenue of the period of the same length right before this one, or
  /// null when there are no orders that far back.
  final double? previousRevenue;
  final int orderCount;
  final int? previousOrderCount;
  final int units;
  final List<DayRevenue> byDay;
  final Map<OrderStatus, int> statusCounts;
  final List<ProductSales> topProducts;
  final List<OrderModel> recent;

  double get averageOrderValue => orderCount == 0 ? 0 : revenue / orderCount;

  /// Percent change of revenue against the previous period.
  double? get revenueChange =>
      previousRevenue == null || previousRevenue == 0
          ? null
          : (revenue - previousRevenue!) / previousRevenue! * 100;

  double? get ordersChange =>
      previousOrderCount == null || previousOrderCount == 0
          ? null
          : (orderCount - previousOrderCount!) / previousOrderCount! * 100;

  int get totalOrdersAnyStatus =>
      statusCounts.values.fold(0, (a, b) => a + b);

  factory SalesAnalytics.from(List<OrderModel> orders,
      {required int days, DateTime? now}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final start = today.subtract(Duration(days: days - 1));
    final prevStart = start.subtract(Duration(days: days));
    DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

    final inPeriod =
        orders.where((o) => !dayOf(o.date).isBefore(start)).toList();
    final previous = orders
        .where((o) =>
            dayOf(o.date).isBefore(start) && !dayOf(o.date).isBefore(prevStart))
        .toList();
    final hasOlder = orders.any((o) => !dayOf(o.date).isAfter(prevStart));

    bool counts(OrderModel o) => o.status != OrderStatus.cancelled;
    final paid = inPeriod.where(counts).toList();

    final revenueByDay = <DateTime, double>{};
    final ordersByDay = <DateTime, int>{};
    for (final o in paid) {
      final d = dayOf(o.date);
      revenueByDay[d] = (revenueByDay[d] ?? 0) + o.total;
      ordersByDay[d] = (ordersByDay[d] ?? 0) + 1;
    }
    final byDay = [
      for (var i = 0; i < days; i++)
        () {
          final d = start.add(Duration(days: i));
          // normalise in case of DST shifts
          final key = DateTime(d.year, d.month, d.day);
          return DayRevenue(key, revenueByDay[key] ?? 0, ordersByDay[key] ?? 0);
        }()
    ];

    final products = <String, ProductSales>{};
    for (final o in paid) {
      for (final i in o.items) {
        final key = i.productId.isNotEmpty ? i.productId : i.name;
        final p = products[key];
        products[key] = ProductSales(key, i.name, i.image,
            (p?.units ?? 0) + i.quantity, (p?.revenue ?? 0) + i.lineTotal);
      }
    }
    final top = products.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final sortedRecent = [...inPeriod]..sort((a, b) => b.date.compareTo(a.date));

    return SalesAnalytics._(
      days: days,
      revenue: paid.fold(0, (a, o) => a + o.total),
      previousRevenue: hasOlder
          ? previous.where(counts).fold<double>(0, (a, o) => a + o.total)
          : null,
      orderCount: paid.length,
      previousOrderCount: hasOlder ? previous.where(counts).length : null,
      units: paid.fold(0, (a, o) => a + o.units),
      byDay: byDay,
      statusCounts: {
        for (final s in OrderStatus.values)
          s: inPeriod.where((o) => o.status == s).length
      },
      topProducts: top.take(5).toList(),
      recent: sortedRecent.take(5).toList(),
    );
  }
}
