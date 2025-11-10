import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF405DE6);
  static const Color secondaryColor = Color(0xFFE1306C);

  // Light Theme Colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF262626);
  static const Color lightTextSecondary = Color(0xFF8E8E8E);
  static const Color lightBorder = Color(0xFFDBDBDB);

  // Dark Theme Colors
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFFA8A8A8);
  static const Color darkBorder = Color(0xFF262626);

  // Instagram Gradient
  static const LinearGradient instagramGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF405DE6),
      Color(0xFF5851DB),
      Color(0xFF833AB4),
      Color(0xFFC13584),
      Color(0xFFE1306C),
      Color(0xFFFD1D1D),
    ],
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,

    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightSurface,
      background: lightBackground,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightText,
      onBackground: lightText,
      onError: Colors.white,
    ),

    textTheme: GoogleFonts.robotoTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: lightText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: lightText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: lightTextSecondary,
        ),
      ),
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: lightBackground,
      foregroundColor: lightText,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: lightText,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Instagram',
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightBackground,
      selectedItemColor: lightText,
      unselectedItemColor: lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 1,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightText, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: lightBorder,
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurface,
      background: darkBackground,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkText,
      onBackground: darkText,
      onError: Colors.white,
    ),

    textTheme: GoogleFonts.robotoTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: darkText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: darkTextSecondary,
        ),
      ),
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: darkBackground,
      foregroundColor: darkText,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: darkText,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Instagram',
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBackground,
      selectedItemColor: darkText,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 1,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkText, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1,
      space: 1,
    ),
  );
}
