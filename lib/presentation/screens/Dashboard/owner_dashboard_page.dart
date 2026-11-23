import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models.dart';
import '../../../data/store_repository.dart';
import 'sales_analytics.dart';

/// Store-owner dashboard: revenue by day, KPIs, orders by status, top
/// products and the latest orders, all computed from the orders stream.
class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  late Stream<List<OrderModel>> _stream = Repo.store.watchAllOrders();
  int _days = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store dashboard')),
      body: StreamBuilder<List<OrderModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              message:
                  'We could not load the store orders. Owner access to orders is required.',
              onRetry: () =>
                  setState(() => _stream = Repo.store.watchAllOrders()),
            );
          }
          if (!snapshot.hasData) return const _DashboardSkeleton();
          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.insights_rounded,
              title: 'No sales yet',
              message:
                  'Your revenue, top products and order status will appear here after the first order.',
            );
          }
          final a = SalesAnalytics.from(orders, days: _days);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.lg, AppSpace.sm, AppSpace.lg, AppSpace.xxl),
            children: [
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 7, label: Text('7 days')),
                  ButtonSegment(value: 14, label: Text('14 days')),
                  ButtonSegment(value: 30, label: Text('30 days')),
                ],
                selected: {_days},
                onSelectionChanged: (s) => setState(() => _days = s.first),
              ),
              const SizedBox(height: AppSpace.lg),
              _kpis(context, a),
              const SizedBox(height: AppSpace.md),
              _revenueCard(context, a),
              const SizedBox(height: AppSpace.md),
              _statusCard(context, a),
              const SizedBox(height: AppSpace.md),
              _topProducts(context, a),
              const SizedBox(height: AppSpace.md),
              _recent(context, a),
            ],
          );
        },
      ),
    );
  }

  Widget _kpis(BuildContext context, SalesAnalytics a) {
    Widget tile(String label, String value, IconData icon, {double? change}) =>
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(AppSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: context.palette.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: context.text.titleLarge!.copyWith(fontSize: 22)),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 18,
                  child: change == null
                      ? Text('Last ${a.days} days',
                          style: context.text.bodySmall)
                      : _Delta(change),
                ),
              ],
            ),
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            tile('Revenue', money(a.revenue), Icons.payments_outlined,
                change: a.revenueChange),
            const SizedBox(width: AppSpace.md),
            tile('Orders', '${a.orderCount}', Icons.receipt_long_outlined,
                change: a.ordersChange),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            tile('Avg. order value', money(a.averageOrderValue),
                Icons.shopping_basket_outlined),
            const SizedBox(width: AppSpace.md),
            tile('Units sold', '${a.units}', Icons.checkroom_rounded),
          ],
        ),
      ],
    );
  }

  Widget _revenueCard(BuildContext context, SalesAnalytics a) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue by day', style: context.text.titleMedium),
          const SizedBox(height: 2),
          Text('Tap a bar to see the day. Cancelled orders are excluded.',
              style: context.text.bodySmall),
          const SizedBox(height: AppSpace.lg),
          RevenueBarChart(data: a.byDay),
        ],
      ),
    );
  }

  Widget _statusCard(BuildContext context, SalesAnalytics a) {
    final total = a.totalOrdersAnyStatus;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Orders by status', style: context.text.titleMedium),
          const SizedBox(height: AppSpace.lg),
          Row(
            children: [
              SizedBox(
                width: 124,
                height: 124,
                child: CustomPaint(
                  painter: _DonutPainter(
                    values: [
                      for (final s in OrderStatus.values)
                        (a.statusCounts[s] ?? 0).toDouble()
                    ],
                    colors: [
                      for (final s in OrderStatus.values)
                        OrderStatusChip.colorOf(context, s)
                    ],
                    track: context.palette.surfaceAlt,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$total',
                            style: context.text.titleLarge!
                                .copyWith(fontSize: 22)),
                        Text('orders', style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.xl),
              Expanded(
                child: Column(
                  children: [
                    for (final s in OrderStatus.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: OrderStatusChip.colorOf(context, s),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(s.label,
                                    style: context.text.bodyMedium)),
                            Text('${a.statusCounts[s] ?? 0}',
                                style: context.text.titleSmall),
                            SizedBox(
                              width: 44,
                              child: Text(
                                total == 0
                                    ? ''
                                    : '${((a.statusCounts[s] ?? 0) / total * 100).round()}%',
                                textAlign: TextAlign.end,
                                style: context.text.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topProducts(BuildContext context, SalesAnalytics a) {
    final maxRevenue =
        a.topProducts.isEmpty ? 1.0 : a.topProducts.first.revenue;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top products', style: context.text.titleMedium),
          const SizedBox(height: 2),
          Text('By revenue in the last ${a.days} days',
              style: context.text.bodySmall),
          const SizedBox(height: AppSpace.md),
          if (a.topProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
              child: Text('No sales in this period.',
                  style: context.text.bodyMedium),
            ),
          for (var i = 0; i < a.topProducts.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    child: Text('${i + 1}', style: context.text.labelMedium),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: SizedBox(
                        width: 40,
                        height: 48,
                        child: ProductImage(a.topProducts[i].image)),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(a.topProducts[i].name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleSmall),
                            ),
                            const SizedBox(width: 8),
                            Text(money(a.topProducts[i].revenue),
                                style: context.text.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                                child: LinearProgressIndicator(
                                  value:
                                      a.topProducts[i].revenue / maxRevenue,
                                  minHeight: 6,
                                  backgroundColor: context.palette.surfaceAlt,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 64,
                              child: Text('${a.topProducts[i].units} sold',
                                  textAlign: TextAlign.end,
                                  style: context.text.bodySmall),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _recent(BuildContext context, SalesAnalytics a) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Latest orders', style: context.text.titleMedium),
          const SizedBox(height: AppSpace.sm),
          for (final o in a.recent)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            o.customerName.isEmpty
                                ? 'Order ${o.number}'
                                : o.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleSmall),
                        Text('${o.number}  ·  ${dateTimeLabel(o.date)}',
                            style: context.text.bodySmall),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(money(o.total), style: context.text.titleSmall),
                      const SizedBox(height: 4),
                      OrderStatusChip(o.status),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta(this.change);
  final double change;

  @override
  Widget build(BuildContext context) {
    final up = change >= 0;
    final c = up ? context.palette.success : context.colors.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 16, color: c),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            '${up ? '+' : ''}${change.toStringAsFixed(0)}% vs prev.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall!
                .copyWith(color: c, letterSpacing: 0),
          ),
        ),
      ],
    );
  }
}

/// Bar chart of daily revenue with gridlines and a tappable highlight.
class RevenueBarChart extends StatefulWidget {
  const RevenueBarChart({super.key, required this.data});
  final List<DayRevenue> data;

  @override
  State<RevenueBarChart> createState() => _RevenueBarChartState();
}

class _RevenueBarChartState extends State<RevenueBarChart> {
  int? _selected;

  @override
  void didUpdateWidget(RevenueBarChart old) {
    super.didUpdateWidget(old);
    if (old.data.length != widget.data.length) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final best = data.isEmpty
        ? 0
        : List.generate(data.length, (i) => i)
            .reduce((a, b) => data[a].revenue >= data[b].revenue ? a : b);
    final sel = _selected ?? best;
    final d = data.isEmpty ? null : data[sel];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (d != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(money(d.revenue), style: context.text.titleLarge),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${dayMonth(d.day)}  ·  ${d.orders} ${d.orders == 1 ? 'order' : 'orders'}'
                  '${_selected == null ? '  ·  best day' : ''}',
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        const SizedBox(height: AppSpace.md),
        SizedBox(
          height: 180,
          child: LayoutBuilder(builder: (context, c) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (t) {
                const left = _BarPainter.axisWidth;
                final w = (c.maxWidth - left) / data.length;
                final i = ((t.localPosition.dx - left) / w).floor();
                if (i >= 0 && i < data.length) setState(() => _selected = i);
              },
              child: TweenAnimationBuilder<double>(
                key: ValueKey(data.length),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, t, _) => CustomPaint(
                  size: Size(c.maxWidth, 180),
                  painter: _BarPainter(
                    data: data,
                    selected: sel,
                    progress: t,
                    bar: context.colors.primary.withValues(alpha: 0.35),
                    barSelected: context.colors.primary,
                    grid: context.colors.outline,
                    label: context.text.labelSmall!.copyWith(
                        color: context.palette.textMuted,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.data,
    required this.selected,
    required this.progress,
    required this.bar,
    required this.barSelected,
    required this.grid,
    required this.label,
  });
  final List<DayRevenue> data;
  final int selected;
  final double progress;
  final Color bar;
  final Color barSelected;
  final Color grid;
  final TextStyle label;

  static const axisWidth = 38.0;
  static const _bottom = 20.0;

  static double niceMax(double v) {
    if (v <= 0) return 100;
    final exp = math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
    for (final m in [1, 2, 2.5, 5, 10]) {
      if (v <= m * exp) return m * exp;
    }
    return 10 * exp;
  }

  void _text(Canvas canvas, String s, Offset at, {bool right = false, bool center = false}) {
    final tp = TextPainter(
        text: TextSpan(text: s, style: label),
        textDirection: TextDirection.ltr)
      ..layout();
    var dx = at.dx;
    if (right) dx -= tp.width;
    if (center) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, at.dy));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final chartH = size.height - _bottom - 6;
    const top = 6.0;
    final maxV = niceMax(data.map((d) => d.revenue).reduce(math.max));
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = top + chartH - chartH * i / 4;
      canvas.drawLine(Offset(axisWidth, y), Offset(size.width, y), gridPaint);
      _text(canvas, moneyCompact(maxV * i / 4), Offset(axisWidth - 6, y - 7),
          right: true);
    }

    final slot = (size.width - axisWidth) / data.length;
    final barW = math.min(slot * 0.62, 22.0);
    final every = data.length <= 7 ? 1 : data.length <= 14 ? 2 : 5;
    for (var i = 0; i < data.length; i++) {
      final cx = axisWidth + slot * (i + 0.5);
      final h = chartH * (data[i].revenue / maxV) * progress;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - barW / 2, top + chartH - h, barW, h),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      );
      canvas.drawRRect(
          rect, Paint()..color = i == selected ? barSelected : bar);
      if ((data.length - 1 - i) % every == 0) {
        _text(canvas, '${data[i].day.month}/${data[i].day.day}',
            Offset(cx, size.height - _bottom + 6),
            center: true);
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.data != data ||
      old.selected != selected ||
      old.progress != progress ||
      old.barSelected != barSelected;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(
      {required this.values, required this.colors, required this.track});
  final List<double> values;
  final List<Color> colors;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke,
        size.height - stroke);
    final total = values.fold<double>(0, (a, b) => a + b);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (total == 0) return;
    const gap = 0.05;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      if (values[i] == 0) continue;
      final sweep = values[i] / total * math.pi * 2;
      canvas.drawArc(rect, start + gap / 2, math.max(sweep - gap, 0.01), false,
          paint..color = colors[i]);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.values.toString() != values.toString() || old.track != track;
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          Skeleton(height: 44, radius: AppRadius.pill),
          SizedBox(height: AppSpace.lg),
          Row(children: [
            Expanded(child: Skeleton(height: 96, radius: AppRadius.lg)),
            SizedBox(width: AppSpace.md),
            Expanded(child: Skeleton(height: 96, radius: AppRadius.lg)),
          ]),
          SizedBox(height: AppSpace.md),
          Skeleton(height: 280, radius: AppRadius.lg),
          SizedBox(height: AppSpace.md),
          Skeleton(height: 180, radius: AppRadius.lg),
        ],
      );
}
