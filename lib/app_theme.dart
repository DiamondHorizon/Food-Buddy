import 'package:flutter/material.dart';

class Palette {
  Palette._();
  static const redOchre = Color(0xFFC92F00);
  static const green = Color(0xFF306F00);
  static const yellow = Color(0xFFFFC800);
  static const pumpkin = Color(0xFFFF6600);
  static const navy = Color(0xFF002664);
  static const brandy = Color(0xFF732C17);
  static const cornflower = Color(0xFF5C98FF);
  static const purple = Color(0xFF64006F);
}

class AppColors {
  AppColors._();

  static const bannerText = Colors.white;
  static const closeHover = Color(0xFFE81123);

  static const inventoryAccent = Palette.green;
  static const recipesAccent = Palette.redOchre;
  static const accountAccent = Palette.navy;

  static const inventoryBg = [Color.fromARGB(255, 196, 221, 190), Color.fromARGB(255, 201, 225, 170)];
  static const inventoryBgDark = [Color.fromARGB(255, 8, 21, 0), Color.fromARGB(255, 0, 0, 0)];
  static const recipesBg = [Color.fromARGB(255, 255, 214, 214), Color(0xFFFFD6BA)];
  static const recipesBgDark = [Color.fromARGB(255, 56, 13, 1), Color.fromARGB(255, 0, 0, 0)];
  static const accountBg = [Color(0xFFEEF2F9), Color(0xFFD9E1EE)];
  static const accountBgDark = [Color(0xFF111A2B), Color.fromARGB(255, 7, 13, 23)];

  static const pantryLight = Color(0xFFF4E4D9);
  static const pantry = Color(0xFFA0522D);
  static const pantryDark = Palette.brandy;

  static const fridgeLight = Color(0xFFE2EDFF);
  static const fridge = Palette.cornflower;
  static const fridgeDark = Color(0xFF2A62CC);

  static const freezerLight = Color(0xFFF3DFF5);
  static const freezer = Color(0xFF9C3AA8);
  static const freezerDark = Palette.purple;

  static Color accentFor(Color accent, bool dark) =>
      dark ? Color.lerp(accent, Colors.white, 0.5)! : accent;

  static Color sidebarFor(Color accent, bool dark) => dark
      ? Color.lerp(accent, Colors.black, 0.7)!
      : Color.lerp(accent, Colors.white, 0.85)!;
}

class AppShades extends ThemeExtension<AppShades> {
  final Color ink;
  final Color muted;
  final Color surface;
  final Color card;
  final Color matchComplete;
  final Color matchPartial;

  const AppShades({
    required this.ink,
    required this.muted,
    required this.surface,
    required this.card,
    required this.matchComplete,
    required this.matchPartial,
  });

  static const light = AppShades(
    ink: Color(0xFF1F1A14),
    muted: Color(0xFF5E554C),
    surface: Color(0xFFFFFBF2),
    card: Colors.white,
    matchComplete: Palette.green,
    matchPartial: Color(0xFFE85D00),
  );

  static const dark = AppShades(
    ink: Color(0xFFF2EDE6),
    muted: Color(0xFFB5AA9D),
    surface: Color(0xFF161412),
    card: Color(0xFF24211E),
    matchComplete: Color(0xFF98B780),
    matchPartial: Color(0xFFFF8A3D),
  );

  static AppShades of(BuildContext context) => Theme.of(context).extension<AppShades>()!;

  @override
  AppShades copyWith({
    Color? ink,
    Color? muted,
    Color? surface,
    Color? card,
    Color? matchComplete,
    Color? matchPartial,
  }) =>
      AppShades(
        ink: ink ?? this.ink,
        muted: muted ?? this.muted,
        surface: surface ?? this.surface,
        card: card ?? this.card,
        matchComplete: matchComplete ?? this.matchComplete,
        matchPartial: matchPartial ?? this.matchPartial,
      );

  @override
  AppShades lerp(ThemeExtension<AppShades>? other, double t) {
    if (other is! AppShades) return this;
    return AppShades(
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      matchComplete: Color.lerp(matchComplete, other.matchComplete, t)!,
      matchPartial: Color.lerp(matchPartial, other.matchPartial, t)!,
    );
  }
}

ThemeData buildAppTheme([Color accent = AppColors.inventoryAccent, bool dark = false]) {
  final shades = dark ? AppShades.dark : AppShades.light;
  final primary = AppColors.accentFor(accent, dark);

  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: primary,
    onPrimary: dark ? AppShades.light.ink : Colors.white,
    surface: shades.card,
    onSurface: shades.ink,
    error: dark ? const Color(0xFFFF8A65) : Palette.redOchre,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: shades.surface,
    extensions: [shades],
    cardTheme: CardThemeData(
      color: shades.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: shades.ink.withValues(alpha: 0.08)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: shades.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: shades.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
    ),
  );
}