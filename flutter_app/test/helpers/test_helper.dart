import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트용 ProviderScope를 생성하는 헬퍼 함수
ProviderContainer createContainer({
  List<Override> overrides = const [],
  ProviderContainer? parent,
}) {
  final container = ProviderContainer(
    overrides: overrides,
    parent: parent,
  );

  addTearDown(container.dispose);

  return container;
}

/// Widget 테스트를 위한 ProviderScope 래핑 헬퍼
Widget createProviderScopeWidget({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

/// 테스트용 Navigator를 포함한 Widget 래핑
Widget createTestableWidget({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

/// 비동기 테스트를 위한 pump 헬퍼
Future<void> pumpAndSettleWithDelay(
  WidgetTester tester, {
  Duration delay = const Duration(milliseconds: 100),
}) async {
  await tester.pump(delay);
  await tester.pumpAndSettle();
}

/// 텍스트 필드에 값을 입력하는 헬퍼
Future<void> enterText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pump();
}

/// 버튼을 탭하는 헬퍼
Future<void> tapButton(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
