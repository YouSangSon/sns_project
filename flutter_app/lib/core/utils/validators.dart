/// 폼 유효성 검사 유틸리티
abstract class Validators {
  /// 이메일 검사
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  /// 비밀번호 검사
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }
    return null;
  }

  /// 비밀번호 확인 검사
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (value != password) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  /// 사용자명 검사
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return '사용자명을 입력해주세요';
    }
    if (value.length < 3) {
      return '사용자명은 3자 이상이어야 합니다';
    }
    if (value.length > 20) {
      return '사용자명은 20자 이하여야 합니다';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return '영문, 숫자, 밑줄만 사용할 수 있습니다';
    }
    return null;
  }

  /// 이름 검사
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요';
    }
    if (value.length < 2) {
      return '이름은 2자 이상이어야 합니다';
    }
    return null;
  }

  /// 필수 입력 검사
  static String? required(String? value, [String fieldName = '필드']) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    return null;
  }

  /// 최소 길이 검사
  static String? minLength(String? value, int minLength, [String fieldName = '입력']) {
    if (value == null || value.isEmpty) {
      return null; // required 검사에서 처리
    }
    if (value.length < minLength) {
      return '$fieldName은(는) $minLength자 이상이어야 합니다';
    }
    return null;
  }

  /// 최대 길이 검사
  static String? maxLength(String? value, int maxLength, [String fieldName = '입력']) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > maxLength) {
      return '$fieldName은(는) $maxLength자 이하여야 합니다';
    }
    return null;
  }
}
