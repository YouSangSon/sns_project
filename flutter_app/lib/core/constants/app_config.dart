class AppConfig {
  AppConfig._();

  // API Configuration
  static const String baseUrl = 'http://localhost:8080';
  static const String prodBaseUrl = 'https://api.yoursns.com';
  static const Duration timeout = Duration(seconds: 30);

  // App Configuration
  static const String appName = 'SNS App';
  static const String version = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int postsPageSize = 10;
  static const int commentsPageSize = 20;
  static const int messagesPageSize = 50;

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // Dev Mode
  static const bool isDev = true;
}
