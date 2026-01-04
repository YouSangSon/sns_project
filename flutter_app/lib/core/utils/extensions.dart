import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DateTime 확장
extension DateTimeExtension on DateTime {
  /// 상대적 시간 표시 (예: 방금 전, 5분 전, 어제)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else {
      return '${(difference.inDays / 365).floor()}년 전';
    }
  }

  /// 날짜 포맷 (예: 2024년 1월 15일)
  String get formatted => DateFormat('yyyy년 M월 d일').format(this);

  /// 짧은 날짜 포맷 (예: 1월 15일)
  String get shortFormatted => DateFormat('M월 d일').format(this);

  /// 시간 포맷 (예: 오후 3:30)
  String get timeFormatted => DateFormat('a h:mm', 'ko').format(this);
}

/// String 확장
extension StringExtension on String {
  /// 첫 글자 대문자
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 이메일 유효성 검사
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// 비밀번호 유효성 검사 (8자 이상)
  bool get isValidPassword => length >= 8;

  /// 사용자명 유효성 검사 (3-20자, 영문/숫자/밑줄)
  bool get isValidUsername {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(this);
  }
}

/// int 확장
extension IntExtension on int {
  /// 숫자 포맷 (예: 1,234)
  String get formatted => NumberFormat('#,###').format(this);

  /// 축약 숫자 (예: 1.2K, 3.5M)
  String get abbreviated {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}

/// double 확장
extension DoubleExtension on double {
  /// 퍼센트 포맷 (예: +5.25%, -3.50%)
  String get percentFormatted {
    final prefix = this >= 0 ? '+' : '';
    return '$prefix${toStringAsFixed(2)}%';
  }

  /// 통화 포맷 (예: ₩1,234,567)
  String get currencyFormatted {
    return NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(this);
  }
}

/// BuildContext 확장
extension BuildContextExtension on BuildContext {
  /// 테마 접근
  ThemeData get theme => Theme.of(this);

  /// 텍스트 테마 접근
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// 색상 스킴 접근
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// 미디어 쿼리 접근
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// 화면 크기
  Size get screenSize => mediaQuery.size;

  /// 화면 너비
  double get screenWidth => screenSize.width;

  /// 화면 높이
  double get screenHeight => screenSize.height;

  /// 스낵바 표시
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
