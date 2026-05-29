// lib/core/theme/app_theme.dart
//
// Design tokens from the ServiceNin HTML design system.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand
  static const orange = Color(0xFFF97316);
  static const orangeDark = Color(0xFFEA580C);
  static const navy = Color(0xFF1F2A5C);
  static const navy2 = Color(0xFF2D3D7A);

  // Neutrals
  static const ink900 = Color(0xFF000000);
  static const ink700 = Color(0xFF111418);
  static const ink500 = Color(0xFF5B6471);
  static const ink400 = Color(0xFF98A0AC);
  static const ink200 = Color(0xFFE5E7EB);
  static const ink100 = Color(0xFFF1F3F5);
  static const surfaceDim = Color(0xFFF6F7F9);

  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Per-module accents (match the HTML modules)
  static const mint = Color(0xFF047857);     // Healthcare
  static const rose = Color(0xFFDC2626);     // Blood / Ambulance emergency
  static const teal = Color(0xFF0D9488);     // Home Service
  static const amber = Color(0xFFB45309);    // Physio
  static const pink = Color(0xFFBE185D);     // Matchmaking
  static const burnt = Color(0xFFC2410C);    // Jobs
  static const violet = Color(0xFF6D28D9);   // Education
  static const dnccOrange = Color(0xFFEA580C); // Nagarik
  static const indigo = Color(0xFF4338CA);   // Info
  static const stone = Color(0xFF44403C);    // Funeral
}

class AppTheme {
  static ThemeData light() {
    // Plus Jakarta Sans for UI; Hind Siliguri available for Bangla via .bnStyle.
    final base = ThemeData(useMaterial3: true, scaffoldBackgroundColor: Colors.white);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orange, primary: AppColors.orange),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: AppColors.ink900, elevation: 0),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange, foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// Bangla text style helper (Hind Siliguri).
  static TextStyle bn([TextStyle? s]) => GoogleFonts.hindSiliguri(textStyle: s);
}
