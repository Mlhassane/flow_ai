import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Palette
  static const primaryBlue = Color(0xFF6366F1); // Indigo
  static const secondaryGold = Color(0xFFFACC15); // Sahel Gold
  
  // Neutral Palette
  static const lightBg = Color(0xFFF8FAFC);
  static const darkBg = Color(0xFF0F172A);
  static const surfaceDark = Color(0xFF1E293B);
  static const surfaceLight = Colors.white;
  
  // Accents & Status
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  
  // Gradients
  static const List<Color> primaryGradient = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> goldGradient = [Color(0xFFF59E0B), Color(0xFFFACC15)];
}

class AppTheme {
  static const primaryColor = AppColors.primaryBlue;
  static const secondaryColor = AppColors.secondaryGold;
  static const backgroundColor = AppColors.lightBg;
  static const surfaceColor = AppColors.surfaceLight;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      surface: surfaceColor,
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: GoogleFonts.outfitTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );

  // Helper Gradients for the UI
  static const List<Color> quizGradient = AppColors.primaryGradient;
  static const List<Color> flashcardsGradient = [
    Color(0xFF3B82F6),
    Color(0xFF60A5FA),
  ];
  static const List<Color> createGradient = AppColors.goldGradient;
}
