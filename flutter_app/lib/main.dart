import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/network/dio_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 모바일에서만 방향 고정 (웹에서는 불필요)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // 시스템 UI 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 서비스 초기화
  await _initializeServices();

  runApp(
    const ProviderScope(
      child: SNSApp(),
    ),
  );
}

Future<void> _initializeServices() async {
  // Dio 클라이언트 초기화
  DioClient.instance.init();

  // 웹 전용 초기화
  if (kIsWeb) {
    _initializeWebPlatform();
  }

  // 기타 초기화 (Firebase 등)
}

/// 웹 플랫폼 초기화
void _initializeWebPlatform() {
  // 웹 전용 설정
  // - URL strategy 설정은 url_strategy 패키지로 처리 가능
  // - 브라우저 히스토리 관리
  debugPrint('SNS App initialized for Web platform');
}
