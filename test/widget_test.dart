import 'package:depi_final_project/data/demo/demo_data.dart';
import 'package:depi_final_project/data/demo/demo_store_repository.dart';
import 'package:depi_final_project/data/models.dart';
import 'package:depi_final_project/presentation/screens/Dashboard/sales_analytics.dart';
import 'package:depi_final_project/presentation/screens/Search/product_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final products = DemoData.products();

  group('ProductFilter', () {
    test('query matches every word', () {
      final r = const ProductFilter(query: 'kitten heels').apply(products);
      expect(r.map((p) => p.id), ['w07']);
    });

    test('category + on sale + price range', () {
      final r = const ProductFilter(
              categories: {'men'}, onSaleOnly: true, maxPrice: 100)
          .apply(products);
      expect(r, isNotEmpty);
      expect(
          r.every((p) =>
              p.category == 'men' && p.onSale && p.salePrice <= 100),
          isTrue);
    });

    test('sorts by price', () {
      final r =
          const ProductFilter(sort: ProductSort.priceLow).apply(products);
      for (var i = 1; i < r.length; i++) {
        expect(r[i].salePrice >= r[i - 1].salePrice, isTrue);
      }
    });

    test('activeCount ignores query and sort', () {
      const f = ProductFilter(
          query: 'x', sizes: {'M', 'L'}, minRating: 4, onSaleOnly: true);
      expect(f.activeCount, 4);
      expect(f.cleared().activeCount, 0);
      expect(f.cleared().query, 'x');
    });
  });

  group('SalesAnalytics', () {
    OrderModel order(String id, DateTime date, double total,
            {OrderStatus status = OrderStatus.delivered}) =>
        OrderModel(
          id: id,
          userId: 'u',
          customerName: 'c',
          items: [
            OrderItem(
                productId: 'p$id',
                name: 'P$id',
                price: total,
                quantity: 1,
                image: '',
                color: '',
                size: '')
          ],
          itemsTotal: total,
          deliveryFee: 0,
          date: date,
          status: status,
        );

    test('revenue excludes cancelled orders and old orders', () {
      final now = DateTime(2026, 11, 23, 12);
      final a = SalesAnalytics.from([
        order('1', DateTime(2026, 11, 23, 9), 100),
        order('2', DateTime(2026, 11, 22, 9), 50),
        order('3', DateTime(2026, 11, 22, 10), 70,
            status: OrderStatus.cancelled),
        order('4', DateTime(2026, 11, 10, 9), 999),
      ], days: 7, now: now);
      expect(a.revenue, 150);
      expect(a.orderCount, 2);
      expect(a.byDay.length, 7);
      expect(a.byDay.last.revenue, 100);
      expect(a.statusCounts[OrderStatus.cancelled], 1);
      expect(a.topProducts.first.name, 'P1');
    });

    test('demo orders produce a full period', () {
      final a = SalesAnalytics.from(DemoData.orders(), days: 14);
      expect(a.byDay.length, 14);
      expect(a.revenue, greaterThan(0));
      expect(
          a.byDay.fold<double>(0, (s, d) => s + d.revenue), closeTo(a.revenue, 0.01));
    });
  });

  test('demo store: add to cart then place order', () async {
    final repo = DemoStoreRepository();
    final p = products.first;
    await repo.addToCart(p, size: p.sizes.first, color: p.colors.first);
    await repo.addToCart(p, size: p.sizes.first, color: p.colors.first);
    final cart = await repo.loadCart();
    expect(cart.single.quantity, 2);
    final o = await repo.placeOrder(
        address: DemoData.addresses.first,
        delivery: DeliveryOption.all.first,
        paymentLabel: 'Card ending 4242');
    expect(o.itemsTotal, closeTo(p.salePrice * 2, 0.001));
    expect(await repo.loadCart(), isEmpty);
    final mine = await repo.watchMyOrders().first;
    expect(mine.first.id, o.id);
  });
}
