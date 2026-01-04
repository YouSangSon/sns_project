# 테스트 가이드

이 디렉토리는 SNS App의 모든 테스트 파일을 포함합니다.

## 📁 디렉토리 구조

```
test/
├── features/                    # Feature별 테스트
│   ├── auth/                    # 인증 Feature
│   │   ├── domain/              # Domain Layer 테스트
│   │   │   ├── entities/        # Entity 테스트
│   │   │   ├── repositories/    # Repository 인터페이스 테스트
│   │   │   └── usecases/        # UseCase 테스트
│   │   ├── data/                # Data Layer 테스트
│   │   │   ├── datasources/     # DataSource 테스트
│   │   │   ├── models/          # Model 테스트
│   │   │   └── repositories/    # Repository 구현 테스트
│   │   └── presentation/        # Presentation Layer 테스트
│   │       ├── providers/       # Provider 테스트
│   │       ├── pages/           # Page 위젯 테스트
│   │       └── widgets/         # Widget 테스트
│   ├── feed/                    # 피드 Feature
│   ├── post/                    # 게시물 Feature
│   └── profile/                 # 프로필 Feature
│
├── helpers/                     # 테스트 헬퍼
│   ├── test_helper.dart         # 공통 테스트 유틸리티
│   └── test_data.dart           # Mock 데이터
│
└── mocks/                       # Mock 클래스
```

## 🧪 테스트 실행

### 모든 테스트 실행

```bash
flutter test
```

### 특정 테스트 실행

```bash
# 특정 파일
flutter test test/features/auth/domain/usecases/login_usecase_test.dart

# 특정 디렉토리
flutter test test/features/auth/

# 이름으로 필터링
flutter test --name "LoginUseCase"
```

### 커버리지 포함

```bash
# 커버리지 생성
flutter test --coverage

# 커버리지 리포트 보기 (macOS/Linux)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Windows
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html
```

### 감시 모드

```bash
# 파일 변경 시 자동 테스트 실행
flutter test --watch
```

## 📝 테스트 작성 가이드

### 1. UseCase 테스트

**위치**: `test/features/{feature}/domain/usecases/`

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([YourRepository])
void main() {
  late YourUseCase useCase;
  late MockYourRepository mockRepository;

  setUp(() {
    mockRepository = MockYourRepository();
    useCase = YourUseCase(mockRepository);
  });

  group('YourUseCase', () {
    test('성공 케이스', () async {
      // Arrange
      when(mockRepository.someMethod())
          .thenAnswer((_) async => Right(expectedResult));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right(expectedResult));
      verify(mockRepository.someMethod()).called(1);
    });

    test('실패 케이스', () async {
      // Arrange
      final failure = Failure.server(message: 'Error');
      when(mockRepository.someMethod())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Left(failure));
    });
  });
}
```

### 2. Model 테스트

**위치**: `test/features/{feature}/data/models/`

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YourModel', () {
    test('fromJson으로 올바르게 파싱되어야 한다', () {
      // Arrange
      final json = {'id': '123', 'name': 'Test'};

      // Act
      final model = YourModel.fromJson(json);

      // Assert
      expect(model.id, '123');
      expect(model.name, 'Test');
    });

    test('toJson으로 올바르게 직렬화되어야 한다', () {
      // Arrange
      final model = YourModel(id: '123', name: 'Test');

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], '123');
      expect(json['name'], 'Test');
    });

    test('toEntity로 Entity로 변환되어야 한다', () {
      // Arrange
      final model = YourModel(id: '123', name: 'Test');

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity, isA<YourEntity>());
      expect(entity.id, model.id);
    });
  });
}
```

### 3. Widget 테스트

**위치**: `test/features/{feature}/presentation/widgets/`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  group('YourWidget', () {
    testWidgets('렌더링 테스트', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestableWidget(
          child: YourWidget(data: testData),
        ),
      );

      // Assert
      expect(find.byType(YourWidget), findsOneWidget);
      expect(find.text('Expected Text'), findsOneWidget);
    });

    testWidgets('버튼 클릭 테스트', (WidgetTester tester) async {
      // Arrange
      var clicked = false;
      await tester.pumpWidget(
        createTestableWidget(
          child: YourWidget(
            onTap: () => clicked = true,
          ),
        ),
      );

      // Act
      await tapButton(tester, find.byType(ElevatedButton));

      // Assert
      expect(clicked, true);
    });
  });
}
```

### 4. Provider 테스트

**위치**: `test/features/{feature}/presentation/providers/`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/test_helper.dart';

@GenerateMocks([YourUseCase])
void main() {
  late MockYourUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockYourUseCase();
  });

  group('YourProvider', () {
    test('초기 상태는 initial이어야 한다', () {
      // Arrange
      final container = createContainer(
        overrides: [
          yourUseCaseProvider.overrideWithValue(mockUseCase),
        ],
      );

      // Act
      final state = container.read(yourProvider);

      // Assert
      expect(state, const YourState.initial());
    });

    test('성공 시 loaded 상태가 되어야 한다', () async {
      // Arrange
      when(mockUseCase()).thenAnswer((_) async => Right(testData));

      final container = createContainer(
        overrides: [
          yourUseCaseProvider.overrideWithValue(mockUseCase),
        ],
      );

      // Act
      await container.read(yourProvider.notifier).loadData();

      // Assert
      final state = container.read(yourProvider);
      expect(state, YourState.loaded(testData));
    });
  });
}
```

## 🔨 Mock 생성

### Mockito 사용

1. **테스트 파일에 어노테이션 추가:**

```dart
import 'package:mockito/annotations.dart';

@GenerateMocks([YourRepository, YourDataSource])
void main() {
  // 테스트 코드
}
```

2. **Mock 생성:**

```bash
flutter pub run build_runner build
```

3. **생성된 Mock 임포트:**

```dart
import 'your_test_file.mocks.dart';
```

## 📊 테스트 커버리지 목표

- **Overall**: 80% 이상
- **Domain Layer**: 90% 이상 (비즈니스 로직)
- **Data Layer**: 80% 이상
- **Presentation Layer**: 70% 이상

## 💡 모범 사례

### 1. AAA 패턴 사용

```dart
test('description', () {
  // Arrange: 테스트 준비
  final input = 'test';

  // Act: 테스트 실행
  final result = functionUnderTest(input);

  // Assert: 검증
  expect(result, expectedOutput);
});
```

### 2. 명확한 테스트 이름

```dart
// 좋은 예
test('로그인 성공 시 UserEntity를 반환해야 한다', () { ... });
test('이메일이 비어있으면 ValidationFailure를 반환해야 한다', () { ... });

// 나쁜 예
test('test1', () { ... });
test('works', () { ... });
```

### 3. Given-When-Then 주석

```dart
test('사용자가 로그인하면 홈 화면으로 이동해야 한다', () async {
  // Given: 유효한 자격 증명
  final email = 'test@example.com';
  final password = 'password';

  // When: 로그인 실행
  await loginUseCase(email: email, password: password);

  // Then: 홈 화면으로 이동
  expect(find.byType(HomePage), findsOneWidget);
});
```

### 4. 테스트 격리

```dart
setUp(() {
  // 각 테스트 전에 실행
  mockRepository = MockRepository();
});

tearDown(() {
  // 각 테스트 후에 실행
  mockRepository.dispose();
});
```

## 🐛 일반적인 문제 해결

### 1. "Missing stub" 오류

**원인**: Mock에 when() 설정을 하지 않음

**해결**:
```dart
when(mockRepository.method()).thenAnswer((_) async => result);
```

### 2. "Called from" 오류

**원인**: setUp()에서 비동기 작업을 동기로 처리

**해결**:
```dart
setUp(() async {
  await initializeService();
});
```

### 3. Widget 테스트 타임아웃

**해결**:
```dart
testWidgets('test', (tester) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle(const Duration(seconds: 5));
});
```

## 📚 추가 자료

- [Flutter 테스트 문서](https://docs.flutter.dev/testing)
- [Mockito 문서](https://pub.dev/packages/mockito)
- [Riverpod 테스트 가이드](https://riverpod.dev/docs/cookbooks/testing)

---

**Happy Testing! 🧪**
