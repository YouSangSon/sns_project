# SNS App - Instagram-Style Social Media Application

Flutter로 구현한 **크로스 플랫폼** 소셜 네트워크 서비스 애플리케이션입니다.

## 🌐 지원 플랫폼
- ✅ **웹** (Chrome, Safari, Edge, Firefox)
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **반응형 디자인** (모바일, 태블릿, 데스크톱)

## 📱 주요 기능

### ✅ 구현 완료
- **사용자 인증**
  - 이메일/비밀번호 회원가입 및 로그인
  - Google 소셜 로그인
  - 프로필 설정

- **홈 피드**
  - 팔로우한 사용자들의 게시물 타임라인
  - 스토리 서클 (상단 수평 스크롤)
  - 무한 스크롤
  - 새로고침 기능

- **게시물 관리**
  - 사진 업로드 (최대 10장)
  - 캡션 작성
  - 위치 태그
  - 해시태그 자동 추출
  - 게시물 삭제

- **상호작용**
  - 좋아요/좋아요 취소
  - 댓글 작성 및 조회
  - 게시물 상세 보기

- **프로필**
  - 사용자 프로필 조회
  - 게시물 그리드 뷰
  - 팔로워/팔로잉 통계
  - 프로필 편집 (사진, 이름, 소개)

- **검색 및 탐색**
  - 사용자 검색
  - 탐색 그리드

- **팔로우 시스템**
  - 팔로우/언팔로우
  - 팔로워/팔로잉 수 표시

- **스토리** ⭐ NEW!
  - 24시간 제한 스토리
  - 스토리 생성 (카메라 촬영)
  - 스토리 뷰어 (제스처 네비게이션)
  - 스토리 조회수 추적
  - 자동 진행 및 프로그레스 바

- **다이렉트 메시지 (DM)** ⭐ NEW!
  - 실시간 1:1 채팅
  - 텍스트 메시지
  - 이미지 공유
  - 읽음 상태 표시
  - 대화 목록 (최근 순)

- **알림 시스템** ⭐ NEW!
  - 실시간 알림 스트림
  - 좋아요 알림
  - 댓글 알림
  - 팔로우 알림
  - 읽음/읽지 않음 상태
  - 알림에서 바로 팔로우백

- **릴스 (Reels)** 🎬 NEW!
  - 짧은 세로 형태 비디오
  - 카메라 녹화 및 갤러리 선택
  - 세로 스와이프 네비게이션
  - 좋아요, 댓글, 공유, 조회수
  - 오디오/음악 추가
  - 비디오 압축

- **라이브 스트리밍** 📡 NEW!
  - Agora 기반 실시간 방송
  - 시청자 수 실시간 추적
  - 라이브 댓글 및 좋아요
  - 방송 시작/종료
  - 카메라/마이크 토글

- **쇼핑** 🛍️ NEW!
  - 상품 브라우징 및 검색
  - 카테고리별 필터링
  - 상품 상세 정보
  - 장바구니 기능
  - 주문 생성 및 관리
  - 리뷰 및 평점

- **푸시 알림 (FCM)** 🔔 NEW!
  - Firebase Cloud Messaging 통합
  - 백그라운드/포그라운드 알림
  - 로컬 알림
  - 알림 클릭 시 딥 링킹
  - 토픽 구독/해제

- **고급 편집 도구** ✨ NEW!
  - 이미지 필터 (10종 이상)
  - 비디오 필터
  - 크롭, 회전, 리사이즈
  - 밝기, 대비, 채도 조절
  - 비디오 트리밍 및 병합
  - 비디오에 오디오 추가

### 🚧 향후 구현 예정
- 게시물 저장 기능
- 댓글에 답글
- 사용자 태그
- 다국어 지원
- 고급 분석 대시보드

## 🛠 기술 스택

### Frontend
- **Flutter** 3.x - 크로스 플랫폼 프레임워크
- **Dart** - 프로그래밍 언어
- **Riverpod** 2.4+ - 현대적인 상태 관리 (Provider에서 마이그레이션)
- **GoRouter** - 선언적 라우팅

### Backend (하이브리드 지원)
- **Firebase**
  - Authentication - 사용자 인증
  - Cloud Firestore - NoSQL 데이터베이스
  - Storage - 파일 저장소
- **Supabase** (선택사항)
  - PostgreSQL - 관계형 데이터베이스
  - Real-time subscriptions - 실시간 업데이트
  - Row Level Security - 보안

### 주요 패키지
```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6

  # Supabase (Optional)
  supabase_flutter: ^2.3.4
  postgrest: ^2.1.1

  # UI
  cached_network_image: ^3.3.0
  google_fonts: ^6.1.0

  # Image & Video
  image_picker: ^1.0.5
  video_player: ^2.8.1

  # Routing
  go_router: ^12.1.3

  # Utils
  intl: ^0.18.1
  timeago: ^3.6.0
  uuid: ^4.2.1
```

### 아키텍처 특징
- ✅ **Riverpod 상태 관리**: 타입 안전성과 테스트 용이성
- ✅ **하이브리드 DB**: Firebase와 Supabase 동시 지원
- ✅ **플랫폼 감지**: 웹/모바일 자동 감지 및 최적화
- ✅ **실시간 동기화**: Firestore와 Supabase real-time
- ✅ **오프라인 지원**: Firestore 캐싱

## 📁 프로젝트 구조

```
lib/
├── main.dart                            # 앱 진입점
├── app.dart                             # 앱 루트 및 라우팅
├── core/
│   ├── config/
│   │   └── supabase_config.dart         # Supabase 설정
│   ├── constants/
│   │   └── app_constants.dart           # 앱 상수
│   ├── theme/
│   │   └── app_theme.dart               # 테마 설정
│   ├── utils/
│   └── widgets/
├── models/
│   ├── user_model.dart                  # 사용자 모델
│   ├── post_model.dart                  # 게시물 모델
│   ├── comment_model.dart               # 댓글 모델
│   ├── story_model.dart                 # 스토리 모델
│   ├── message_model.dart               # 메시지 모델
│   └── notification_model.dart          # 알림 모델
├── providers/                           # Riverpod Providers
│   ├── auth_provider_riverpod.dart      # 인증 상태 관리
│   ├── user_provider_riverpod.dart      # 사용자 상태 관리
│   ├── post_provider_riverpod.dart      # 게시물 상태 관리
│   ├── theme_provider_riverpod.dart     # 테마 상태 관리
│   ├── story_provider_riverpod.dart     # 스토리 상태 관리
│   ├── message_provider_riverpod.dart   # 메시지 상태 관리
│   └── notification_provider_riverpod.dart  # 알림 상태 관리
├── services/
│   ├── auth_service.dart                # Firebase 인증 서비스
│   ├── database_service.dart            # Firebase 데이터베이스 서비스
│   ├── storage_service.dart             # Firebase 스토리지 서비스
│   ├── supabase_service.dart            # Supabase 서비스
│   └── hybrid_database_service.dart     # 하이브리드 DB 서비스
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart            # 로그인 화면
│   │   └── signup_screen.dart           # 회원가입 화면
│   ├── home/
│   │   └── home_screen.dart             # 홈 (메인 네비게이션)
│   ├── feed/
│   │   └── feed_screen.dart             # 피드 화면
│   ├── post/
│   │   ├── create_post_screen.dart      # 게시물 작성
│   │   └── post_detail_screen.dart      # 게시물 상세
│   ├── profile/
│   │   ├── profile_screen.dart          # 프로필 화면
│   │   └── edit_profile_screen.dart     # 프로필 편집
│   ├── search/
│   │   └── search_screen.dart           # 검색 화면
│   ├── stories/
│   │   ├── create_story_screen.dart     # 스토리 생성
│   │   └── stories_screen.dart          # 스토리 뷰어
│   ├── messages/
│   │   ├── messages_screen.dart         # 대화 목록
│   │   └── chat_screen.dart             # 채팅 화면
│   └── notifications/
│       └── notifications_screen.dart    # 알림 화면
└── widgets/
    ├── post_card.dart                   # 게시물 카드 위젯
    └── story_circle.dart                # 스토리 서클 위젯
```

## 🚀 시작하기

### 사전 준비
- Flutter SDK 3.0 이상
- Dart SDK 3.0 이상
- Android Studio / Xcode (모바일 개발 시)
- Firebase 계정 (필수)
- Supabase 계정 (선택사항)

### 1. 저장소 클론

```bash
git clone <repository-url>
cd sns_project
```

### 2. 패키지 설치

```bash
flutter pub get
```

### 3. Firebase 설정 (필수)

**중요:** Firebase 설정이 필수입니다. 자세한 내용은 [FIREBASE_SETUP.md](FIREBASE_SETUP.md)를 참조하세요.

간단 요약:
1. [Firebase Console](https://console.firebase.google.com/)에서 프로젝트 생성
2. 웹 앱 추가 (웹 지원용)
3. Android 앱 추가 및 `google-services.json` 다운로드 → `android/app/` 에 배치
4. iOS 앱 추가 및 `GoogleService-Info.plist` 다운로드 → `ios/Runner/` 에 배치
5. Authentication, Firestore, Storage 활성화

### 4. Supabase 설정 (선택사항)

Supabase를 사용하려면 [SUPABASE_SETUP.md](SUPABASE_SETUP.md)를 참조하세요.

PostgreSQL의 강력한 쿼리와 관계형 데이터베이스를 원한다면 Supabase를 추가하세요!

### 5. 앱 실행

#### 웹에서 실행
```bash
flutter run -d chrome
# 또는
flutter run -d edge
```

#### 모바일에서 실행
```bash
# Android
flutter run -d android

# iOS (macOS only)
cd ios && pod install && cd ..
flutter run -d ios
```

#### 빌드
```bash
# 웹 빌드
flutter build web --release

# Android APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release
```

## 🗄 데이터베이스 구조

### Firestore Collections

```
users/
  {userId}/
    - uid: string
    - email: string
    - username: string
    - displayName: string
    - photoUrl: string
    - bio: string
    - followers: number
    - following: number
    - posts: number
    - createdAt: timestamp

posts/
  {postId}/
    - postId: string
    - userId: string
    - username: string
    - userPhotoUrl: string
    - imageUrls: array<string>
    - caption: string
    - location: string
    - hashtags: array<string>
    - likes: number
    - comments: number
    - createdAt: timestamp

comments/
  {commentId}/
    - commentId: string
    - postId: string
    - userId: string
    - username: string
    - userPhotoUrl: string
    - text: string
    - likes: number
    - createdAt: timestamp

likes/
  {likeId}/
    - postId: string
    - userId: string
    - createdAt: timestamp

follows/
  {followId}/
    - followerId: string
    - followingId: string
    - createdAt: timestamp
```

## 🎨 디자인

- **테마**: Light & Dark Mode 지원
- **컬러**: Instagram 스타일 그라데이션
- **폰트**: Google Fonts (Roboto)
- **UI/UX**: Material Design 3

## 🔧 개발 도구

```bash
# 빌드
flutter build apk          # Android APK
flutter build ios          # iOS
flutter build web          # Web

# 분석
flutter analyze

# 테스트
flutter test

# 코드 포맷팅
dart format .
```

## 📝 주요 파일 설명

### main.dart
- 앱 진입점
- Firebase 초기화
- Supabase 초기화 (선택사항)
- ProviderScope 설정
- 플랫폼 감지 (웹/모바일)

### app.dart
- 라우팅 설정 (GoRouter)
- 테마 설정 (라이트/다크 모드)
- 인증 상태에 따른 리다이렉션

### services/
- **auth_service.dart**: Firebase Authentication 래퍼
- **database_service.dart**: Firestore CRUD 작업
- **storage_service.dart**: Firebase Storage 이미지 업로드
- **supabase_service.dart**: Supabase PostgreSQL 작업
- **hybrid_database_service.dart**: Firebase + Supabase 하이브리드

### providers/
- **Riverpod** 패턴을 사용한 상태 관리
- **StateNotifier**: 변경 가능한 상태 관리
- **FutureProvider**: 비동기 데이터 로딩
- **StreamProvider**: 실시간 데이터 스트림
- **Provider.family**: 매개변수화된 provider

## 🔐 보안

### Firestore 보안 규칙
- 읽기: 모든 사용자 가능
- 쓰기: 인증된 사용자만
- 수정/삭제: 작성자만 가능

### Storage 보안 규칙
- 읽기: 모든 사용자 가능
- 쓰기: 인증된 사용자만

## 🐛 알려진 이슈

1. **이미지 업로드 속도**: 큰 이미지는 업로드 시간이 오래 걸릴 수 있습니다.
   - 해결 방법: 이미지 압축 구현 예정

2. **피드 로딩**: 팔로우한 사용자가 많을 경우 로딩이 느릴 수 있습니다.
   - 해결 방법: 페이지네이션 최적화 예정

## 🚀 향후 계획

1. **Phase 1** (✅ 완료)
   - ✅ 기본 인증 시스템
   - ✅ 게시물 CRUD
   - ✅ 프로필 관리
   - ✅ 팔로우 시스템

2. **Phase 2** (✅ 완료)
   - ✅ 스토리 기능
   - ✅ 다이렉트 메시지
   - ✅ 실시간 알림

3. **Phase 3** (✅ 완료)
   - ✅ 릴스 (짧은 비디오)
     - 세로 스와이프 네비게이션
     - 비디오 녹화 및 업로드
     - 좋아요, 댓글, 공유
     - 조회수 추적
   - ✅ 라이브 스트리밍
     - Agora 기반 실시간 스트리밍
     - 시청자 수 추적
     - 실시간 댓글 및 좋아요
   - ✅ 쇼핑 기능
     - 상품 카탈로그
     - 장바구니
     - 주문 관리
     - 결제 통합 준비
   - ✅ FCM 푸시 알림
     - 백그라운드/포그라운드 알림
     - 토픽 구독
     - 딥 링킹
   - ✅ 고급 필터 및 편집 도구
     - 이미지 필터 (Grayscale, Sepia, Vintage 등)
     - 비디오 필터 및 편집
     - 크롭, 회전, 리사이즈
     - 밝기, 대비, 채도 조절

## 📄 라이선스

이 프로젝트는 학습 목적으로 제작되었습니다.

## 👥 기여

기여는 언제나 환영합니다!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 문의

프로젝트에 대한 질문이나 제안이 있으시면 이슈를 생성해주세요.

## 🙏 감사의 말

- Flutter Team
- Firebase Team
- 모든 오픈소스 패키지 기여자들

---

Made with ❤️ using Flutter