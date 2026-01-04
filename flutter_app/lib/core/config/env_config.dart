import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

/// 환경별 설정을 관리하는 클래스
/// config/dev.yaml, config/staging.yaml, config/prod.yaml 파일에서 설정을 로드합니다.
class EnvConfig {
  EnvConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.apiConnectionTimeout,
    required this.apiReceiveTimeout,
    required this.apiEnableLogging,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.supabaseServiceRoleKey,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.enableDebugMenu,
    required this.enableMockData,
    required this.defaultPageSize,
    required this.postsPageSize,
    required this.commentsPageSize,
    required this.messagesPageSize,
    required this.maxImageSizeMb,
    required this.allowedImageTypes,
    required this.imageCacheDurationDays,
    required this.apiCacheDurationMinutes,
    required this.appName,
    required this.appVersion,
    required this.supportEmail,
  });

  // 싱글톤 인스턴스
  static EnvConfig? _instance;
  static EnvConfig get instance {
    if (_instance == null) {
      throw Exception(
        'EnvConfig가 초기화되지 않았습니다. '
        'main() 함수에서 EnvConfig.initialize()를 먼저 호출하세요.',
      );
    }
    return _instance!;
  }

  // Environment
  final String environment;

  // API Configuration
  final String apiBaseUrl;
  final int apiConnectionTimeout;
  final int apiReceiveTimeout;
  final bool apiEnableLogging;

  // Supabase
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String supabaseServiceRoleKey;

  // Feature Flags
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool enableDebugMenu;
  final bool enableMockData;

  // Pagination
  final int defaultPageSize;
  final int postsPageSize;
  final int commentsPageSize;
  final int messagesPageSize;

  // Storage
  final int maxImageSizeMb;
  final List<String> allowedImageTypes;

  // Cache
  final int imageCacheDurationDays;
  final int apiCacheDurationMinutes;

  // App Settings
  final String appName;
  final String appVersion;
  final String supportEmail;

  // Timeout Durations
  Duration get connectionTimeout => Duration(seconds: apiConnectionTimeout);
  Duration get receiveTimeout => Duration(seconds: apiReceiveTimeout);
  Duration get imageCacheDuration => Duration(days: imageCacheDurationDays);
  Duration get apiCacheDuration => Duration(minutes: apiCacheDurationMinutes);

  // Environment Checks
  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';
  bool get isProduction => environment == 'production';

  /// 환경별 설정 파일을 로드하여 초기화
  /// [env]는 'dev', 'staging', 'prod' 중 하나
  static Future<void> initialize({String env = 'dev'}) async {
    try {
      final configFile = 'config/$env.yaml';
      final yamlString = await rootBundle.loadString(configFile);
      final yamlMap = loadYaml(yamlString) as YamlMap;

      _instance = EnvConfig._(
        environment: yamlMap['environment'] as String,

        // API
        apiBaseUrl: yamlMap['api']['base_url'] as String,
        apiConnectionTimeout: yamlMap['api']['connection_timeout'] as int,
        apiReceiveTimeout: yamlMap['api']['receive_timeout'] as int,
        apiEnableLogging: yamlMap['api']['enable_logging'] as bool,

        // Supabase
        supabaseUrl: yamlMap['supabase']['url'] as String,
        supabaseAnonKey: yamlMap['supabase']['anon_key'] as String,
        supabaseServiceRoleKey: yamlMap['supabase']['service_role_key'] as String,

        // Features
        enableAnalytics: yamlMap['features']['enable_analytics'] as bool,
        enableCrashReporting: yamlMap['features']['enable_crash_reporting'] as bool,
        enableDebugMenu: yamlMap['features']['enable_debug_menu'] as bool,
        enableMockData: yamlMap['features']['enable_mock_data'] as bool,

        // Pagination
        defaultPageSize: yamlMap['pagination']['default_page_size'] as int,
        postsPageSize: yamlMap['pagination']['posts_page_size'] as int,
        commentsPageSize: yamlMap['pagination']['comments_page_size'] as int,
        messagesPageSize: yamlMap['pagination']['messages_page_size'] as int,

        // Storage
        maxImageSizeMb: yamlMap['storage']['max_image_size_mb'] as int,
        allowedImageTypes: (yamlMap['storage']['allowed_image_types'] as YamlList)
            .map((e) => e as String)
            .toList(),

        // Cache
        imageCacheDurationDays: yamlMap['cache']['image_cache_duration_days'] as int,
        apiCacheDurationMinutes: yamlMap['cache']['api_cache_duration_minutes'] as int,

        // App
        appName: yamlMap['app']['name'] as String,
        appVersion: yamlMap['app']['version'] as String,
        supportEmail: yamlMap['app']['support_email'] as String,
      );

      print('✅ EnvConfig initialized: ${_instance!.environment}');
      print('   API Base URL: ${_instance!.apiBaseUrl}');
      print('   Mock Data: ${_instance!.enableMockData}');
    } catch (e) {
      throw Exception('Failed to load config file: $e');
    }
  }

  /// 설정 정보를 출력 (디버깅용)
  void printConfig() {
    print('=== Environment Configuration ===');
    print('Environment: $environment');
    print('API Base URL: $apiBaseUrl');
    print('Supabase URL: $supabaseUrl');
    print('Enable Analytics: $enableAnalytics');
    print('Enable Mock Data: $enableMockData');
    print('Enable Debug Menu: $enableDebugMenu');
    print('================================');
  }
}
