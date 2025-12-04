import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00D9FF), // Cyan blue from Cloqr icon
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFF0A1628), // Dark blue background
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF0A1628),
      foregroundColor: Colors.white,
    ),
  );

  static const primaryColor = Color(0xFF00D9FF); // Cyan blue
  static const secondaryColor = Color(0xFF7B61FF); // Purple from gradient
  static const backgroundColor = Color(0xFF0A1628); // Dark navy
  static const dangerColor = Color(0xFFE53935);
  static const warningColor = Color(0xFFFFA726);
}
