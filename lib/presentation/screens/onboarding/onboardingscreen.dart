import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  static const _pages = [
    (
      image: 'assets/images/boarding1.png',
      title: 'Personalized Fashion',
      body:
          'Discover clothes that match your style, from casual to formal, with handpicked selections just for you.',
    ),
    (
      image: 'assets/images/boarding.png',
      title: 'Fashion for Everyone',
      body:
          'The latest trends for women, men and kids. Shop your favorite styles with a quick, secure checkout.',
    ),
    (
      image: 'assets/images/onboarding3.png',
      title: 'Exclusive Deals',
      body:
          'Stay up to date with the latest offers and grab your favorite items at a better price before they are gone.',
    ),
  ];

  void _finish() => Navigator.pushReplacementNamed(context, 'signIn');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = currentPage == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpace.sm, top: 4),
                child: TextButton(onPressed: _finish, child: const Text('Skip')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => currentPage = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpace.xxl),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(
                                  maxWidth: 340, maxHeight: 340),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl + 8),
                                border: Border.all(
                                    color: context.colors.outline),
                              ),
                              clipBehavior: Clip.antiAlias,
                              padding: const EdgeInsets.all(AppSpace.xl),
                              child: Image.asset(p.image, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        Text(p.title,
                            textAlign: TextAlign.center,
                            style: context.text.headlineLarge),
                        const SizedBox(height: AppSpace.md),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: context.text.bodyLarge!
                              .copyWith(color: context.palette.textMuted),
                        ),
                        const SizedBox(height: AppSpace.xxl),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == currentPage;
                return AnimatedContainer(
                  duration: AppDurations.normal,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? context.colors.primary
                        : context.colors.outline,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpace.xxl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (last) {
                      _finish();
                    } else {
                      _controller.nextPage(
                          duration: AppDurations.normal,
                          curve: Curves.easeOutCubic);
                    }
                  },
                  child: Text(last ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
