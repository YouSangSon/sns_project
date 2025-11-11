# Instagram-Style SNS App - 기획서

## 🎯 프로젝트 개요
Flutter를 활용한 크로스 플랫폼 SNS 애플리케이션

## 📋 핵심 기능

### 1. 사용자 인증 (Authentication)
- 이메일/비밀번호 회원가입 및 로그인
- Google 소셜 로그인
- 프로필 설정 (닉네임, 프로필 사진, 자기소개)

### 2. 홈 피드 (Feed)
- 팔로우한 사용자들의 게시물 타임라인
- 무한 스크롤
- 새로고침 기능

### 3. 게시물 (Post)
- 사진/비디오 업로드
- 다중 이미지 지원
- 캡션 작성
- 위치 태그
- 해시태그 기능

### 4. 상호작용 (Interaction)
- 좋아요 (Like)
- 댓글 (Comment)
- 답글 (Reply)
- 게시물 저장

### 5. 프로필 (Profile)
- 사용자 프로필 조회
- 게시물 그리드 뷰
- 팔로워/팔로잉 목록
- 프로필 편집

### 6. 검색 및 탐색 (Explore)
- 사용자 검색
- 해시태그 검색
- 인기 게시물 탐색
- 추천 사용자

### 7. 팔로우 시스템 (Follow System)
- 팔로우/언팔로우
- 팔로워/팔로잉 관리

### 8. 알림 (Notifications)
- 좋아요 알림
- 댓글 알림
- 팔로우 알림
- 실시간 푸시 알림

### 9. 스토리 (Stories)
- 24시간 제한 스토리
- 스토리 업로드
- 스토리 뷰어

### 10. 다이렉트 메시지 (DM)
- 1:1 채팅
- 사진/비디오 공유
- 실시간 메시징

## 🛠 기술 스택

### Frontend
- **Framework**: Flutter 3.x
- **언어**: Dart
- **상태 관리**: Provider / Riverpod
- **라우팅**: Go Router

### Backend
- **Backend as a Service**: Firebase
  - Authentication (인증)
  - Firestore (데이터베이스)
  - Storage (파일 저장소)
  - Cloud Functions (서버리스 함수)
  - Cloud Messaging (푸시 알림)

### 주요 패키지
- `firebase_core` - Firebase 초기화
- `firebase_auth` - 인증
- `cloud_firestore` - 데이터베이스
- `firebase_storage` - 파일 저장
- `image_picker` - 이미지 선택
- `cached_network_image` - 이미지 캐싱
- `provider` / `riverpod` - 상태 관리
- `go_router` - 라우팅
- `video_player` - 비디오 재생
- `intl` - 국제화
- `timeago` - 시간 표시

## 📁 프로젝트 구조

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── models/
│   ├── user_model.dart
│   ├── post_model.dart
│   ├── comment_model.dart
│   ├── story_model.dart
│   └── message_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── post_provider.dart
│   └── theme_provider.dart
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── storage_service.dart
│   └── notification_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── feed/
│   │   └── feed_screen.dart
│   ├── post/
│   │   ├── create_post_screen.dart
│   │   └── post_detail_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   ├── search/
│   │   └── search_screen.dart
│   ├── notifications/
│   │   └── notifications_screen.dart
│   ├── stories/
│   │   ├── stories_screen.dart
│   │   └── create_story_screen.dart
│   └── messages/
│       ├── messages_screen.dart
│       └── chat_screen.dart
└── widgets/
    ├── post_card.dart
    ├── user_avatar.dart
    ├── story_circle.dart
    └── comment_tile.dart
```

## 🗄 데이터베이스 구조 (Firestore)

### Users Collection
```
users/{userId}
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
```

### Posts Collection
```
posts/{postId}
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
```

### Comments Collection
```
comments/{commentId}
  - commentId: string
  - postId: string
  - userId: string
  - username: string
  - userPhotoUrl: string
  - text: string
  - likes: number
  - createdAt: timestamp
```

### Likes Collection
```
likes/{likeId}
  - postId: string
  - userId: string
  - createdAt: timestamp
```

### Follows Collection
```
follows/{followId}
  - followerId: string (팔로우 하는 사람)
  - followingId: string (팔로우 받는 사람)
  - createdAt: timestamp
```

### Stories Collection
```
stories/{storyId}
  - storyId: string
  - userId: string
  - username: string
  - userPhotoUrl: string
  - mediaUrl: string
  - mediaType: string (image/video)
  - views: array<string>
  - createdAt: timestamp
  - expiresAt: timestamp
```

### Messages Collection
```
conversations/{conversationId}
  - participants: array<string>
  - lastMessage: string
  - lastMessageTime: timestamp

  messages/{messageId}
    - senderId: string
    - text: string
    - mediaUrl: string
    - type: string (text/image/video)
    - createdAt: timestamp
    - isRead: boolean
```

### Notifications Collection
```
notifications/{notificationId}
  - userId: string (알림 받는 사람)
  - fromUserId: string (알림 보낸 사람)
  - fromUsername: string
  - fromUserPhotoUrl: string
  - type: string (like/comment/follow)
  - postId: string (optional)
  - text: string
  - isRead: boolean
  - createdAt: timestamp
```

## 🎨 UI/UX 설계

### 색상 테마
- Primary: Instagram 그라데이션 (#405DE6, #5851DB, #833AB4, #C13584, #E1306C, #FD1D1D, #F56040, #FFDC80)
- Background: #FFFFFF (Light), #000000 (Dark)
- Text: #262626 (Light), #FFFFFF (Dark)
- Border: #DBDBDB (Light), #262626 (Dark)

### 네비게이션
- 하단 탭 바 (5개 탭)
  1. 홈 (피드)
  2. 검색 (탐색)
  3. 게시물 작성
  4. 알림
  5. 프로필

## 🚀 개발 단계

### Phase 1: 기본 설정 (완료 예정)
- Flutter 프로젝트 초기화
- Firebase 설정
- 프로젝트 구조 생성
- 기본 테마 및 라우팅 설정

### Phase 2: 인증 시스템
- 로그인/회원가입 UI
- Firebase Auth 연동
- 프로필 설정

### Phase 3: 핵심 기능
- 홈 피드
- 게시물 작성
- 프로필 화면

### Phase 4: 상호작용
- 좋아요, 댓글
- 팔로우 시스템
- 검색 기능

### Phase 5: 추가 기능
- 알림
- 스토리
- 다이렉트 메시지

### Phase 6: 최적화 및 배포
- 성능 최적화
- 버그 수정
- 앱 스토어 배포 준비

## 📱 주요 화면 플로우

```
Splash Screen
    ↓
Login/Signup
    ↓
Home (Feed) ←→ Search ←→ Create Post ←→ Notifications ←→ Profile
    ↓              ↓                           ↓              ↓
Post Detail    User Profile              View Notification  Edit Profile
    ↓              ↓                                         ↓
Comments       Follow/Unfollow                         Settings
```

## 🔒 보안 고려사항

1. Firebase Security Rules 설정
2. 사용자 데이터 검증
3. 이미지 업로드 제한 (크기, 형식)
4. Rate Limiting
5. 개인정보 보호

## 📈 향후 확장 가능성

1. 릴스(Reels) - 짧은 비디오
2. 쇼핑 기능
3. 라이브 스트리밍
4. AR 필터
5. 다국어 지원
6. 웹 버전

## 🎓 학습 목표

- Flutter 앱 개발 전반
- Firebase 백엔드 활용
- 상태 관리
- 실시간 데이터 처리
- 이미지/비디오 처리
- UI/UX 구현
