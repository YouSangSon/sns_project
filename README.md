# SNS App - Instagram-Style Social Media Application

Flutter로 구현한 크로스 플랫폼 소셜 네트워크 서비스 애플리케이션입니다.

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

### 🚧 향후 구현 예정
- 릴스 (짧은 비디오)
- 게시물 저장 기능
- 댓글에 답글
- 사용자 태그
- 다국어 지원
- 푸시 알림 (FCM)

## 🛠 기술 스택

### Frontend
- **Flutter** 3.x
- **Dart**
- **Provider** - 상태 관리
- **GoRouter** - 라우팅

### Backend
- **Firebase Authentication** - 인증
- **Cloud Firestore** - 데이터베이스
- **Firebase Storage** - 파일 저장
- **Google Sign-In** - 소셜 로그인

### 주요 패키지
```yaml
dependencies:
  # UI
  cached_network_image: ^3.3.0
  google_fonts: ^6.1.0

  # State Management
  provider: ^6.1.1

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6

  # Image & Video
  image_picker: ^1.0.5

  # Routing
  go_router: ^12.1.3

  # Utils
  intl: ^0.18.1
  timeago: ^3.6.0
  uuid: ^4.2.1
```

## 📁 프로젝트 구조

```
lib/
├── main.dart                   # 앱 진입점
├── app.dart                    # 앱 루트 및 라우팅
├── core/
│   ├── constants/
│   │   └── app_constants.dart  # 앱 상수
│   ├── theme/
│   │   └── app_theme.dart      # 테마 설정
│   ├── utils/
│   └── widgets/
├── models/
│   ├── user_model.dart         # 사용자 모델
│   ├── post_model.dart         # 게시물 모델
│   ├── comment_model.dart      # 댓글 모델
│   ├── story_model.dart        # 스토리 모델
│   └── message_model.dart      # 메시지 모델
├── providers/
│   ├── auth_provider.dart      # 인증 상태 관리
│   ├── user_provider.dart      # 사용자 상태 관리
│   ├── post_provider.dart      # 게시물 상태 관리
│   └── theme_provider.dart     # 테마 상태 관리
├── services/
│   ├── auth_service.dart       # 인증 서비스
│   ├── database_service.dart   # 데이터베이스 서비스
│   └── storage_service.dart    # 스토리지 서비스
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart   # 로그인 화면
│   │   └── signup_screen.dart  # 회원가입 화면
│   ├── home/
│   │   └── home_screen.dart    # 홈 (메인 네비게이션)
│   ├── feed/
│   │   └── feed_screen.dart    # 피드 화면
│   ├── post/
│   │   ├── create_post_screen.dart  # 게시물 작성
│   │   └── post_detail_screen.dart  # 게시물 상세
│   ├── profile/
│   │   ├── profile_screen.dart      # 프로필 화면
│   │   └── edit_profile_screen.dart # 프로필 편집
│   ├── search/
│   │   └── search_screen.dart       # 검색 화면
│   └── notifications/
│       └── notifications_screen.dart # 알림 화면
└── widgets/
    └── post_card.dart          # 게시물 카드 위젯
```

## 🚀 시작하기

### 사전 준비
- Flutter SDK 3.0 이상
- Dart SDK 3.0 이상
- Android Studio / Xcode
- Firebase 계정

### 1. 저장소 클론

```bash
git clone <repository-url>
cd sns_project
```

### 2. 패키지 설치

```bash
flutter pub get
```

### 3. Firebase 설정

**중요:** Firebase 설정이 필수입니다. 자세한 내용은 [FIREBASE_SETUP.md](FIREBASE_SETUP.md)를 참조하세요.

간단 요약:
1. [Firebase Console](https://console.firebase.google.com/)에서 프로젝트 생성
2. Android 앱 추가 및 `google-services.json` 다운로드 → `android/app/` 에 배치
3. iOS 앱 추가 및 `GoogleService-Info.plist` 다운로드 → `ios/Runner/` 에 배치
4. Authentication, Firestore, Storage 활성화

### 4. 앱 실행

```bash
# Android
flutter run

# iOS
cd ios && pod install && cd ..
flutter run
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
- Provider 설정

### app.dart
- 라우팅 설정 (GoRouter)
- 테마 설정
- 인증 상태에 따른 리다이렉션

### services/
- **auth_service.dart**: Firebase Authentication 래퍼
- **database_service.dart**: Firestore CRUD 작업
- **storage_service.dart**: Firebase Storage 이미지 업로드

### providers/
- Provider 패턴을 사용한 상태 관리
- ChangeNotifier를 상속하여 UI 업데이트

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

3. **Phase 3** (📋 계획)
   - 📋 릴스 (짧은 비디오)
   - 📋 라이브 스트리밍
   - 📋 쇼핑 기능
   - 📋 FCM 푸시 알림
   - 📋 고급 필터 및 편집 도구

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