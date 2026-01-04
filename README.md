# SNS App - Modern Social Media Platform

**풀스택 소셜 네트워크 서비스** 애플리케이션입니다.

## 🏗️ 아키텍처

- **Mobile**: Flutter (Clean Architecture) + Dart
- **Web**: Next.js 14 (App Router) + TypeScript
- **Backend**:
  - ⭐ **Supabase** (PostgreSQL + Auth + Storage) - 추천
  - Kotlin + Spring Boot 3 REST API ([YouSangSon/rest_server](https://github.com/YouSangSon/rest_server))
- **Mobile State Management**: Riverpod + dartz (Either)
- **Web State Management**: React Query (@tanstack/react-query) + Zustand

## 🌐 지원 플랫폼

- ✅ **Web** (Chrome, Safari, Edge, Firefox) - Next.js
- ✅ **Android** (API 21+) - Flutter
- ✅ **iOS** (iOS 12.0+) - Flutter
- ✅ **반응형 디자인** (모바일, 태블릿, 데스크톱)

## 📱 주요 기능

### ✅ 구현 완료

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
  - React Query 기반 실시간 업데이트

- **게시물 관리**
  - 사진 업로드 (최대 10장)
  - 캡션 작성
  - 해시태그 지원
  - 게시물 수정/삭제
  - 이미지 미리보기 및 슬라이더

- **상호작용**
  - 좋아요/좋아요 취소 (Optimistic UI)
  - 댓글 작성, 수정, 삭제
  - 대댓글 (답글) 기능
  - 게시물 상세 보기
  - 좋아요 목록 조회

- **프로필**
  - 사용자 프로필 조회
  - 게시물 그리드 뷰 (3열)
  - 팔로워/팔로잉 통계
  - 프로필 편집 (사진, 이름, 소개)
  - 내 프로필 / 다른 사용자 프로필

- **검색 및 탐색**
  - 사용자 검색 (디바운싱)
  - 실시간 검색 결과
  - 탐색 피드

- **팔로우 시스템**
  - 팔로우/언팔로우
  - 팔로워/팔로잉 수 자동 업데이트
  - 팔로우 상태 추적

- **북마크 (Bookmarks)** ⭐
  - 게시물 북마크 저장
  - 릴스 북마크 저장
  - 타입별 필터링 (Posts/Reels)
  - 3열 그리드 레이아웃
  - 북마크 삭제 (롱 프레스 / 호버)
  - 무한 스크롤

- **알림 (Notifications)** ⭐
  - 실시간 알림 피드
  - 좋아요 알림
  - 댓글 알림
  - 팔로우 알림
  - 멘션 알림
  - 읽음/읽지 않음 상태
  - 30초마다 자동 갱신
  - 알림 타입별 아이콘

- **다이렉트 메시지 (Messages)** ⭐
  - 1:1 채팅
  - 텍스트 메시지
  - 이미지 공유
  - 읽음 상태 표시
  - 대화 목록 (최근 순)
  - 읽지 않은 메시지 카운트
  - 5초마다 자동 갱신

- **스토리 (Stories)** ⭐
  - 24시간 제한 스토리
  - 스토리 생성 (이미지 선택)
  - 스토리 뷰어 (풀스크린)
  - 자동 진행 (5초)
  - 진행률 바
  - 터치/클릭 네비게이션 (이전/다음)
  - 일시정지 기능
  - 조회수 추적

- **릴스 (Reels)** 🎬
  - 짧은 세로 형태 비디오
  - 세로 스크롤 피드
  - 좋아요, 댓글, 공유
  - 조회수 추적
  - 비디오 플레이어 기본 구조
  - 오디오 정보 표시

#### 투자 SNS (Investment Social Network) 📊

- **포트폴리오 관리**
  - 포트폴리오 생성, 조회, 수정, 삭제
  - 공개/비공개 설정
  - 총 자산 가치 추적
  - 수익률 계산
  - 다중 통화 지원

- **자산 보유 (Holdings)**
  - 보유 종목 추가/수정/삭제
  - 주식, 암호화폐, ETF, 채권 지원
  - 평균 단가 자동 계산
  - 현재가 및 수익률 표시
  - 자산 유형별 분류

- **거래 내역 (Trade History)**
  - 매수/매도 거래 기록
  - 거래 수수료 추적
  - 거래 메모
  - 포트폴리오별 거래 내역
  - 무한 스크롤 지원

- **관심종목 (Watchlist)**
  - 관심 종목 추가/삭제
  - 목표가 설정
  - 실시간 가격 조회
  - 자산 검색 기능
  - 가격 알림 설정

- **투자 포스트 (Investment Posts)**
  - 투자 아이디어 공유
  - Bullish/Bearish 투표
  - 종목 태그
  - 투자 심리 표시
  - 좋아요 및 댓글
  - 투자 포스트 피드

- **포트폴리오 소셜 기능**
  - 포트폴리오 팔로우/언팔로우
  - 포트폴리오 복사
  - 공개 포트폴리오 피드
  - 팔로워 수 추적
  - 트렌딩 포트폴리오

- **포트폴리오 분석**
  - 자산 배분 분석
  - 실시간 수익률
  - 수익/손실 추적
  - 포트폴리오 성과 히스토리
  - 다각화 점수

## 🛠 기술 스택

### Frontend (Mobile - Flutter)
- **Flutter 3.x** - 크로스 플랫폼 프레임워크
- **Dart 3.x** - 프로그래밍 언어
- **Clean Architecture** - Feature-first 구조
- **Riverpod** - 상태 관리 + DI
- **Go Router** - 네비게이션
- **Dio** - HTTP 클라이언트
- **freezed + json_serializable** - 코드 생성
- **dartz** - 함수형 에러 처리 (Either)
- **flutter_secure_storage** - 보안 저장소

### Frontend (Web)
- **Next.js 14** - App Router
- **TypeScript**
- **Tailwind CSS** - 스타일링
- **React Query** - Server state management
- **Zustand** - Client state management
- **Axios** - HTTP client

### Backend
- **Kotlin** - 프로그래밍 언어
- **Spring Boot 3** - REST API 프레임워크
- **PostgreSQL** - 관계형 데이터베이스
- **JWT** - 인증 토큰
- **REST API** - RESTful 아키텍처

### 주요 패키지 (Flutter)

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
├── flutter_app/                     # Flutter 모바일 앱 (Clean Architecture)
│   └── lib/
│       ├── core/                    # 핵심 공통 모듈
│       │   ├── constants/           # 상수 (색상, 설정, API)
│       │   ├── errors/              # Failure, Exception
│       │   ├── network/             # Dio, Router, Interceptors
│       │   └── utils/               # Extensions, Validators
│       │
│       ├── features/                # Feature 모듈
│       │   ├── auth/                # 인증
│       │   │   ├── domain/          # entities, repositories, usecases
│       │   │   ├── data/            # datasources, models, repositories impl
│       │   │   └── presentation/    # providers, pages, widgets
│       │   ├── feed/                # 피드
│       │   ├── post/                # 게시물
│       │   ├── profile/             # 프로필
│       │   ├── messages/            # 메시지
│       │   ├── search/              # 검색
│       │   ├── notifications/       # 알림
│       │   ├── investment/          # 투자
│       │   └── stories/             # 스토리
│       │
│       └── shared/                  # 공유 모듈
│           ├── providers/           # DI Providers
│           └── widgets/             # 공통 위젯
│
├── mobile/                          # React Native 앱 (레거시)
│
├── web-app/                         # Next.js 웹 앱
│   ├── app/                         # App Router
│   ├── lib/
│   │   ├── hooks/                   # Custom React Hooks
│   │   └── stores/                  # Zustand stores
│   └── components/                  # 재사용 컴포넌트
│
└── shared/                          # 웹 공유 레이어
    ├── api/                         # API 서비스 클래스
    ├── types/                       # TypeScript 타입 정의
    └── constants/                   # 상수
```

## 🚀 시작하기

### 사전 준비

- Node.js 18+
- npm 또는 yarn
- Expo CLI (모바일 개발 시)
- Android Studio / Xcode (모바일 개발 시)
- **백엔드 (선택사항)**:
  - ⭐ **Supabase 계정** (무료, 추천) - [가입하기](https://supabase.com)
  - 또는 백엔드 API 서버 ([YouSangSon/rest_server](https://github.com/YouSangSon/rest_server))

### 1. 저장소 클론

```bash
git clone https://github.com/YouSangSon/sns_project.git
cd sns_project
```

### 2. 패키지 설치

#### Mobile (Flutter)
```bash
cd flutter_app
flutter pub get

# 코드 생성 (freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Web (Next.js)
```bash
cd web-app
npm install

# Supabase 사용 시
npm install @supabase/supabase-js
```

### 3. 백엔드 설정 (옵션 선택)

#### 옵션 A: Supabase 사용 (추천 ⭐)

**5-10분 만에 완전한 백엔드 구축!**

1. **Supabase 프로젝트 생성**: [supabase.com](https://supabase.com)에서 프로젝트 생성
2. **데이터베이스 설정**: `supabase/schema.sql` 파일을 SQL Editor에서 실행
3. **테스트 데이터 추가**: `supabase/seed.sql` 파일을 SQL Editor에서 실행
4. **환경 변수 설정**:

**Mobile (.env)**
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
```

**Web (.env.local)**
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
```

5. **자세한 설정 방법**: [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) 참조

#### 옵션 B: 자체 백엔드 API 서버

```bash
# https://github.com/YouSangSon/rest_server 참조
cd rest_server
./gradlew bootRun
```

**환경 변수**:
```env
# Mobile (.env)
API_BASE_URL=http://localhost:8080

# Web (.env.local)
NEXT_PUBLIC_API_BASE_URL=http://localhost:8080
```

#### 옵션 C: 백엔드 없이 테스트 (하드코딩된 계정)

환경 변수 설정 없이 바로 실행하면 하드코딩된 테스트 계정으로 로그인 가능합니다!

### 4. 테스트 계정

#### 기본 테스트 계정
```
이메일: test@example.com
비밀번호: Test123!@#
사용자명: testuser
```

#### 추가 테스트 계정들
```
# 계정 1
이메일: john@example.com
비밀번호: John123!@#
사용자명: johndoe

# 계정 2
이메일: jane@example.com
비밀번호: Jane123!@#
사용자명: janedoe

# 계정 3
이메일: admin@example.com
비밀번호: Admin123!@#
사용자명: admin
```

#### 📝 백엔드 옵션별 로그인 방법

**🔹 Supabase 사용 시 (옵션 A)**
- `supabase/seed.sql`을 실행하면 위 테스트 계정들이 데이터베이스에 생성됩니다
- 실제 Supabase Auth를 통해 로그인됩니다
- ✅ **추천**: 완전한 백엔드 기능 사용 가능!

**🔹 자체 백엔드 사용 시 (옵션 B)**
- 백엔드 서버의 초기 데이터에 테스트 계정을 추가해야 합니다
- REST API를 통해 로그인됩니다

**🔹 백엔드 없이 테스트 (옵션 C)**
- **프론트엔드에 하드코딩**되어 있어 백엔드 없이도 로그인 가능! 🎉
- 환경 변수 설정 불필요
- **그냥 로그인 화면에서 위 이메일/비밀번호 입력하면 끝!**
- ⚠️ 제한사항: 로그인 후 다른 기능(게시물, 댓글 등)은 백엔드가 필요합니다

### 6. 앱 실행

#### Mobile (Flutter)
```bash
cd flutter_app

# iOS 시뮬레이터 (macOS only)
flutter run -d ios

# Android 에뮬레이터
flutter run -d android

# 웹 (개발용)
flutter run -d chrome
```

#### Web (Next.js)
```bash
cd web-app
npm run dev
```

브라우저에서 http://localhost:3000 접속

### 7. 빌드

#### Mobile (Flutter)
```bash
cd flutter_app

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS 필요)
flutter build ios --release
```

#### Web
```bash
cd web-app
npm run build
npm start
```

## 🔑 주요 기능 상세

### React Query 패턴

모든 서버 상태는 React Query로 관리됩니다:

```typescript
// useInfiniteQuery를 사용한 무한 스크롤
export const useFeed = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: POST_KEYS.feed(params),
    queryFn: ({ pageParam = 1 }) =>
      postsService.getFeed({ ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

// useMutation을 사용한 Optimistic UI
export const useLikePost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (postId: string) => postsService.likePost(postId),
    onSuccess: (_, postId) => {
      queryClient.invalidateQueries({
        queryKey: POST_KEYS.detail(postId),
      });
    },
  });
};
```

### Zustand 상태 관리

인증 상태는 Zustand로 관리하고 AsyncStorage에 persist:

```typescript
export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      isAuthenticated: false,

      login: (token: string, user: User) => {
        apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        set({ token, user, isAuthenticated: true });
      },

      logout: () => {
        delete apiClient.defaults.headers.common['Authorization'];
        set({ token: null, user: null, isAuthenticated: false });
      },
    }),
    {
      name: 'auth-storage',
    }
  )
);
```

### 공유 API 서비스

모든 API 호출은 shared/api 레이어를 통해 처리:

```typescript
// shared/api/posts.service.ts
export class PostsService {
  async getFeed(params?: PaginationParams): Promise<PaginatedResponse<Post>> {
    return apiClient.get<PaginatedResponse<Post>>(
      API_ENDPOINTS.POSTS.FEED,
      { params }
    );
  }

  async createPost(data: CreatePostDto): Promise<Post> {
    return apiClient.post<Post>(API_ENDPOINTS.POSTS.BASE, data);
  }
}

export const postsService = new PostsService();
```

## 📡 API 엔드포인트

백엔드 API는 REST API로 구현되어 있습니다:

- `POST /api/v1/auth/login` - 로그인
- `POST /api/v1/auth/register` - 회원가입
- `GET /api/v1/posts/feed` - 피드 조회
- `POST /api/v1/posts` - 게시물 생성
- `GET /api/v1/users/{id}` - 사용자 프로필
- `POST /api/v1/messages` - 메시지 전송
- `GET /api/v1/notifications` - 알림 조회
- `POST /api/v1/investment/portfolios` - 포트폴리오 생성

전체 API 문서는 백엔드 저장소를 참조하세요.

## 🎨 디자인 시스템

### Mobile (React Native)
- **테마**: Instagram 스타일
- **컬러**:
  - Primary: #0095f6 (Instagram Blue)
  - Like: #ff3b5c (Red)
  - Text: #262626
  - Border: #dbdbdb
- **폰트**: System fonts (San Francisco / Roboto)
- **UI 패턴**: Bottom Tabs, Stack Navigation

### Web (Next.js)
- **CSS Framework**: Tailwind CSS
- **컬러 스킴**: Mobile과 동일
- **반응형**: Mobile-first design
- **UI 패턴**: Client-side routing

## 🔐 보안

- **JWT Authentication**: Access token + Refresh token
- **Token Auto-refresh**: Axios interceptor로 자동 갱신
- **Secure Storage**:
  - Mobile: AsyncStorage (encrypted on iOS)
  - Web: localStorage with encryption
- **HTTPS**: Production 환경에서 필수
- **XSS Protection**: Next.js built-in protection
- **CSRF Protection**: Backend에서 처리

## 📊 성능 최적화

- **React Query Caching**: 서버 상태 자동 캐싱
- **Infinite Scroll**: 효율적인 페이지네이션
- **Optimistic UI**: 즉각적인 사용자 피드백
- **Image Optimization**: Next.js Image component
- **Code Splitting**: Next.js automatic code splitting
- **Lazy Loading**: React.lazy & Suspense

## 🧪 테스트

```bash
# Mobile
cd mobile
npm test

# Web
cd web-app
npm test
```

## 📝 개발 가이드

### 새로운 기능 추가 시

1. `shared/types/`에 타입 정의
2. `shared/api/`에 서비스 클래스 생성
3. `mobile/src/hooks/` 및 `web-app/lib/hooks/`에 React Query hooks 생성
4. 화면 컴포넌트 구현 (mobile & web)
5. Navigation 업데이트

### 코드 컨벤션

- TypeScript strict mode
- ESLint + Prettier
- Functional components + Hooks
- Named exports (services, hooks)
- Default export (screens, pages)

## 🐛 알려진 이슈

1. **비디오 재생**: Reels 기능은 기본 구조만 구현됨 (expo-av 필요)
2. **이미지 업로드**: 큰 이미지는 압축 필요
3. **실시간 기능**: WebSocket 미구현 (polling 방식 사용 중)

## 🔄 CI/CD

이 프로젝트는 **GitHub Actions**를 사용하여 자동 빌드, 테스트, 배포를 수행합니다.

### 워크플로우

- **Mobile Build** (`.github/workflows/mobile-build.yml`)
  - Lint, TypeScript 체크, 테스트
  - Android/iOS 프로덕션 빌드 (EAS Build)
  - OTA 업데이트 자동 배포
  - 스토어 자동 제출 (옵션)

- **Web Deploy** (`.github/workflows/web-deploy.yml`)
  - Lint, TypeScript 체크, 테스트
  - Next.js 프로덕션 빌드
  - Vercel 자동 배포
  - Lighthouse 성능 체크

- **PR Checks** (`.github/workflows/pr-checks.yml`)
  - PR 제목 형식 검증 (Conventional Commits)
  - 의존성 보안 취약점 검사
  - 민감한 파일 체크
  - 번들 사이즈 체크

- **Release** (`.github/workflows/release.yml`)
  - Git 태그 자동 생성
  - GitHub Release 생성
  - Changelog 자동 생성

- **CodeQL Security** (`.github/workflows/codeql.yml`)
  - 정적 코드 분석
  - 보안 취약점 스캔

### 배포 가이드

자세한 배포 방법은 **[DEPLOYMENT.md](./DEPLOYMENT.md)** 문서를 참조하세요.

## 🚀 최근 추가된 기능 (2025)

- ✅ **Investment UI 화면** - 포트폴리오 관리, 자산 분석, 관심종목 (Mobile & Web)
- ✅ **다크 모드** - 라이트/다크/시스템 자동 전환
- ✅ **Push Notifications (FCM)** - 실시간 알림 (좋아요, 댓글, 팔로우, 메시지)
- ✅ **PWA 지원** - 홈 화면에 추가, 오프라인 지원, Service Worker
- ✅ **WebSocket 실시간 업데이트** - 실시간 메시지, 타이핑 인디케이터, 온라인 상태
- ✅ **Performance Monitoring** - Sentry 에러 추적 및 성능 분석
- ✅ **비디오 녹화 및 편집** - Reels용 비디오 촬영, 필터, 음악 추가

## 🚀 향후 계획

- [ ] 다국어 지원 (i18n)
- [ ] E2E 테스트 (Detox / Playwright)
- [ ] AI 기반 콘텐츠 추천
- [ ] 라이브 스트리밍
- [ ] 그룹 채팅

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

- React Native Team
- Next.js Team
- TanStack Query Team
- 모든 오픈소스 기여자들

---

Made with ❤️ using React Native & Next.js
