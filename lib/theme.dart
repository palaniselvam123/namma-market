import 'package:flutter/material.dart';

/// Brand constants from the MahaRaja crown mark. These are identical in both
/// themes — a logo does not change colour with the OS setting.
const kNavyDeep = Color(0xFF0A1626);
const kNavy = Color(0xFF102138);
const kNavyLight = Color(0xFF1D3A5F);
const kCream = Color(0xFFF7F4EC);
const kGoldLeaf = Color(0xFFD9B45B);

/// Warm Chennai-market palette: terracotta primary on a sand ground,
/// with a produce-green used only for delivery/savings signals.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryBg;
  final Color green;
  final Color greenBg;
  final Color gold;
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceSunk;
  final Color t0;
  final Color t1;
  final Color t2;
  final Color t3;
  final Color border;
  final Color borderLight;

  const AppColors({
    required this.primary,
    required this.primaryBg,
    required this.green,
    required this.greenBg,
    required this.gold,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceSunk,
    required this.t0,
    required this.t1,
    required this.t2,
    required this.t3,
    required this.border,
    required this.borderLight,
  });

  static const light = AppColors(
    primary: Color(0xFFC8390A),
    primaryBg: Color(0xFFFFF1EB),
    green: Color(0xFF15803D),
    greenBg: Color(0xFFDCFCE7),
    gold: Color(0xFFB8860B),
    bg: Color(0xFFF3EDE5),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF8F4EE),
    surfaceSunk: Color(0xFFF0EAE0),
    t0: Color(0xFF1A0F08),
    t1: Color(0xFF5C4333),
    t2: Color(0xFF9A8272),
    t3: Color(0xFFC4B098),
    border: Color(0xFFE8DFD2),
    borderLight: Color(0xFFF0EAE0),
  );

  static const dark = AppColors(
    primary: Color(0xFFE8551F),
    primaryBg: Color(0xFF33180E),
    green: Color(0xFF4ADE80),
    greenBg: Color(0xFF15281B),
    gold: Color(0xFFE0B040),
    bg: Color(0xFF0F0A06),
    surface: Color(0xFF1A120C),
    surfaceAlt: Color(0xFF221810),
    surfaceSunk: Color(0xFF2E2018),
    t0: Color(0xFFF0E4D6),
    t1: Color(0xFFB8A48E),
    t2: Color(0xFF7A6652),
    t3: Color(0xFF4A3828),
    border: Color(0xFF2E2218),
    borderLight: Color(0xFF382A1E),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryBg,
    Color? green,
    Color? greenBg,
    Color? gold,
    Color? bg,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceSunk,
    Color? t0,
    Color? t1,
    Color? t2,
    Color? t3,
    Color? border,
    Color? borderLight,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryBg: primaryBg ?? this.primaryBg,
      green: green ?? this.green,
      greenBg: greenBg ?? this.greenBg,
      gold: gold ?? this.gold,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceSunk: surfaceSunk ?? this.surfaceSunk,
      t0: t0 ?? this.t0,
      t1: t1 ?? this.t1,
      t2: t2 ?? this.t2,
      t3: t3 ?? this.t3,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: l(primary, other.primary),
      primaryBg: l(primaryBg, other.primaryBg),
      green: l(green, other.green),
      greenBg: l(greenBg, other.greenBg),
      gold: l(gold, other.gold),
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      surfaceSunk: l(surfaceSunk, other.surfaceSunk),
      t0: l(t0, other.t0),
      t1: l(t1, other.t1),
      t2: l(t2, other.t2),
      t3: l(t3, other.t3),
      border: l(border, other.border),
      borderLight: l(borderLight, other.borderLight),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}

ThemeData buildTheme(Brightness brightness) {
  final ac = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    fontFamily: 'system-ui',
    colorScheme: ColorScheme.fromSeed(
      seedColor: ac.primary,
      brightness: brightness,
    ).copyWith(surface: ac.surface),
    scaffoldBackgroundColor: ac.bg,
  );
  return base.copyWith(
    extensions: [ac],
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
