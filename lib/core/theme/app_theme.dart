import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// Material 3 themes (light + dark) built from [AppColors] tokens.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  /// Font variants used by the theme; awaited on the splash screen so the
  /// first real screen never paints with a fallback font.
  static Future<void> preloadFonts() {
    for (final w in [
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700
    ]) {
      GoogleFonts.dmSans(fontWeight: w);
    }
    GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600);
    GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700);
    return GoogleFonts.pendingFonts();
  }

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final primary = isDark ? AppColors.brandDark : AppColors.brand;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceAlt =
        isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final onSurface = isDark ? const Color(0xFFF3F1EE) : AppColors.ink;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: b,
    ).copyWith(
      primary: primary,
      onPrimary: isDark ? const Color(0xFF2A0A07) : Colors.white,
      primaryContainer:
          isDark ? const Color(0xFF4A1A15) : const Color(0xFFFDE7E5),
      onPrimaryContainer:
          isDark ? const Color(0xFFFFDAD5) : const Color(0xFF8C1D18),
      secondary: isDark ? const Color(0xFFE8E2DA) : AppColors.ink,
      onSecondary: isDark ? AppColors.ink : Colors.white,
      secondaryContainer: surfaceAlt,
      onSecondaryContainer: onSurface,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: muted,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surface,
      surfaceContainer: surfaceAlt,
      surfaceContainerHigh: surfaceAlt,
      surfaceContainerHighest: surfaceAlt,
      outline: outline,
      outlineVariant: outline,
      error: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E),
      surfaceTint: Colors.transparent,
    );

    final base = GoogleFonts.dmSansTextTheme(
      ThemeData(brightness: b, useMaterial3: true).textTheme,
    ).apply(bodyColor: onSurface, displayColor: onSurface);

    TextStyle serif(double size, FontWeight w, {double h = 1.15}) =>
        GoogleFonts.playfairDisplay(
            fontSize: size, fontWeight: w, height: h, color: onSurface);

    final text = base.copyWith(
      displaySmall: serif(34, FontWeight.w700),
      headlineLarge: serif(30, FontWeight.w700),
      headlineMedium: serif(26, FontWeight.w700),
      headlineSmall: serif(22, FontWeight.w600),
      titleLarge: base.titleLarge!
          .copyWith(fontSize: 19, fontWeight: FontWeight.w700, height: 1.25),
      titleMedium: base.titleMedium!
          .copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3),
      titleSmall: base.titleSmall!
          .copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge: base.bodyLarge!.copyWith(fontSize: 16, height: 1.45),
      bodyMedium: base.bodyMedium!.copyWith(fontSize: 14, height: 1.45),
      bodySmall:
          base.bodySmall!.copyWith(fontSize: 12.5, height: 1.4, color: muted),
      labelLarge: base.labelLarge!.copyWith(
          fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: base.labelMedium!
          .copyWith(fontSize: 12.5, fontWeight: FontWeight.w600),
      labelSmall: base.labelSmall!.copyWith(
          fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4),
    );

    OutlineInputBorder fieldBorder(Color c, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: text,
      extensions: [isDark ? AppPalette.dark : AppPalette.light],
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: outline),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          side: BorderSide(color: outline),
          foregroundColor: onSurface,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: fieldBorder(outline),
        enabledBorder: fieldBorder(outline),
        focusedBorder: fieldBorder(primary, 1.6),
        errorBorder: fieldBorder(scheme.error),
        focusedErrorBorder: fieldBorder(scheme.error, 1.6),
        hintStyle: text.bodyMedium!.copyWith(color: muted),
        labelStyle: text.bodyMedium!.copyWith(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: isDark ? const Color(0xFFF3F1EE) : AppColors.ink,
        side: BorderSide(color: outline),
        shape: const StadiumBorder(),
        labelStyle: text.labelMedium,
        secondaryLabelStyle: text.labelMedium!
            .copyWith(color: isDark ? AppColors.ink : Colors.white),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        height: 68,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((s) =>
            text.labelSmall!.copyWith(
                letterSpacing: 0.1,
                color: s.contains(WidgetState.selected) ? primary : muted)),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected) ? primary : muted)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFFF3F1EE) : AppColors.ink,
        contentTextStyle: text.bodyMedium!
            .copyWith(color: isDark ? AppColors.ink : Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurface,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : muted),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary : surfaceAlt),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: surfaceAlt,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? (isDark ? const Color(0xFFF3F1EE) : AppColors.ink)
                  : surface),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? (isDark ? AppColors.ink : Colors.white)
                  : onSurface),
          side: WidgetStateProperty.all(BorderSide(color: outline)),
          textStyle: WidgetStateProperty.all(text.labelMedium),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      tabBarTheme: TabBarThemeData(
        labelColor: onSurface,
        unselectedLabelColor: muted,
        indicatorColor: primary,
        dividerColor: outline,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }
}
