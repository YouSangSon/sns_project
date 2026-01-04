# SNS App - Modern Social Media Platform

**풀스택 소셜 네트워크 서비스** 애플리케이션입니다.

## 🏗️ 아키텍처

- **Frontend**: Flutter (Clean Architecture) + Dart - 모바일 & 웹 통합
- **Backend**:
  - Supabase (PostgreSQL + Auth + Storage) - 추천
  - Kotlin + Spring Boot 3 REST API ([YouSangSon/rest_server](https://github.com/YouSangSon/rest_server))
- **State Management**: Riverpod + dartz (Either)
- **Navigation**: Go Router

## 🌐 지원 플랫폼

**단일 Flutter 코드베이스로 모든 플랫폼 지원!**

- **Web** (Chrome, Safari, Edge, Firefox) - Flutter Web
- **Android** (API 21+) - Flutter
- **iOS** (iOS 12.0+) - Flutter
- **반응형 디자인** (모바일, 태블릿, 데스크톱)

## 📱 주요 기능

### 구현 완료

#### 핵심 SNS 기능
- **사용자 인증**
  - 이메일/비밀번호 회원가입 및 로그인
  - JWT 기반 인증
  - 자동 토큰 갱신
  - 프로필 설정 및 편집

- **홈 피드**
  - 팔로우한 사용자들의 게시물 타임라인
  - 무한 스크롤
  - Pull to Refresh

- **게시물 관리**
  - 사진 업로드 (최대 10장)
  - 캡션 작성
  - 해시태그 지원
  - 게시물 수정/삭제

- **상호작용**
  - 좋아요/좋아요 취소 (Optimistic UI)
  - 댓글 작성, 수정, 삭제
  - 대댓글 (답글) 기능
  - 북마크 저장

- **프로필**
  - 사용자 프로필 조회
  - 게시물 그리드 뷰 (3열)
  - 팔로워/팔로잉 통계
  - 프로필 편집

- **검색 및 탐색**
  - 사용자 검색 (디바운싱)
  - 실시간 검색 결과

- **팔로우 시스템**
  - 팔로우/언팔로우
  - 팔로워/팔로잉 목록

- **알림 (Notifications)**
  - 실시간 알림 피드
  - 좋아요/댓글/팔로우 알림
  - 읽음/읽지 않음 상태

- **다이렉트 메시지 (Messages)**
  - 1:1 채팅
  - 대화 목록
  - 읽음 상태 표시

- **스토리 (Stories)**
  - 24시간 제한 스토리
  - 풀스크린 뷰어
  - 자동 진행 (5초)

- **릴스 (Reels)**
  - 세로 스크롤 피드
  - 좋아요, 댓글, 공유

#### 투자 SNS (Investment Social Network)

- **포트폴리오 관리**
  - 포트폴리오 CRUD
  - 공개/비공개 설정
  - 수익률 계산

- **자산 보유 (Holdings)**
  - 보유 종목 추가/수정/삭제
  - 주식, 암호화폐, ETF 지원

- **관심종목 (Watchlist)**
  - 관심 종목 관리
  - 목표가 설정

- **투자 포스트**
  - 투자 아이디어 공유
  - Bullish/Bearish 투표

## 🛠 기술 스택

### Frontend (Flutter - Mobile & Web 통합)
- **Flutter 3.x** - 크로스 플랫폼 프레임워크
- **Dart 3.x** - 프로그래밍 언어
- **Clean Architecture** - Feature-first 구조
- **Riverpod** - 상태 관리 + DI
- **Go Router** - 네비게이션
- **Dio** - HTTP 클라이언트
- **freezed + json_serializable** - 코드 생성
- **dartz** - 함수형 에러 처리 (Either)
- **flutter_secure_storage** - 보안 저장소

### 반응형 디자인
- **Breakpoints** - 모바일/태블릿/데스크톱
- **ResponsiveBuilder** - 적응형 레이아웃
- **AdaptiveNavigation** - 플랫폼별 네비게이션
  - 모바일: 하단 네비게이션 바
  - 태블릿: 축소된 사이드바
  - 데스크톱: 확장된 사이드바 + 우측 패널

### Backend
- **Kotlin** - 프로그래밍 언어
- **Spring Boot 3** - REST API 프레임워크
- **PostgreSQL** - 관계형 데이터베이스
- **JWT** - 인증 토큰

### 주요 패키지

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
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7

dev_dependencies:
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8
```

## 📁 프로젝트 구조

```
sns_project/
├── flutter_app/                     # Flutter 앱 (Mobile + Web)
│   ├── lib/
│   │   ├── core/                    # 핵심 공통 모듈
│   │   │   ├── constants/           # 상수 (색상, 설정, API)
│   │   │   ├── errors/              # Failure, Exception
│   │   │   ├── network/             # Dio, Router, Interceptors
│   │   │   ├── responsive/          # 반응형 유틸리티
│   │   │   └── utils/               # Extensions, Validators
│   │   │
│   │   ├── features/                # Feature 모듈 (Clean Architecture)
│   │   │   ├── auth/                # 인증
│   │   │   │   ├── domain/          # entities, repositories, usecases
│   │   │   │   ├── data/            # datasources, models, repositories impl
│   │   │   │   └── presentation/    # providers, pages, widgets
│   │   │   ├── feed/                # 피드
│   │   │   ├── post/                # 게시물
│   │   │   ├── profile/             # 프로필
│   │   │   ├── messages/            # 메시지
│   │   │   ├── search/              # 검색
│   │   │   ├── notifications/       # 알림
│   │   │   ├── investment/          # 투자
│   │   │   └── stories/             # 스토리
│   │   │
│   │   └── shared/                  # 공유 모듈
│   │       ├── providers/           # DI Providers
│   │       └── widgets/             # 공통 위젯
│   │           └── web/             # 웹 전용 위젯
│   │
│   └── web/                         # Flutter 웹 설정
│       ├── index.html
│       └── manifest.json
│
├── mobile/                          # React Native 앱 (레거시)
└── web-app/                         # Next.js 웹 앱 (레거시)
```

## 🚀 시작하기

### 사전 준비

- Flutter SDK 3.x
- Dart SDK 3.x
- Chrome (웹 개발용)
- Android Studio / Xcode (모바일 개발 시)
- **백엔드**:
  - Supabase 계정 (무료, 추천) - [가입하기](https://supabase.com)
  - 또는 백엔드 API 서버 ([YouSangSon/rest_server](https://github.com/YouSangSon/rest_server))

### 1. 저장소 클론

```bash
git clone https://github.com/YouSangSon/sns_project.git
cd sns_project
```

### 2. 패키지 설치

```bash
cd flutter_app
flutter pub get

# 코드 생성 (freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. 앱 실행

```bash
# 웹 (Chrome)
flutter run -d chrome

# iOS 시뮬레이터 (macOS only)
flutter run -d ios

# Android 에뮬레이터
flutter run -d android

# 연결된 디바이스 목록 확인
flutter devices
```

### 4. 테스트 계정

```
이메일: test@example.com
비밀번호: Test123!@#
사용자명: testuser
```

### 5. 빌드

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

## 🎨 반응형 디자인

### 브레이크포인트

| 디바이스 | 너비 | 레이아웃 |
|---------|-----|---------|
| 모바일 | 0 - 599px | 하단 네비게이션 |
| 태블릿 | 600 - 1023px | 축소된 사이드바 |
| 데스크톱 | 1024 - 1439px | 확장된 사이드바 |
| 대형 데스크톱 | 1440px+ | 사이드바 + 우측 패널 |

### ResponsiveBuilder 사용

```dart
ResponsiveBuilder(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

### Context Extensions

```dart
// 디바이스 타입 확인
context.isMobile
context.isTablet
context.isDesktop

// 반응형 값
context.responsive<double>(
  mobile: 16,
  tablet: 24,
  desktop: 32,
)
```

## 🔐 보안

- **JWT Authentication**: Access token + Refresh token
- **Token Auto-refresh**: Dio interceptor로 자동 갱신
- **Secure Storage**: flutter_secure_storage
- **HTTPS**: Production 환경에서 필수

## 📊 성능 최적화

- **상태 캐싱**: Riverpod 캐싱
- **Infinite Scroll**: 효율적인 페이지네이션
- **Optimistic UI**: 즉각적인 사용자 피드백
- **Image Caching**: cached_network_image
- **Code Generation**: freezed로 보일러플레이트 최소화

## 🧪 테스트

```bash
# 단위 테스트
flutter test

# 특정 파일 테스트
flutter test test/features/auth/domain/usecases/login_usecase_test.dart

# 커버리지
flutter test --coverage
```

## 📝 개발 가이드

### 새로운 Feature 추가 시

1. `features/{feature_name}/domain/`에 Entity, Repository, UseCase 정의
2. `features/{feature_name}/data/`에 Model, DataSource, Repository 구현
3. `features/{feature_name}/presentation/`에 Provider, Page, Widget 구현
4. `shared/providers/di_providers.dart`에 DI 등록
5. `core/network/app_router.dart`에 라우트 추가

### 코드 컨벤션

- Dart style guide 준수
- freezed로 Entity/Model 정의
- Either<Failure, T>로 에러 처리
- StateNotifier로 상태 관리

## 📚 문서

- **[로컬 개발 환경 가이드](./DEVELOPMENT.md)** - 로컬에서 개발 환경 설정
- **[Mock 서버 가이드](./MOCK_SERVER.md)** - 백엔드 없이 개발하기
- **[Docker 설정 가이드](./DOCKER_SETUP.md)** - Docker Compose로 전체 스택 실행
- **[아키텍처 문서](./ARCHITECTURE.md)** - Clean Architecture 구조
- **[API 엔드포인트](./API_ENDPOINTS.md)** - REST API 명세
- **[Supabase 설정](./SUPABASE_SETUP.md)** - Supabase 백엔드 설정
- **[배포 가이드](./DEPLOYMENT.md)** - 프로덕션 배포
- **[보안 가이드](./SECURITY.md)** - 보안 모범 사례

## 📄 라이선스

이 프로젝트는 학습 목적으로 제작되었습니다.

## 👥 기여

기여는 언제나 환영합니다!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

Made with Flutter
