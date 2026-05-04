import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode {
  defaultTheme,
  light,
  dark,
}

class WireTheme {
  // --- Dark Theme (Telegram Dark Blue) ---
  static const Color background = Color(0xFF000000); // Pure dark black
  static const Color surface = Color(0xFF111111);
  static const Color primary = Color(0xFF3390EC); // Telegram Blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF222222);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color variant = Color(0xFF333333);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      background: background,
      surface: surface,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSurface: onSurface,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: onSurface),
      headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: onSurface),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: onSurface),
      labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: onPrimary),
    ),
    dividerTheme: const DividerThemeData(color: variant, thickness: 1),
  );

  // --- Light Theme (White Theme) ---
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF4F4F5);
  static const Color lightPrimary = Color(0xFF3390EC); // Telegram Blue
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFE0E0E0);
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color lightVariant = Color(0xFFE5E5E5);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      background: lightBackground,
      surface: lightSurface,
      primary: lightPrimary,
      onPrimary: lightOnPrimary,
      secondary: lightSecondary,
      onSurface: lightOnSurface,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: lightOnSurface),
      headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: lightOnSurface),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: lightOnSurface),
      labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: lightOnPrimary),
    ),
    dividerTheme: const DividerThemeData(color: lightVariant, thickness: 1),
  );

  // --- Default Theme (Old UI Color from HTML) ---
  static const Color defaultBackground = Color(0xFF0A0A0A);
  static const Color defaultSurface = Color(0xFF17130F);
  static const Color defaultPrimary = Color(0xFFF2BE8C); // Orange-ish primary
  static const Color defaultOnPrimary = Color(0xFF482904);
  static const Color defaultSecondary = Color(0xFF393430);
  static const Color defaultOnSurface = Color(0xFFEAE1DB);
  static const Color defaultVariant = Color(0xFF393430);

  static ThemeData get defaultTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: defaultBackground,
    colorScheme: const ColorScheme.dark(
      background: defaultBackground,
      surface: defaultSurface,
      primary: defaultPrimary,
      onPrimary: defaultOnPrimary,
      secondary: defaultSecondary,
      onSurface: defaultOnSurface,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: defaultOnSurface),
      headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: defaultOnSurface),
      bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: defaultOnSurface),
      labelLarge: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.bold, color: defaultOnPrimary),
    ),
    dividerTheme: const DividerThemeData(color: defaultVariant, thickness: 1),
  );
}
