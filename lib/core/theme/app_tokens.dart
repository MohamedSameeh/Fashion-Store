import 'package:flutter/material.dart';

/// Design tokens for the Fashionshop design system.
/// The brand accent is the red the app has always used for its primary
/// actions and bottom navigation (Material red 600).
class AppColors {
  AppColors._();

  static const brand = Color(0xFFE53935);
  static const brandDark = Color(0xFFFF6B5E); // accent on dark surfaces
  static const ink = Color(0xFF1B1B1F);
  static const sand = Color(0xFFF6F2EC);
  static const gold = Color(0xFFF5A524);
  static const success = Color(0xFF1E9E6A);
  static const info = Color(0xFF2F6FED);
  static const warning = Color(0xFFE08A00);

  // Light surfaces
  static const lightBg = Color(0xFFFAF8F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF1EDE7);
  static const lightOutline = Color(0xFFE4DED6);
  static const lightTextMuted = Color(0xFF6E6A66);

  // Dark surfaces
  static const darkBg = Color(0xFF121214);
  static const darkSurface = Color(0xFF1C1C20);
  static const darkSurfaceAlt = Color(0xFF26262B);
  static const darkOutline = Color(0xFF34343A);
  static const darkTextMuted = Color(0xFFA5A3A0);
}

class AppSpace {
  AppSpace._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius field = BorderRadius.all(Radius.circular(md));
}

class AppDurations {
  AppDurations._();
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 280);
}

/// Extra semantic colors that Material's ColorScheme does not cover.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.surfaceAlt,
    required this.textMuted,
    required this.success,
    required this.info,
    required this.warning,
    required this.star,
    required this.skeleton,
    required this.skeletonHighlight,
  });

  final Color surfaceAlt;
  final Color textMuted;
  final Color success;
  final Color info;
  final Color warning;
  final Color star;
  final Color skeleton;
  final Color skeletonHighlight;

  static const light = AppPalette(
    surfaceAlt: AppColors.lightSurfaceAlt,
    textMuted: AppColors.lightTextMuted,
    success: AppColors.success,
    info: AppColors.info,
    warning: AppColors.warning,
    star: AppColors.gold,
    skeleton: Color(0xFFE9E4DD),
    skeletonHighlight: Color(0xFFF6F3EE),
  );

  static const dark = AppPalette(
    surfaceAlt: AppColors.darkSurfaceAlt,
    textMuted: AppColors.darkTextMuted,
    success: Color(0xFF4CC38A),
    info: Color(0xFF7AA7FF),
    warning: Color(0xFFFFB84D),
    star: AppColors.gold,
    skeleton: Color(0xFF26262B),
    skeletonHighlight: Color(0xFF34343A),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      star: Color.lerp(star, other.star, t)!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
      skeletonHighlight:
          Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
    );
  }
}

extension AppThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
