import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models.dart';
import '../../../data/store_repository.dart';
import '../../models/product_model.dart';

/// Ratings summary, review list and "write a review" for one product.
class RatingAndReviewPage extends StatefulWidget {
  const RatingAndReviewPage({super.key, required this.product});
  final Product product;

  @override
  State<RatingAndReviewPage> createState() => _RatingAndReviewPageState();
}

class _RatingAndReviewPageState extends State<RatingAndReviewPage> {
  late final Stream<List<Review>> _stream =
      Repo.store.watchReviews(widget.product.id);

  Future<void> _writeReview() async {
    var rating = 5;
    final controller = TextEditingController();
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl,
              AppSpace.xl + MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('What is your rating?', style: context.text.headlineSmall),
              const SizedBox(height: AppSpace.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    tooltip: '${index + 1} stars',
                    iconSize: 38,
                    icon: Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: context.palette.star,
                    ),
                    onPressed: () => setSheet(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: AppSpace.md),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                    hintText: 'Your review (fit, quality, delivery...)'),
              ),
              const SizedBox(height: AppSpace.lg),
              LoadingButton(
                label: 'Send review',
                onPressed: () {
                  if (controller.text.trim().length < 4) {
                    showAppSnack(context, 'Please write a few words first');
                    return;
                  }
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (submitted == true) {
      await Repo.store
          .addReview(widget.product.id, rating, controller.text.trim());
      if (mounted) showAppSnack(context, 'Thanks! Your review was posted.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rating & Reviews')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _writeReview,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Write a review'),
      ),
      body: StreamBuilder<List<Review>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorState(
                message: 'We could not load the reviews.');
          }
          if (!snapshot.hasData) return const ListSkeleton(height: 96);
          final reviews = snapshot.data!;
          if (reviews.isEmpty) {
            return EmptyState(
              icon: Icons.rate_review_outlined,
              title: 'No reviews yet',
              message: 'Be the first to review ${widget.product.name}.',
              actionLabel: 'Write a review',
              onAction: _writeReview,
            );
          }

          final avg = reviews.fold<int>(0, (a, r) => a + r.rating) /
              reviews.length;
          final counts = {
            for (var s = 5; s >= 1; s--)
              s: reviews.where((r) => r.rating == s).length
          };

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.lg, AppSpace.sm, AppSpace.lg, 96),
            children: [
              Text(widget.product.name, style: context.text.bodySmall),
              const SizedBox(height: AppSpace.md),
              AppCard(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(avg.toStringAsFixed(1),
                            style: context.text.displaySmall),
                        RatingStars(avg, size: 16),
                        const SizedBox(height: 4),
                        Text(
                            '${reviews.length} ${reviews.length == 1 ? 'rating' : 'ratings'}',
                            style: context.text.bodySmall),
                      ],
                    ),
                    const SizedBox(width: AppSpace.xl),
                    Expanded(
                      child: Column(
                        children: [
                          for (final e in counts.entries)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    child: Text('${e.key}',
                                        style: context.text.labelSmall),
                                  ),
                                  Icon(Icons.star_rounded,
                                      size: 12, color: context.palette.star),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.pill),
                                      child: LinearProgressIndicator(
                                        value: e.value / reviews.length,
                                        minHeight: 8,
                                        backgroundColor:
                                            context.palette.surfaceAlt,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 24,
                                    child: Text('${e.value}',
                                        textAlign: TextAlign.end,
                                        style: context.text.bodySmall),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              Text('${reviews.length} reviews',
                  style: context.text.titleMedium),
              const SizedBox(height: AppSpace.md),
              for (final r in reviews)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.md),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: context.palette.surfaceAlt,
                              child: Text(
                                  r.author.isEmpty ? '?' : r.author[0],
                                  style: context.text.titleSmall),
                            ),
                            const SizedBox(width: AppSpace.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.author,
                                      style: context.text.titleSmall),
                                  RatingStars(r.rating.toDouble(), size: 14),
                                ],
                              ),
                            ),
                            Text(shortDate(r.date),
                                style: context.text.bodySmall),
                          ],
                        ),
                        const SizedBox(height: AppSpace.md),
                        Text(r.text, style: context.text.bodyMedium),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
