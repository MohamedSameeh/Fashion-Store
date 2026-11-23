import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../format.dart';
import '../theme/app_tokens.dart';

// ---------------------------------------------------------------- brand mark

/// The store logo, drawn in Flutter so it works on light and dark surfaces.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 22, this.showIcon = true});
  final double size;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Container(
            width: size * 1.35,
            height: size * 1.35,
            decoration: BoxDecoration(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(size * 0.36),
            ),
            child: Icon(Icons.checkroom_rounded,
                color: Colors.white, size: size * 0.95),
          ),
          SizedBox(width: size * 0.45),
        ],
        Text(
          'FASHIONSHOP',
          style: context.text.titleMedium!.copyWith(
            fontSize: size * 0.78,
            fontWeight: FontWeight.w700,
            letterSpacing: size * 0.16,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ product images

/// Shows a product image from any supported source:
/// `assets/...`, `art:<label>:<hex>` (drawn tile) or an http(s) URL.
class ProductImage extends StatelessWidget {
  const ProductImage(this.source,
      {super.key,
      this.fit = BoxFit.cover,
      this.alignment = Alignment.topCenter});
  final String source;
  final Alignment alignment;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('art:')) {
      final parts = source.split(':');
      return ProductArt(
        label: parts[1],
        color: Color(int.parse('FF${parts.length > 2 ? parts[2] : 'B0A090'}',
            radix: 16)),
      );
    }
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => const _ImageFallback(),
      );
    }
    if (source.isEmpty) return const _ImageFallback();
    return CachedNetworkImage(
      imageUrl: source,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => const Skeleton(radius: 0),
      errorWidget: (_, __, ___) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: context.palette.surfaceAlt,
        child: Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: context.palette.textMuted),
        ),
      );
}

/// A typographic colour-block tile for catalogue items without a photo.
class ProductArt extends StatelessWidget {
  const ProductArt({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final light = Color.lerp(color, Colors.white, 0.45)!;
    final deep = Color.lerp(color, Colors.black, 0.18)!;
    final serif = Theme.of(context).textTheme.headlineMedium!;
    return LayoutBuilder(builder: (context, c) {
      final s = c.biggest.shortestSide;
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [light, color, deep],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -s * 0.25,
              top: -s * 0.2,
              child: _Blob(size: s * 0.9, opacity: 0.14),
            ),
            Positioned(
              left: -s * 0.3,
              bottom: -s * 0.35,
              child: _Blob(size: s * 0.95, opacity: 0.09),
            ),
            if (s > 70)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: s * 0.1),
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label.replaceFirst(' ', '\n'),
                            textAlign: TextAlign.center,
                            style: serif.copyWith(
                              color: Colors.white,
                              fontSize: s * 0.17,
                              height: 1.05,
                            ),
                          ),
                        ),
                        SizedBox(height: s * 0.05),
                        Container(
                            width: s * 0.16, height: 1.5, color: Colors.white70),
                        SizedBox(height: s * 0.045),
                        Text(
                          'FASHIONSHOP',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: (s * 0.048).clamp(6.0, 14.0),
                            fontWeight: FontWeight.w600,
                            letterSpacing: s * 0.016,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Icon(Icons.checkroom_rounded,
                    size: s * 0.5, color: Colors.white),
              ),
          ],
        ),
      );
    });
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.opacity});
  final double size;
  final double opacity;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      );
}

// ------------------------------------------------------------------ skeleton

/// Shimmering placeholder block used by all loading states.
class Skeleton extends StatefulWidget {
  const Skeleton(
      {super.key, this.width, this.height, this.radius = AppRadius.md});
  final double? width;
  final double? height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value * 3 - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(t - 1, 0),
              end: Alignment(t + 1, 0),
              colors: [p.skeleton, p.skeletonHighlight, p.skeleton],
            ),
          ),
        );
      },
    );
  }
}

/// Grid of product-card skeletons.
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpace.lg),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: productGridDelegate,
      itemCount: count,
      itemBuilder: (_, __) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Skeleton(radius: AppRadius.lg)),
          SizedBox(height: 10),
          Skeleton(width: 120, height: 14),
          SizedBox(height: 8),
          Skeleton(width: 70, height: 14),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}

const productGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: AppSpace.lg,
  crossAxisSpacing: AppSpace.md,
  childAspectRatio: 0.58,
);

/// List of row skeletons (orders, bag, reviews).
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.count = 4, this.height = 108});
  final int count;
  final double height;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.all(AppSpace.lg),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpace.md),
        itemBuilder: (_, __) =>
            Skeleton(height: height, radius: AppRadius.lg),
      );
}

// ------------------------------------------------------------ empty / error

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: context.colors.primary),
            ),
            const SizedBox(height: AppSpace.xl),
            Text(title,
                style: context.text.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium!
                  .copyWith(color: context.palette.textMuted),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpace.xxl),
              FilledButton(
                onPressed: onAction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Something went wrong',
        message: message,
        actionLabel: onRetry == null ? null : 'Try again',
        onAction: onRetry,
      );
}

// ------------------------------------------------------------- small pieces

class SectionHeader extends StatelessWidget {
  const SectionHeader(
      {super.key, required this.title, this.subtitle, this.onViewAll});
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.xxl, 4, AppSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.headlineMedium),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!, style: context.text.bodySmall),
                  ),
              ],
            ),
          ),
          if (onViewAll != null)
            TextButton(onPressed: onViewAll, child: const Text('View all'))
          else
            const SizedBox(width: AppSpace.md),
        ],
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  const RatingStars(this.rating, {super.key, this.size = 16});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final icon = rating >= i + 0.75
            ? Icons.star_rounded
            : rating >= i + 0.25
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;
        return Icon(icon, size: size, color: context.palette.star);
      }),
    );
  }
}

/// Compact "4.6 (12)" rating label.
class RatingLabel extends StatelessWidget {
  const RatingLabel({super.key, required this.rating, required this.count});
  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 15, color: context.palette.star),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1), style: context.text.labelMedium),
        Text(' ($count)', style: context.text.bodySmall),
      ],
    );
  }
}

class PriceText extends StatelessWidget {
  const PriceText(
      {super.key,
      required this.price,
      required this.salePrice,
      this.large = false});
  final double price;
  final double salePrice;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final onSale = salePrice < price;
    final main = (large ? context.text.headlineSmall : context.text.titleSmall)!
        .copyWith(
            fontFamily: context.text.titleSmall!.fontFamily,
            fontWeight: FontWeight.w700,
            color: onSale ? context.colors.primary : null);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(money(salePrice), style: main),
        if (onSale) ...[
          const SizedBox(width: 6),
          Text(
            money(price),
            style: (large ? context.text.bodyLarge : context.text.bodySmall)!
                .copyWith(
                    color: context.palette.textMuted,
                    decoration: TextDecoration.lineThrough),
          ),
        ],
      ],
    );
  }
}

class DiscountBadge extends StatelessWidget {
  const DiscountBadge(this.discount, {super.key});
  final int discount;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text('-$discount%',
            style: context.text.labelSmall!.copyWith(color: Colors.white)),
      );
}

class TagBadge extends StatelessWidget {
  const TagBadge(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(label.toUpperCase(),
            style: context.text.labelSmall!.copyWith(color: Colors.white)),
      );
}

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip(this.status, {super.key});
  final OrderStatus status;

  static Color colorOf(BuildContext context, OrderStatus s) => switch (s) {
        OrderStatus.processing => context.palette.warning,
        OrderStatus.shipped => context.palette.info,
        OrderStatus.delivered => context.palette.success,
        OrderStatus.cancelled => context.palette.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final c = colorOf(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(status.label,
              style: context.text.labelMedium!.copyWith(color: c)),
        ],
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper(
      {super.key,
      required this.quantity,
      required this.onMinus,
      required this.onPlus});
  final int quantity;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback? onTap, String tip) => Tooltip(
          message: tip,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 34,
              height: 34,
              child: Icon(icon,
                  size: 18,
                  color: onTap == null
                      ? context.palette.textMuted.withValues(alpha: 0.4)
                      : context.colors.onSurface),
            ),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, onMinus, 'Decrease quantity'),
          SizedBox(
            width: 24,
            child: Text('$quantity',
                textAlign: TextAlign.center, style: context.text.titleSmall),
          ),
          btn(Icons.add_rounded, onPlus, 'Increase quantity'),
        ],
      ),
    );
  }
}

/// Rounded surface card used across the app.
class AppCard extends StatelessWidget {
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(AppSpace.lg),
      this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: context.colors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Bottom action area with a hairline on top (add to bag, checkout...).
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.colors.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.md),
            child: child,
          ),
        ),
      );
}

/// Filled button that swaps its label for a spinner while [loading].
class LoadingButton extends StatelessWidget {
  const LoadingButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.loading = false,
      this.icon});
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8)
                  ],
                  Flexible(
                      child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
              ),
      ),
    );
  }
}

Color colorFromName(String name) => switch (name.toLowerCase()) {
      'black' => const Color(0xFF1B1B1F),
      'white' => const Color(0xFFFAFAFA),
      'red' => const Color(0xFFD7332A),
      'beige' => const Color(0xFFD9C5A7),
      'brown' => const Color(0xFF7A5238),
      'khaki' => const Color(0xFF8E8A62),
      'yellow' => const Color(0xFFF2C21A),
      'orange' => const Color(0xFFF2811D),
      'navy' => const Color(0xFF1F2F4F),
      'grey' || 'gray' => const Color(0xFF9A9A9E),
      'blue' => const Color(0xFF3F74C9),
      'green' => const Color(0xFF3F9B6C),
      'teal' => const Color(0xFF4F8A8B),
      'gold' => const Color(0xFFD4AF37),
      'pink' => const Color(0xFFF2A7BD),
      _ => const Color(0xFFB0A090),
    };

void showAppSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        content: Text(message), duration: const Duration(seconds: 2)));
}
