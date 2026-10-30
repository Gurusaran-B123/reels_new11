import 'package:flutter/material.dart';

/// Colours taken straight from the Reels new11 logo:
/// hot pink -> electric purple -> sunset orange on a near-black base.
class Brand {
  Brand._();

  static const Color pink = Color(0xFFFF5FB7);
  static const Color purple = Color(0xFF9B2BE3);
  static const Color orange = Color(0xFFFF9A3E);
  static const Color ink = Color(0xFF141414);
  static const Color inkSoft = Color(0xFF1E1E21);
  static const Color lavenderBg = Color(0xFFFBF5FF);

  static const LinearGradient gradient = LinearGradient(
    colors: [pink, purple, orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientSoft = LinearGradient(
    colors: [Color(0xFFFF5FB7), Color(0xFF9B2BE3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: Brand.purple,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFFD27BFF) : Brand.purple,
      secondary: Brand.pink,
      tertiary: Brand.orange,
      surface: isDark ? Brand.inkSoft : Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? Brand.ink : Brand.lavenderBg,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Brand.ink : Brand.lavenderBg,
        foregroundColor: isDark ? Colors.white : Brand.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : Brand.ink,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF0E0E10) : Colors.white,
        indicatorColor: Brand.purple.withAlpha(isDark ? 90 : 40),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2A2A2E) : Brand.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
