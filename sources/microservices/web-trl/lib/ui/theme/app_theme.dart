import 'package:flutter/material.dart';

import 'tokens.dart';

/// Deep-space dark theme and its light counterpart.
abstract final class AppTheme {
  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8E9BFF),
    onPrimary: Color(0xFF0A0F24),
    primaryContainer: Color(0xFF2A3473),
    onPrimaryContainer: Color(0xFFDDE1FF),
    secondary: Color(0xFF5EE6C9),
    onSecondary: Color(0xFF00201A),
    secondaryContainer: Color(0xFF12403A),
    onSecondaryContainer: Color(0xFFB4F5E6),
    tertiary: Color(0xFFF5B95C),
    onTertiary: Color(0xFF2B1A00),
    error: Color(0xFFFF6B8B),
    onError: Color(0xFF2D0010),
    surface: Color(0xFF0B1022),
    onSurface: Color(0xFFE7EAF6),
    onSurfaceVariant: Color(0xFF9EA7CB),
    surfaceContainerLowest: Color(0xFF080C1B),
    surfaceContainerLow: Color(0xFF0F152C),
    surfaceContainer: Color(0xFF131A35),
    surfaceContainerHigh: Color(0xFF19213F),
    surfaceContainerHighest: Color(0xFF20294B),
    outline: Color(0xFF4A5583),
    outlineVariant: Color(0xFF242E57),
    inverseSurface: Color(0xFFE7EAF6),
    onInverseSurface: Color(0xFF131A35),
    shadow: Color(0xFF000000),
  );

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF4652C9),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE0E3FF),
    onPrimaryContainer: Color(0xFF121A63),
    secondary: Color(0xFF0E8A78),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCDF3EA),
    onSecondaryContainer: Color(0xFF00201A),
    tertiary: Color(0xFFB86E00),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFD12E57),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF6F7FC),
    onSurface: Color(0xFF141A33),
    onSurfaceVariant: Color(0xFF5A6386),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF0F2F9),
    surfaceContainerHigh: Color(0xFFE9ECF6),
    surfaceContainerHighest: Color(0xFFE1E5F2),
    outline: Color(0xFF8A92B2),
    outlineVariant: Color(0xFFDDE2EE),
    inverseSurface: Color(0xFF1B2242),
    onInverseSurface: Color(0xFFEFF1FA),
    shadow: Color(0xFF000000),
  );

  static ThemeData get dark => _build(_darkScheme, TrlColors.dark);
  static ThemeData get light => _build(_lightScheme, TrlColors.light);

  static ThemeData _build(ColorScheme scheme, TrlColors trl) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final text = _textTheme(base.textTheme, scheme);
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.lg),
      side: BorderSide(color: trl.hairline),
    );
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      extensions: [trl],
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: cardShape,
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        selectedLabelTextStyle: text.labelLarge?.copyWith(color: scheme.onSurface),
        unselectedLabelTextStyle: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.pill)),
        side: BorderSide(color: trl.hairline),
        labelStyle: text.labelLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: Space.xl),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: Space.xl),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          side: BorderSide(color: scheme.outline),
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
        ),
      ),
      dividerTheme: DividerThemeData(color: trl.hairline, space: 1, thickness: 1),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.45),
        selectedColor: scheme.onSurface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    const tabular = [FontFeature.tabularFigures()];
    TextStyle? tight(TextStyle? s, double spacing, FontWeight weight) =>
        s?.copyWith(letterSpacing: spacing, fontWeight: weight, fontFeatures: tabular);
    final t = base.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    return t.copyWith(
      displayLarge: tight(t.displayLarge, -1.5, FontWeight.w300),
      displayMedium: tight(t.displayMedium, -1.0, FontWeight.w300),
      displaySmall: tight(t.displaySmall, -0.5, FontWeight.w400),
      headlineLarge: tight(t.headlineLarge, -0.5, FontWeight.w500),
      headlineMedium: tight(t.headlineMedium, -0.4, FontWeight.w500),
      headlineSmall: tight(t.headlineSmall, -0.2, FontWeight.w500),
      titleLarge: tight(t.titleLarge, -0.1, FontWeight.w600),
      titleMedium: tight(t.titleMedium, 0, FontWeight.w600),
      titleSmall: tight(t.titleSmall, 0.1, FontWeight.w600),
      labelLarge: tight(t.labelLarge, 0.2, FontWeight.w600),
      labelMedium: tight(t.labelMedium, 0.4, FontWeight.w600),
      labelSmall: tight(t.labelSmall, 1.0, FontWeight.w700),
      bodyLarge: t.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: t.bodyMedium?.copyWith(height: 1.5, color: scheme.onSurfaceVariant),
      bodySmall: t.bodySmall?.copyWith(height: 1.4, color: scheme.onSurfaceVariant),
    );
  }
}
