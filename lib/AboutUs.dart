import 'package:flutter/material.dart';

import 'core/theme/app_tokens.dart';
import 'core/widgets/app_widgets.dart';

class AboutUS extends StatelessWidget {
  const AboutUS({super.key});

  // The team that built the app.
  static const List<Map<String, String>> teamMembers = [
    {'name': 'Hend Sayed', 'description': 'Mobile app Developer'},
    {'name': 'Norhan Ayman', 'description': 'Mobile app Developer'},
    {'name': 'Menna Elwan', 'description': 'Mobile app Developer'},
    {'name': 'Mohamed Sameeh', 'description': 'Mobile app Developer'},
    {'name': 'Ibrahim Elareney', 'description': 'Mobile app Developer'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          const SizedBox(height: AppSpace.md),
          const Center(child: BrandMark(size: 24)),
          const SizedBox(height: AppSpace.lg),
          Text(
            'A fashion store app for women, men and kids, built as a DEPI final project.',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium!
                .copyWith(color: context.palette.textMuted),
          ),
          const SizedBox(height: AppSpace.xxl),
          Text('The team', style: context.text.titleMedium),
          const SizedBox(height: AppSpace.md),
          for (final member in teamMembers)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpace.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: context.colors.primaryContainer,
                      child: Text(
                        member['name']!
                            .split(' ')
                            .map((p) => p[0])
                            .take(2)
                            .join(),
                        style: context.text.titleSmall!.copyWith(
                            color: context.colors.onPrimaryContainer),
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member['name']!,
                              style: context.text.titleSmall),
                          Text(member['description']!,
                              style: context.text.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
