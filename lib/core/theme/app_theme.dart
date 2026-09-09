import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Palette
  static const Color primaryTeal = Color(0xFF0D9488); // Modern clinical teal
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentCoral = Color(0xFFF43F5E);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentEmerald = Color(0xFF10B981);

  // Neutral Palette
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryTeal,
    scaffoldBackgroundColor: slate50,
    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      secondary: accentCyan,
      surface: Colors.white,
      error: accentCoral,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: slate900,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: const TextStyle(fontWeight: FontWeight.w800, color: slate900, letterSpacing: -1.0),
      displayMedium: const TextStyle(fontWeight: FontWeight.w800, color: slate900, letterSpacing: -0.5),
      titleLarge: const TextStyle(fontWeight: FontWeight.w800, color: slate900, letterSpacing: -0.4),
      titleMedium: const TextStyle(fontWeight: FontWeight.w700, color: slate800, letterSpacing: -0.2),
      titleSmall: const TextStyle(fontWeight: FontWeight.w600, color: slate800),
      bodyLarge: const TextStyle(color: slate800, height: 1.5, letterSpacing: -0.1),
      bodyMedium: const TextStyle(color: slate700, height: 1.4),
      labelLarge: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: slate900,
      elevation: 0,
      scrolledUnderElevation: 1.5,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: slate900,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: slate200, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentCoral),
      ),
      labelStyle: const TextStyle(color: slate600, fontSize: 13.5, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: slate400, fontSize: 13.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, letterSpacing: 0.1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTeal,
        side: const BorderSide(color: primaryTeal, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: slate100,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      labelStyle: const TextStyle(color: slate800, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.25),
      side: const BorderSide(color: slate200, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
  );
}
