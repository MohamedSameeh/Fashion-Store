import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/store_repository.dart';
import '../../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // Hold the splash for a beat while the theme fonts load.
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 1600)),
      AppTheme.preloadFonts()
          .timeout(const Duration(seconds: 4), onTimeout: () {}),
    ]);
    if (!mounted) return;

    final String next;
    if (isFirstTime) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isFirstTime', false);
      next = 'onBoarding';
    } else {
      next = Repo.auth.isSignedIn && loginOrNot ? 'homepage' : 'signIn';
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, next);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    return Scaffold(
      backgroundColor: AppColors.brand,
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(fade),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset('assets/images/app_icon.png',
                      width: 112, height: 112),
                ),
                const SizedBox(height: 24),
                const Text(
                  'FASHIONSHOP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Style for women, men and kids',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
