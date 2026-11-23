import 'dart:math';

import '../../presentation/models/product_model.dart';
import '../models.dart';

/// Demo catalogue for `--dart-define=DEMO=true`.
///
/// Photos are the ones shipped in `assets/images/`; products without a photo
/// use an `art:<icon>:<hex>` tile that is drawn in Flutter.
class DemoData {
  DemoData._();

  static const userId = 'demo-user';
  static const profile = UserProfile(
    uid: userId,
    name: 'Sara Mitchell',
    email: 'sara.mitchell@example.com',
    phone: '+1 415 555 0134',
  );

  static const addresses = [
    Address(
      id: 'addr-1',
      name: 'Sara Mitchell',
      line: '48 Linden Street, Apt 5B\nSan Francisco, CA 94117, United States',
      phone: '+1 415 555 0134',
      isDefault: true,
    ),
    Address(
      id: 'addr-2',
      name: 'Sara Mitchell (Office)',
      line: '900 Harbor Avenue, Floor 3\nOakland, CA 94607, United States',
      phone: '+1 415 555 0134',
    ),
    Address(
      id: 'addr-3',
      name: 'Daniel Mitchell',
      line: '17 Maple Court\nPortland, OR 97205, United States',
      phone: '+1 503 555 0178',
    ),
  ];

  static const _clothes = ['XS', 'S', 'M', 'L', 'XL'];
  static const _shoesW = ['36', '37', '38', '39', '40'];
  static const _shoesM = ['40', '41', '42', '43', '44'];
  static const _kids = ['4Y', '6Y', '8Y', '10Y'];
  static const _kidsShoes = ['28', '30', '32', '34'];
  static const _one = ['One size'];

  static String _img(String f) => 'assets/images/$f';

  static Product _p(
    String id,
    String name,
    String category,
    String sub,
    double price,
    String image,
    List<String> sizes,
    List<String> colors,
    String description, {
    int discount = 0,
    int daysOld = 30,
  }) =>
      Product(
        id: id,
        name: name,
        description: description,
        colors: colors,
        discount: discount,
        category: category,
        price: price,
        images: [image],
        sid: 'demo-store',
        sizes: sizes,
        subcateg: sub,
        createdAt: DateTime.now().subtract(Duration(days: daysOld)),
      );

  static final List<Product> _baseProducts = [
    // ------------------------------------------------------------- Women
    _p('w01', 'Crimson Tailored Suit', 'woman', 'Clothes', 189, _img('11.jpg'),
        _clothes, ['Red', 'Black'],
        'A relaxed two-piece suit in a fluid crepe. Wide-leg trousers with a high waist and a soft-shouldered blazer that works together or apart.',
        discount: 20, daysOld: 40),
    _p('w02', 'Sand Linen Blazer Set', 'woman', 'New', 164, _img('12.jpg'),
        _clothes, ['Beige', 'Brown'],
        'Lightweight linen-blend blazer with matching pleated trousers. Breathable, softly structured and made for warm days.',
        daysOld: 3),
    _p('w03', 'Utility Jumpsuit', 'woman', 'Clothes', 118, _img('13.jpg'),
        _clothes, ['Khaki', 'Black'],
        'Cotton-twill jumpsuit with a belted waist, patch pockets and a concealed zip. An easy one-piece outfit.',
        discount: 15, daysOld: 55),
    _p('w04', 'Sunshine Jogger Set', 'woman', 'New', 79, _img('1.jpeg'),
        _clothes, ['Yellow', 'White'],
        'Cropped hoodie and matching joggers in brushed fleece. Soft inside, bright outside.',
        daysOld: 5),
    _p('w05', 'Tangerine Oversized Hoodie', 'woman', 'New', 68, _img('4.jpg'),
        _clothes, ['Orange', 'White'],
        'Heavyweight cotton hoodie with dropped shoulders and a roomy hood. Cut long for an oversized fit.',
        discount: 10, daysOld: 8),
    _p('w06', 'Scarlet Satin Shirt', 'woman', 'Clothes', 72, _img('5.jpg'),
        _clothes, ['Red', 'Black', 'White'],
        'Satin shirt with a sharp collar and covered placket. Tuck it in or wear it open over a tee.',
        daysOld: 70),
    _p('w07', 'Slingback Kitten Heels', 'woman', 'Shoes', 96,
        _img('shoes_women.jpg'), _shoesW, ['Black', 'Beige'],
        'Pointed-toe slingbacks with a 4 cm kitten heel and an elasticated strap for all-day comfort.',
        discount: 25, daysOld: 62),
    _p('w08', 'Layered Chain Necklace', 'woman', 'Accessories', 42,
        _img('accessories_women.jpg'), _one, ['Gold'],
        'Three gold-tone chains of different weights on a single clasp, finished with a coin pendant.',
        daysOld: 20),
    _p('w09', 'Everyday Canvas Tote', 'woman', 'Accessories', 38,
        'art:bag:C98B6B', _one, ['Beige', 'Black'],
        'Sturdy cotton-canvas tote with an inner zip pocket and long handles. Fits a 15-inch laptop.',
        daysOld: 33),
    _p('w10', 'Leather Ankle Boots', 'woman', 'Shoes', 142, 'art:boot:6B4A3A',
        _shoesW, ['Brown', 'Black'],
        'Smooth leather ankle boots with a stacked heel, side zip and cushioned insole.',
        discount: 30, daysOld: 80),
    // --------------------------------------------------------------- Men
    _p('m01', 'Rust Camp-Collar Shirt', 'men', 'New', 64, _img('10.jpg'),
        _clothes, ['Brown', 'Beige'],
        'Short-sleeved shirt with an open camp collar in a drapey viscose blend. Relaxed through the body.',
        daysOld: 2),
    _p('m02', 'Amber Workwear Suit', 'men', 'Clothes', 176, _img('2.jpg'),
        _clothes, ['Yellow', 'Navy'],
        'Chore jacket and straight-leg trousers in garment-dyed cotton twill. Sold as a set.',
        discount: 20, daysOld: 45),
    _p('m03', 'Yellow Chore Jacket', 'men', 'New', 98, _img('3.jpg'),
        _clothes, ['Yellow', 'Khaki'],
        'Unlined cotton chore jacket with three patch pockets and corozo buttons. Layers over a tee or knit.',
        daysOld: 6),
    _p('m04', 'Navy Cable Knit Sweater', 'men', 'Clothes', 84,
        _img('mens_clothes.jpg'), _clothes, ['Navy', 'Grey'],
        'Chunky cable-knit crew neck in a soft wool blend with ribbed cuffs and hem.',
        discount: 15, daysOld: 50),
    _p('m05', 'Retro Court Sneakers', 'men', 'Shoes', 112,
        _img('mens_shoes.jpg'), _shoesM, ['Teal', 'White'],
        'Mid-top court sneakers with suede overlays, a padded collar and a grippy cupsole.',
        daysOld: 12),
    _p('m06', 'Everyday Carry Wallet Set', 'men', 'Accessories', 58,
        _img('mens_accesories.jpg'), _one, ['Brown'],
        'Full-grain leather bifold wallet with six card slots, boxed with a matching key fob.',
        discount: 10, daysOld: 36),
    _p('m07', 'Resort Print Shirt', 'men', 'Clothes', 54, _img('8.jpeg'),
        _clothes, ['Blue', 'White', 'Green'],
        'Lightweight printed shirt with a relaxed fit and a straight hem. Made to be worn untucked.',
        daysOld: 66),
    _p('m08', 'Suede Chelsea Boots', 'men', 'Shoes', 148, 'art:boot:8A6A4F',
        _shoesM, ['Brown', 'Black'],
        'Soft suede Chelsea boots with elastic side panels, a pull tab and a flexible rubber sole.',
        discount: 25, daysOld: 75),
    _p('m09', 'Aviator Sunglasses', 'men', 'Accessories', 46,
        'art:glasses:3E5C76', _one, ['Black', 'Gold'],
        'Classic metal-frame aviators with UV400 lenses. Comes with a hard case and cloth.',
        daysOld: 15),
    _p('m10', 'Slim Stretch Chinos', 'men', 'Clothes', 62, 'art:pants:7A8471',
        _clothes, ['Khaki', 'Navy', 'Black'],
        'Slim-fit chinos in stretch cotton twill. Sits just below the waist with a tapered leg.',
        daysOld: 28),
    // -------------------------------------------------------------- Kids
    _p('k01', 'Wool Blend Mini Coat', 'kids', 'Clothes', 74,
        _img('kids_clothes.jpg'), _kids, ['Grey', 'Navy'],
        'Double-breasted coat in a warm wool blend, fully lined, with deep front pockets.',
        discount: 20, daysOld: 48),
    _p('k02', 'Chunky Trail Sneakers', 'kids', 'Shoes', 49,
        _img('kids_shoes.jpg'), _kidsShoes, ['Grey', 'Yellow'],
        'Lightweight sneakers with a cushioned chunky sole and easy hook-and-loop straps.',
        daysOld: 10),
    _p('k03', 'Playground Sweatshirt', 'kids', 'New', 32,
        _img('kids_wear.jpg'), _kids, ['Pink', 'Brown', 'White'],
        'Soft loopback cotton sweatshirt with a playful print. Washes well, wears even better.',
        daysOld: 4),
    _p('k04', 'Charm Ring Set', 'kids', 'Accessories', 14,
        _img('kids_accesories.jpg'), _one, ['Gold', 'Pink'],
        'Set of six adjustable rings with hearts, paws and pearls. Nickel free.',
        daysOld: 22),
    _p('k05', 'Rainbow School Backpack', 'kids', 'Accessories', 36,
        'art:backpack:5B7BD5', _one, ['Blue', 'Pink'],
        'Padded backpack with two compartments, a bottle pocket and reflective trims.',
        discount: 15, daysOld: 58),
    _p('k06', 'Dino Graphic Tee', 'kids', 'New', 18, 'art:tee:4FA38A', _kids,
        ['Green', 'White'],
        'Organic cotton tee with a hand-drawn dinosaur print and a ribbed neckline.',
        daysOld: 7),
    _p('k07', 'Canvas Slip-Ons', 'kids', 'Shoes', 28, 'art:shoe:D98C5F',
        _kidsShoes, ['Orange', 'Navy'],
        'Easy slip-on canvas shoes with elastic gussets and a flexible rubber sole.',
        discount: 10, daysOld: 41),
    _p('k08', 'Denim Dungarees', 'kids', 'Clothes', 39, 'art:pants:4C6A92',
        _kids, ['Blue'],
        'Soft-washed denim dungarees with adjustable straps and a front bib pocket.',
        daysOld: 30),
  ];

  static const _firstNames = [
    'Emma', 'Liam', 'Olivia', 'Noah', 'Ava', 'Ethan', 'Mia', 'Lucas',
    'Hannah', 'James', 'Chloe', 'Ben', 'Grace', 'Owen', 'Ruby', 'Leo',
    'Nora', 'Adam', 'Ella', 'Sam', 'Lily', 'Jack', 'Zoe', 'Max',
  ];

  static const _reviewTexts = <int, List<String>>{
    5: [
      'Exactly as pictured and the quality is better than I expected for the price.',
      'Fits true to size and feels really well made. Already wore it three times this week.',
      'Arrived two days early, nicely packed. Would buy again.',
      'Great fabric and the colour is even nicer in person.',
      'Bought it as a gift and it was a hit. Very happy.',
    ],
    4: [
      'Really nice, just runs a little large. Consider sizing down.',
      'Good quality overall. The colour is slightly darker than in the photo.',
      'Comfortable and looks great. Delivery took a day longer than promised.',
      'Happy with it. Stitching is neat, material feels sturdy.',
    ],
    3: [
      'It is fine for the price but the material is thinner than I hoped.',
      'Looks good, fit is a bit off for me. Kept it anyway.',
    ],
    2: [
      'Sizing was off and I had to exchange it. The exchange itself was easy.',
    ],
  };

  static final Map<String, List<Review>> reviews = _buildReviews();

  static Map<String, List<Review>> _buildReviews() {
    final rnd = Random(11);
    final now = DateTime.now();
    final out = <String, List<Review>>{};
    for (final p in _baseProducts) {
      final count = 4 + rnd.nextInt(6);
      final list = <Review>[];
      for (var i = 0; i < count; i++) {
        final roll = rnd.nextInt(100);
        final rating = roll < 55 ? 5 : roll < 85 ? 4 : roll < 95 ? 3 : 2;
        final texts = _reviewTexts[rating]!;
        list.add(Review(
          id: '${p.id}-r$i',
          productId: p.id,
          author: _firstNames[rnd.nextInt(_firstNames.length)],
          rating: rating,
          text: texts[rnd.nextInt(texts.length)],
          date: now.subtract(Duration(days: 1 + rnd.nextInt(60), hours: i)),
        ));
      }
      list.sort((a, b) => b.date.compareTo(a.date));
      out[p.id] = list;
    }
    return out;
  }

  /// Catalogue with rating / review count derived from the demo reviews.
  static List<Product> products() => _baseProducts.map(withRating).toList();

  static Product withRating(Product p) {
    final list = reviews[p.id] ?? const <Review>[];
    final avg = list.isEmpty
        ? 0.0
        : list.fold<int>(0, (a, r) => a + r.rating) / list.length;
    return Product(
      id: p.id,
      name: p.name,
      description: p.description,
      colors: p.colors,
      discount: p.discount,
      category: p.category,
      price: p.price,
      images: p.images,
      sid: p.sid,
      sizes: p.sizes,
      subcateg: p.subcateg,
      rating: double.parse(avg.toStringAsFixed(1)),
      reviewCount: list.length,
      createdAt: p.createdAt,
    );
  }

  static OrderItem _item(Product p, int qty, Random rnd) => OrderItem(
        productId: p.id,
        name: p.name,
        price: p.salePrice,
        quantity: qty,
        image: p.image,
        color: p.colors[rnd.nextInt(p.colors.length)],
        size: p.sizes[rnd.nextInt(p.sizes.length)],
      );

  /// 30 days of store orders (other customers + the demo customer), built
  /// relative to today so the dashboard always shows a current period.
  static List<OrderModel> orders() {
    final rnd = Random(7);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = <OrderModel>[];
    var n = 4100;

    OrderModel make(String uid, String customer, DateTime date,
        OrderStatus status, List<OrderItem> items, DeliveryOption d) {
      n += 1 + rnd.nextInt(3);
      return OrderModel(
        id: 'FS-10$n',
        userId: uid,
        customerName: customer,
        items: items,
        itemsTotal: items.fold(0, (a, i) => a + i.lineTotal),
        deliveryFee: d.fee,
        date: date,
        status: status,
        deliveryMethod: d.label,
        paymentLabel: 'Card ending 4242',
        addressName: customer,
        addressLine: addresses.first.line,
      );
    }

    for (var daysAgo = 29; daysAgo >= 0; daysAgo--) {
      final day = today.subtract(Duration(days: daysAgo));
      final weekend = day.weekday >= 6;
      // gentle upward trend + busier weekends
      final count = 1 + rnd.nextInt(3) + (weekend ? 1 : 0) + (daysAgo < 10 ? 1 : 0);
      for (var i = 0; i < count; i++) {
        final date = day.add(Duration(hours: 9 + rnd.nextInt(11), minutes: rnd.nextInt(60)));
        if (date.isAfter(now)) continue;
        final lines = 1 + rnd.nextInt(3);
        final items = <OrderItem>[];
        for (var l = 0; l < lines; l++) {
          // weight the catalogue so a few products are clear best sellers
          final idx = rnd.nextInt(100) < 45
              ? rnd.nextInt(6) * 2 % _baseProducts.length
              : rnd.nextInt(_baseProducts.length);
          items.add(_item(_baseProducts[idx], 1 + (rnd.nextInt(5) == 0 ? 1 : 0), rnd));
        }
        final OrderStatus status;
        if (daysAgo > 5) {
          status = rnd.nextInt(100) < 8 ? OrderStatus.cancelled : OrderStatus.delivered;
        } else if (daysAgo > 1) {
          status = rnd.nextInt(100) < 70 ? OrderStatus.shipped : OrderStatus.delivered;
        } else {
          status = rnd.nextInt(100) < 75 ? OrderStatus.processing : OrderStatus.shipped;
        }
        final name = '${_firstNames[rnd.nextInt(_firstNames.length)]} '
            '${String.fromCharCode(65 + rnd.nextInt(26))}.';
        out.add(make('cust-${rnd.nextInt(400)}', name, date, status, items,
            DeliveryOption.all[rnd.nextInt(100) < 65 ? 0 : 1 + rnd.nextInt(2)]));
      }
    }

    // The signed-in demo customer's own history.
    Product byId(String id) => _baseProducts.firstWhere((p) => p.id == id);
    OrderModel mine(int daysAgo, int hour, OrderStatus s, List<OrderItem> items,
            DeliveryOption d) =>
        make(userId, profile.name,
            today.subtract(Duration(days: daysAgo)).add(Duration(hours: hour, minutes: 24)),
            s, items, d);
    out.addAll([
      mine(2, 11, OrderStatus.shipped,
          [_item(byId('w02'), 1, rnd), _item(byId('w08'), 1, rnd)],
          DeliveryOption.all[1]),
      mine(9, 15, OrderStatus.delivered,
          [_item(byId('w05'), 1, rnd), _item(byId('k03'), 2, rnd)],
          DeliveryOption.all[0]),
      mine(16, 10, OrderStatus.cancelled, [_item(byId('w10'), 1, rnd)],
          DeliveryOption.all[0]),
      mine(24, 18, OrderStatus.delivered,
          [_item(byId('m04'), 1, rnd), _item(byId('m06'), 1, rnd), _item(byId('w07'), 1, rnd)],
          DeliveryOption.all[0]),
    ]);

    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  static const initialFavorites = {'w02', 'm05', 'w07', 'k01', 'm03'};
}
