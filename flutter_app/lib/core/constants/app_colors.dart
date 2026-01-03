import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF0095F6);
  static const Color primaryDark = Color(0xFF0074CC);
  static const Color primaryLight = Color(0xFF4DB5F9);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundGray = Color(0xFFFAFAFA);

  // Text
  static const Color text = Color(0xFF262626);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color textLight = Color(0xFFFFFFFF);

  // Borders
  static const Color border = Color(0xFFDBDBDB);
  static const Color borderLight = Color(0xFFEFEFEF);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFED4956);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Social
  static const Color like = Color(0xFFED4956);
  static const Color share = Color(0xFF0095F6);

  // Investment
  static const Color profit = Color(0xFF34C759);
  static const Color loss = Color(0xFFFF3B30);

  // Instagram Gradient
  static const List<Color> instagramGradient = [
    Color(0xFFF09433),
    Color(0xFFE6683C),
    Color(0xFFDC2743),
    Color(0xFFCC2366),
    Color(0xFFBC1888),
  ];

  // Message Bubbles
  static const Color myMessageBubble = Color(0xFF0095F6);
  static const Color otherMessageBubble = Color(0xFFEFEFEF);
}
