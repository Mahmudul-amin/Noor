import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF0F9D58);
  static const Color primaryLight = Color(0xFF4DB68C);
  static const Color primaryDark = Color(0xFF006B3C);

  // Secondary
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFEDD368);
  static const Color goldDark = Color(0xFF9E8200);

  // Background Light
  static const Color bgLight = Color(0xFFF8FAF9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background Dark
  static const Color bgDark = Color(0xFF0D1B2A);
  static const Color surfaceDark = Color(0xFF152336);
  static const Color cardDark = Color(0xFF1E3045);

  // Ramadan Special
  static const Color ramadanBg = Color(0xFF0A1628);
  static const Color ramadanSurface = Color(0xFF12213A);
  static const Color ramadanCard = Color(0xFF1A2F4E);
  static const Color ramadanAccent = Color(0xFFD4AF37);

  // Text
  static const Color textDark = Color(0xFF0D1B2A);
  static const Color textMedium = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF718096);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhiteMuted = Color(0xFFB0C4DE);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Prayer colors
  static const Color fajr = Color(0xFF6366F1);
  static const Color dhuhr = Color(0xFF0F9D58);
  static const Color asr = Color(0xFFF59E0B);
  static const Color maghrib = Color(0xFFEF4444);
  static const Color isha = Color(0xFF1E3045);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F9D58), Color(0xFF00C875)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF152336)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFEDD368)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ramadanGradient = LinearGradient(
    colors: [Color(0xFF0A1628), Color(0xFF1A2F4E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient prayerCardGradient = LinearGradient(
    colors: [Color(0xFF0F9D58), Color(0xFF0D7A45)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
