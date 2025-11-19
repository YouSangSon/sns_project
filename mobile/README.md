# SNS Mobile App (React Native + Expo)

Instagram 스타일의 소셜 네트워크 서비스 모바일 앱입니다.

## 🚀 기술 스택

- **React Native** + **Expo** - 크로스 플랫폼 모바일 프레임워크
- **TypeScript** - 타입 안전성
- **React Navigation** - 네비게이션
- **React Query** - 서버 상태 관리
- **Zustand** - 클라이언트 상태 관리
- **Axios** - HTTP 클라이언트

## 📁 프로젝트 구조

```
src/
├── components/       # 재사용 가능한 컴포넌트
│   ├── common/       # 공통 컴포넌트 (Button, Input, Loading)
│   ├── posts/        # 게시물 관련 컴포넌트
│   └── profile/      # 프로필 관련 컴포넌트
├── screens/          # 화면 컴포넌트
│   ├── auth/         # 인증 화면 (Login, Signup)
│   ├── feed/         # 피드 화면
│   ├── home/         # 홈 화면
│   ├── post/         # 게시물 화면
│   ├── profile/      # 프로필 화면
│   ├── search/       # 검색 화면
│   ├── messages/     # 메시지 화면
│   └── notifications/# 알림 화면
├── navigation/       # 네비게이션 설정
│   ├── types.ts      # 네비게이션 타입
│   ├── AuthStack.tsx # 인증 스택
│   ├── MainTabs.tsx  # 메인 탭
│   └── RootNavigator.tsx # 루트 네비게이터
├── stores/           # Zustand 스토어
│   └── authStore.ts  # 인증 스토어
├── hooks/            # 커스텀 Hooks
│   └── useAuth.ts    # 인증 Hook
├── services/         # API 서비스
│   ├── api.ts        # API 클라이언트 초기화
│   └── queryClient.ts# React Query 설정
├── constants/        # 상수
│   ├── config.ts     # 앱 설정
│   └── colors.ts     # 색상 테마
└── utils/            # 유틸리티 함수
```

## 🔧 설치 및 실행

### 1. 의존성 설치

```bash
npm install
```

### 2. 앱 실행

```bash
# iOS 시뮬레이터
npm run ios

# Android 에뮬레이터
npm run android

# 웹 브라우저
npm run web

# Expo Go 앱으로 실행
npm start
```

## 📱 주요 기능

### ✅ 구현 완료

- **인증 시스템**
  - 로그인 / 회원가입
  - JWT 토큰 기반 인증
  - 자동 토큰 갱신
  - 비밀번호 표시/숨기기
  - 폼 유효성 검사

- **네비게이션**
  - 인증 스택 (Login, Signup)
  - 메인 탭 (Home, Search, CreatePost, Notifications, Profile)
  - 자동 로그인 체크

- **상태 관리**
  - Zustand (인증 상태)
  - React Query (서버 데이터)
  - AsyncStorage (영구 저장)

### 🚧 구현 예정

- 홈 피드
- 게시물 작성/조회/수정/삭제
- 프로필 관리
- 댓글/좋아요
- 팔로우/팔로잉
- 검색
- 알림
- DM (다이렉트 메시지)
- 스토리
- 릴스
- 투자 SNS 기능

## 🔗 API 연동

이 앱은 REST API 서버와 연동됩니다.

- **백엔드 저장소**: https://github.com/YouSangSon/rest_server
- **기본 URL**: `http://localhost:8080` (개발 모드)
- **공유 타입**: `../shared/types`
- **API 클라이언트**: `../shared/api`

## 🎨 디자인 시스템

- **색상**: Instagram 스타일 (Primary Blue, Gradient)
- **컴포넌트**: Material Design 기반
- **아이콘**: Ionicons
- **폰트**: 시스템 기본 폰트

## 📝 환경 변수

`.env` 파일을 생성하여 설정:

```env
API_BASE_URL=http://localhost:8080
```

## 🐛 문제 해결

### iOS 빌드 오류

```bash
cd ios && pod install && cd ..
```

### Android 빌드 오류

```bash
cd android && ./gradlew clean && cd ..
```

### 캐시 클리어

```bash
npm start -- --clear
```

## 📄 라이선스

이 프로젝트는 학습 목적으로 제작되었습니다.
