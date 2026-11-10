import 'package:flutter/material.dart';

/// Spacing scale (logical pixels).
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radii.
abstract final class Radii {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;
}

/// Maximum content widths, so long lines stay readable on wide screens.
abstract final class ContentWidth {
  static const double reading = 760;
  static const double page = 1280;
}

/// Colours with a domain meaning, beyond the Material colour scheme.
@immutable
class TrlColors extends ThemeExtension<TrlColors> {
  const TrlColors({
    required this.meets,
    required this.below,
    required this.rethink,
    required this.heritage,
    required this.trlLow,
    required this.trlHigh,
    required this.heroStart,
    required this.heroEnd,
    required this.hairline,
  });

  /// Component meets the target TRL.
  final Color meets;

  /// Component is below the target TRL.
  final Color below;

  /// "Rethink position regarding this technology!"
  final Color rethink;

  /// Heritage (reused) component.
  final Color heritage;

  /// Ends of the TRL ramp: TRL 1 → [trlLow], TRL 9 → [trlHigh].
  final Color trlLow;
  final Color trlHigh;

  /// Gradient of the project header.
  final Color heroStart;
  final Color heroEnd;

  /// Card borders and dividers.
  final Color hairline;

  /// The colour of a TRL (1–9) on the maturity ramp.
  Color trl(int level) => Color.lerp(trlLow, trlHigh, (level - 1) / 8)!;

  static const dark = TrlColors(
    meets: Color(0xFF34D3A0),
    below: Color(0xFFF5B95C),
    rethink: Color(0xFFFF6B8B),
    heritage: Color(0xFF9DB4FF),
    trlLow: Color(0xFFB794F6),
    trlHigh: Color(0xFF22D3EE),
    heroStart: Color(0xFF1B2454),
    heroEnd: Color(0xFF0E3A4A),
    hairline: Color(0xFF242E57),
  );

  static const light = TrlColors(
    meets: Color(0xFF0E8A66),
    below: Color(0xFFB86E00),
    rethink: Color(0xFFD12E57),
    heritage: Color(0xFF4058C8),
    trlLow: Color(0xFF7C3AED),
    trlHigh: Color(0xFF0784A3),
    heroStart: Color(0xFFE3E7FF),
    heroEnd: Color(0xFFD7F3F5),
    hairline: Color(0xFFDDE2EE),
  );

  @override
  TrlColors copyWith({
    Color? meets,
    Color? below,
    Color? rethink,
    Color? heritage,
    Color? trlLow,
    Color? trlHigh,
    Color? heroStart,
    Color? heroEnd,
    Color? hairline,
  }) => TrlColors(
    meets: meets ?? this.meets,
    below: below ?? this.below,
    rethink: rethink ?? this.rethink,
    heritage: heritage ?? this.heritage,
    trlLow: trlLow ?? this.trlLow,
    trlHigh: trlHigh ?? this.trlHigh,
    heroStart: heroStart ?? this.heroStart,
    heroEnd: heroEnd ?? this.heroEnd,
    hairline: hairline ?? this.hairline,
  );

  @override
  TrlColors lerp(TrlColors? other, double t) {
    if (other == null) return this;
    return TrlColors(
      meets: Color.lerp(meets, other.meets, t)!,
      below: Color.lerp(below, other.below, t)!,
      rethink: Color.lerp(rethink, other.rethink, t)!,
      heritage: Color.lerp(heritage, other.heritage, t)!,
      trlLow: Color.lerp(trlLow, other.trlLow, t)!,
      trlHigh: Color.lerp(trlHigh, other.trlHigh, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
    );
  }
}

extension TrlThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  TrlColors get trlColors => Theme.of(this).extension<TrlColors>()!;
}
