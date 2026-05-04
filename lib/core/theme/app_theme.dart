import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondary,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: _buildTextTheme(AppColors.textDark, AppColors.textMedium),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F4F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.outfit(
          color: AppColors.textLight,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8EFF0),
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textMedium, size: 24),
      extensions: const [NoorThemeExtension.light],
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: _buildTextTheme(AppColors.textWhite, AppColors.textWhiteMuted),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textWhite,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.outfit(
          color: AppColors.textWhiteMuted,
          fontSize: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E3045),
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textWhiteMuted, size: 24),
      extensions: const [NoorThemeExtension.dark],
    );
  }

  static ThemeData get ramadan {
    return dark.copyWith(
      scaffoldBackgroundColor: AppColors.ramadanBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.primary,
        surface: AppColors.ramadanSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ramadanBg,
        foregroundColor: AppColors.gold,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.ramadanCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      extensions: const [NoorThemeExtension.ramadan],
    );
  }
}

// Custom theme extension for Noor-specific design tokens
class NoorThemeExtension extends ThemeExtension<NoorThemeExtension> {
  final Color cardBorder;
  final Color shadowColor;
  final bool isRamadan;
  final Color accentColor;

  const NoorThemeExtension({
    required this.cardBorder,
    required this.shadowColor,
    required this.isRamadan,
    required this.accentColor,
  });

  static const light = NoorThemeExtension(
    cardBorder: Color(0xFFE8F5EE),
    shadowColor: Color(0x1A0F9D58),
    isRamadan: false,
    accentColor: AppColors.primary,
  );

  static const dark = NoorThemeExtension(
    cardBorder: Color(0xFF1E3045),
    shadowColor: Color(0x330F9D58),
    isRamadan: false,
    accentColor: AppColors.primary,
  );

  static const ramadan = NoorThemeExtension(
    cardBorder: Color(0xFF2A3F5E),
    shadowColor: Color(0x33D4AF37),
    isRamadan: true,
    accentColor: AppColors.gold,
  );

  @override
  NoorThemeExtension copyWith({
    Color? cardBorder,
    Color? shadowColor,
    bool? isRamadan,
    Color? accentColor,
  }) {
    return NoorThemeExtension(
      cardBorder: cardBorder ?? this.cardBorder,
      shadowColor: shadowColor ?? this.shadowColor,
      isRamadan: isRamadan ?? this.isRamadan,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  NoorThemeExtension lerp(NoorThemeExtension? other, double t) {
    if (other is! NoorThemeExtension) return this;
    return NoorThemeExtension(
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      isRamadan: t < 0.5 ? isRamadan : other.isRamadan,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
    );
  }
}
