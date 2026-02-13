import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF6366F1);
  static const secondaryColor = Color(0xFFFACC15);
  static const backgroundColor = Color(0xFFF8FAFC);
  static const surfaceColor = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      surface: surfaceColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: GoogleFonts.outfitTextTheme(),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E293B),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
  );

  static const List<Color> quizGradient = [
    Color(0xFF86EFAC),
    Color(0xFF4ADE80),
  ];
  static const List<Color> flashcardsGradient = [
    Color(0xFF93C5FD),
    Color(0xFF60A5FA),
  ];
  static const List<Color> createGradient = [
    Color(0xFFFDBA74),
    Color(0xFFFB923C),
  ];
}
