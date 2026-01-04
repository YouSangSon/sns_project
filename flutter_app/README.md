# SNS Flutter App

Flutter와 Clean Architecture로 구현한 소셜 네트워크 서비스 앱입니다.
**모바일(iOS/Android)과 웹을 단일 코드베이스로 지원합니다.**

## 🏗️ 아키텍처

**Feature-first Clean Architecture** 패턴을 적용하여 확장성과 유지보수성을 극대화했습니다.

```
lib/
├── core/                           # 핵심 공통 모듈
│   ├── constants/                  # 상수 (색상, 설정, API 엔드포인트)
│   ├── errors/                     # 에러 처리 (Failure, Exception)
│   ├── network/                    # 네트워크 (Dio, Router, Interceptors)
│   ├── responsive/                 # 반응형 유틸리티 (웹/태블릿/모바일)
│   └── utils/                      # 유틸리티 (Extensions, Validators)
│
├── features/                       # Feature 모듈 (Feature-first)
│   ├── auth/                       # 인증
│   ├── feed/                       # 피드
│   ├── post/                       # 게시물
│   ├── profile/                    # 프로필
│   ├── messages/                   # 메시지
│   ├── search/                     # 검색
│   ├── notifications/              # 알림
│   ├── investment/                 # 투자 포트폴리오
│   └── stories/                    # 스토리
│
├── shared/                         # 공유 모듈
│   ├── providers/                  # DI Providers (Riverpod)
│   └── widgets/                    # 공통 위젯
│       └── web/                    # 웹 전용 위젯
│
└── web/                            # Flutter 웹 설정
    ├── index.html
    └── manifest.json
```

### Feature 모듈 구조 (Clean Architecture)

각 Feature는 Domain, Data, Presentation 3개 레이어로 구성됩니다:

```
feature/
├── domain/                         # 비즈니스 로직 (순수 Dart)
│   ├── entities/                   # Entity 클래스 (freezed)
│   ├── repositories/               # Repository 인터페이스
│   └── usecases/                   # UseCase 클래스
│
├── data/                           # 데이터 접근
│   ├── datasources/                # Remote/Local DataSource
│   ├── models/                     # DTO (freezed + json_serializable)
│   └── repositories/               # Repository 구현체
│
└── presentation/                   # UI
    ├── providers/                  # Riverpod StateNotifier
    ├── pages/                      # 화면
    └── widgets/                    # 위젯
```

## 🚀 기술 스택

| 카테고리 | 기술 |
|---------|-----|
| **Framework** | Flutter 3.x |
| **Language** | Dart 3.x |
| **Platforms** | iOS, Android, Web |
| **State Management** | Riverpod + riverpod_annotation |
| **Navigation** | Go Router |
| **HTTP Client** | Dio |
| **Code Generation** | freezed + json_serializable |
| **Error Handling** | dartz (Either type) |
| **Storage** | flutter_secure_storage, shared_preferences |
| **Image** | cached_network_image |

## 📦 주요 패키지

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  go_router: ^13.1.0
  dio: ^5.4.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  dartz: ^0.10.1
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  intl: ^0.18.1

dev_dependencies:
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8
```

## 📱 주요 기능

### 핵심 SNS 기능
- **인증**: 로그인, 회원가입, 자동 토큰 갱신
- **피드**: 무한 스크롤, Pull to Refresh
- **게시물**: CRUD, 이미지 업로드, 좋아요, 댓글, 북마크
- **프로필**: 조회/편집, 팔로우/언팔로우
- **검색**: 사용자/게시물/해시태그 검색
- **메시지**: 1:1 채팅, 대화 목록
- **알림**: 실시간 알림 피드
- **스토리**: 24시간 제한 스토리

### 투자 SNS
- **포트폴리오**: CRUD, 수익률 분석
- **보유 종목**: 추가/수정/삭제
- **자산 검색**: 주식/ETF/암호화폐

## 🎨 반응형 디자인

단일 코드베이스로 모바일/태블릿/데스크톱 지원

### 브레이크포인트

| 디바이스 | 너비 | 레이아웃 |
|---------|-----|---------|
| 모바일 | 0 - 599px | 하단 네비게이션 |
| 태블릿 | 600 - 1023px | 축소된 사이드바 (아이콘만) |
| 데스크톱 | 1024 - 1439px | 확장된 사이드바 |
| 대형 데스크톱 | 1440px+ | 사이드바 + 우측 패널 |

### ResponsiveBuilder 사용

```dart
import 'core/responsive/responsive.dart';

ResponsiveBuilder(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

### Context Extensions

```dart
// 디바이스 타입 확인
if (context.isMobile) { ... }
if (context.isTablet) { ... }
if (context.isDesktop) { ... }

// 반응형 값 선택
final padding = context.responsive<double>(
  mobile: 16,
  tablet: 24,
  desktop: 32,
);
```

### AdaptiveNavigationShell

플랫폼에 따라 자동으로 네비게이션 레이아웃 전환:
- **모바일**: 하단 네비게이션 바
- **태블릿**: 축소된 사이드바 (아이콘만)
- **데스크톱**: 확장된 사이드바 + 우측 추천 패널

## 🔧 설치 및 실행

### 1. Flutter 설치
```bash
# Flutter SDK 설치 후
flutter doctor
```

### 2. 프로젝트 설정
```bash
cd flutter_app

# 의존성 설치
flutter pub get

# 코드 생성 (freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. 앱 실행
```bash
# 웹 (Chrome)
flutter run -d chrome

# iOS
flutter run -d ios

# Android
flutter run -d android

# 디바이스 목록 확인
flutter devices
```

### 4. 빌드
```bash
# 웹 빌드
flutter build web --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS 필요)
flutter build ios --release
```

## 🏛️ 아키텍처 상세

### Domain Layer (비즈니스 로직)

**순수 Dart로 작성**, Flutter 의존성 없음

```dart
// Entity (freezed)
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required String username,
  }) = _UserEntity;
}

// Repository Interface
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
}

// UseCase
class LoginUseCase {
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) => _repository.login(email: email, password: password);
}
```

### Data Layer (데이터 접근)

**DTO 변환 및 API 통신**

```dart
// Model (DTO)
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    @JsonKey(name: 'user_name') required String username,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // Entity 변환
  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    username: username,
  );
}

// Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(response.user.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    }
  }
}
```

### Presentation Layer (UI)

**Riverpod으로 상태 관리**

```dart
// Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) => state = AuthState.error(failure.errorMessage),
      (user) => state = AuthState.authenticated(user),
    );
  }
}

// Page
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      initial: () => _buildLoginForm(),
      loading: () => const CircularProgressIndicator(),
      authenticated: (user) => const FeedPage(),
      error: (message) => Text(message),
    );
  }
}
```

## 🔐 에러 처리

**dartz Either 타입**으로 함수형 에러 처리:

```dart
// Failure 정의 (freezed)
@freezed
class Failure with _$Failure {
  const factory Failure.server({required String message}) = ServerFailure;
  const factory Failure.network() = NetworkFailure;
  const factory Failure.auth() = AuthFailure;
}

// 사용
final result = await repository.login(...);

result.fold(
  (failure) => failure.when(
    server: (msg) => showError(msg),
    network: () => showError('네트워크 연결 확인'),
    auth: () => showError('인증 필요'),
  ),
  (user) => navigateToHome(),
);
```

## 🔄 DI (Dependency Injection)

**Riverpod Provider**로 의존성 주입:

```dart
// di_providers.dart
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});
```

## 🧪 테스트

```bash
# 단위 테스트
flutter test

# 특정 파일 테스트
flutter test test/features/auth/domain/usecases/login_usecase_test.dart

# 커버리지
flutter test --coverage
```

## 📝 코드 생성

freezed, json_serializable 코드 생성:

```bash
# 일회성 빌드
flutter pub run build_runner build --delete-conflicting-outputs

# 감시 모드 (파일 변경 시 자동 빌드)
flutter pub run build_runner watch
```

## 🎨 디자인 시스템

- **테마**: Light/Dark 모드 지원
- **색상**: Instagram 스타일 (Primary Blue, Gradient)
- **타이포그래피**: Material 3 Text Theme
- **아이콘**: Material Icons
- **반응형**: 모바일/태블릿/데스크톱 적응형 레이아웃

## 📄 라이선스

이 프로젝트는 학습 목적으로 제작되었습니다.
