import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Tech Palette
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo 600
  static const Color secondaryColor = Color(0xFF818CF8); // Indigo 400
  static const Color accentColor = Color(0xFF6366F1); // Indigo 500
  
  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color successColor = Color(0xFF10B981); // Emerald 500
  static const Color warningColor = Color(0xFFF59E0B); // Amber 500
  
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Colors.white;
  static const Color textLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  static TextTheme _buildTextTheme(TextTheme base, Color textColor, Color secondaryColor) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.inter(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      headlineMedium: GoogleFonts.inter(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleLarge: GoogleFonts.inter(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyLarge: GoogleFonts.inter(
        color: textColor,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: secondaryColor,
        fontSize: 14,
      ),
      labelLarge: GoogleFonts.inter(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundLight,
    textTheme: _buildTextTheme(ThemeData.light().textTheme, textLight, textSecondaryLight),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceLight,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textLight,
      onError: Colors.white,
      tertiary: accentColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: textLight,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: textLight),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: TextStyle(color: textSecondaryLight),
      hintStyle: TextStyle(color: textSecondaryLight.withValues(alpha: 0.7)),
    ),
    iconTheme: const IconThemeData(
      color: textLight,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundDark,
    textTheme: _buildTextTheme(ThemeData.dark().textTheme, textDark, textSecondaryDark),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceDark,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
      onError: Colors.white,
      tertiary: accentColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: textDark),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade800),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: TextStyle(color: textSecondaryDark),
      hintStyle: TextStyle(color: textSecondaryDark.withValues(alpha: 0.7)),
    ),
    iconTheme: const IconThemeData(
      color: textDark,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
      thickness: 1,
    ),
  );
}
