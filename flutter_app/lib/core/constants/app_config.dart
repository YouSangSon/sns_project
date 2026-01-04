import '../config/env_config.dart';

/// 앱 설정 상수
/// 환경별 설정은 EnvConfig에서 가져오고, 앱 전체에서 사용되는 상수는 여기에 정의합니다.
abstract class AppConfig {
  // EnvConfig에서 가져오는 설정들
  static String get appName => EnvConfig.instance.appName;
  static String get appVersion => EnvConfig.instance.appVersion;
  static String get baseUrl => EnvConfig.instance.apiBaseUrl;
  static Duration get connectionTimeout => EnvConfig.instance.connectionTimeout;
  static Duration get receiveTimeout => EnvConfig.instance.receiveTimeout;
  static int get defaultPageSize => EnvConfig.instance.defaultPageSize;
  static int get postsPageSize => EnvConfig.instance.postsPageSize;
  static int get commentsPageSize => EnvConfig.instance.commentsPageSize;
  static int get messagesPageSize => EnvConfig.instance.messagesPageSize;
  static bool get isDevelopment => EnvConfig.instance.isDevelopment;
  static bool get enableLogging => EnvConfig.instance.apiEnableLogging;

  // Storage Keys (환경과 무관한 상수)
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
