/// 앱 설정 상수
abstract class AppConfig {
  // App Info
  static const String appName = 'SNS App';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:8080';
  static const String prodBaseUrl = 'https://api.yoursns.com';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int postsPageSize = 10;
  static const int commentsPageSize = 20;
  static const int messagesPageSize = 50;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // Feature Flags
  static const bool isDevelopment = true;
  static const bool enableLogging = true;
}
