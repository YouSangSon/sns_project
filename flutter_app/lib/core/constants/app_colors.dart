import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 색상 상수
abstract class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF0095F6);
  static const Color primaryDark = Color(0xFF0074CC);
  static const Color primaryLight = Color(0xFF4DB5F9);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundGray = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFF2F2F7);

  // Text
  static const Color textPrimary = Color(0xFF262626);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color textLight = Color(0xFFFFFFFF);

  // Borders
  static const Color border = Color(0xFFDBDBDB);
  static const Color borderLight = Color(0xFFEFEFEF);
  static const Color divider = Color(0xFFE5E5EA);

  // Status
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFED4956);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  // Social
  static const Color like = Color(0xFFED4956);

  // Investment
  static const Color profit = Color(0xFF34C759);
  static const Color loss = Color(0xFFFF3B30);

  // Message Bubbles
  static const Color myMessage = Color(0xFF0095F6);
  static const Color otherMessage = Color(0xFFEFEFEF);
}
