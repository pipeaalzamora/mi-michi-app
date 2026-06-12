import 'package:flutter/material.dart';

/// Paleta de colores según el sexo del gato activo.
class CatTheme {
  final String sex;
  final Color primary;
  final Color primaryLight;
  final Color secondary;
  final Color surface;
  final Color background;
  final Color cardFill;
  final Color inputFill;
  final Color heroGradientStart;
  final Color heroGradientEnd;
  final String label;
  final String emoji;

  const CatTheme._({
    required this.sex,
    required this.primary,
    required this.primaryLight,
    required this.secondary,
    required this.surface,
    required this.background,
    required this.cardFill,
    required this.inputFill,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.label,
    required this.emoji,
  });

  // ── Hembra — rosa/lila (paleta original) ──────────────────
  static const hembra = CatTheme._(
    sex: 'hembra',
    primary: Color(0xFFE879A0),
    primaryLight: Color(0xFFF5A8C4),
    secondary: Color(0xFFA78BFA),
    surface: Color(0xFFFFF5F8),
    background: Color(0xFFFFFBFE),
    cardFill: Colors.white,
    inputFill: Color(0xFFF8F4FF),
    heroGradientStart: Color(0xFFE879A0),
    heroGradientEnd: Color(0xFFA78BFA),
    label: 'Hembra',
    emoji: '🌸',
  );

  // ── Macho — azul/celeste ───────────────────────────────────
  static const macho = CatTheme._(
    sex: 'macho',
    primary: Color(0xFF3B82F6),
    primaryLight: Color(0xFF93C5FD),
    secondary: Color(0xFF06B6D4),
    surface: Color(0xFFF0F9FF),
    background: Color(0xFFF8FBFF),
    cardFill: Colors.white,
    inputFill: Color(0xFFEFF6FF),
    heroGradientStart: Color(0xFF3B82F6),
    heroGradientEnd: Color(0xFF06B6D4),
    label: 'Macho',
    emoji: '💙',
  );

  // ── Desconocido — verde/menta neutro ──────────────────────
  static const desconocido = CatTheme._(
    sex: 'desconocido',
    primary: Color(0xFF10B981),
    primaryLight: Color(0xFF6EE7B7),
    secondary: Color(0xFF8B5CF6),
    surface: Color(0xFFF0FDF4),
    background: Color(0xFFF8FFFE),
    cardFill: Colors.white,
    inputFill: Color(0xFFF0FDF4),
    heroGradientStart: Color(0xFF10B981),
    heroGradientEnd: Color(0xFF8B5CF6),
    label: 'Desconocido',
    emoji: '🐾',
  );

  static CatTheme fromSex(String? sex) {
    switch (sex) {
      case 'macho':
        return macho;
      case 'hembra':
        return hembra;
      default:
        return desconocido;
    }
  }

  /// Genera el ThemeData completo de Material 3 para esta paleta.
  ThemeData toThemeData({bool dark = false}) {
    final brightness = dark ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: dark ? primaryLight : primary,
      secondary: secondary,
      surface: dark ? const Color(0xFF0F172A) : surface,
      error: const Color(0xFFEF4444),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: dark ? const Color(0xFF0F172A) : background,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF0F172A) : background,
        foregroundColor: dark ? Colors.white : const Color(0xFF1E1B4B),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: dark ? Colors.white : const Color(0xFF1E1B4B),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: dark ? const Color(0xFF1E293B) : cardFill,
        shadowColor: primary.withValues(alpha: 0.12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? primaryLight : primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1E293B) : inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: dark ? primaryLight : primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF1E293B) : Colors.white,
        selectedItemColor: dark ? primaryLight : primary,
        unselectedItemColor: const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle:
            const TextStyle(fontFamily: 'Nunito', fontSize: 11),
      ),
    );
  }

  /// Gradiente para el hero card del gato.
  LinearGradient get heroGradient => LinearGradient(
        colors: [heroGradientStart, heroGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
