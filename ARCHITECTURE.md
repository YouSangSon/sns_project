# 프로젝트 아키텍처

## 📐 전체 아키텍처 개요

```
┌─────────────────────────────────────────────────────────────┐
│                        Client Layer                          │
├──────────────────────────┬──────────────────────────────────┤
│   Flutter (Mobile)       │      Next.js 14 (Web)            │
│   ├── iOS                │      ├── SSR/CSR                 │
│   ├── Android            │      └── Responsive Design       │
│   └── Clean Architecture │                                  │
└──────────────────────────┴──────────────────────────────────┘
                           │
                           ▼ HTTP/REST
┌─────────────────────────────────────────────────────────────┐
│                  Backend API Server                          │
│   Kotlin + Spring Boot 3  /  Supabase                       │
│   ├── REST API Endpoints                                    │
│   ├── JWT Authentication                                    │
│   └── PostgreSQL Database                                   │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 설계 원칙

### 1. **Clean Architecture** (Mobile - Flutter)
- **Domain Layer**: 순수 비즈니스 로직 (Flutter 의존성 없음)
- **Data Layer**: 외부 데이터 소스 접근
- **Presentation Layer**: UI 및 상태 관리
- **Dependency Rule**: 안쪽 레이어는 바깥쪽을 모름

### 2. **타입 안전성** (Type Safety)
- **Flutter**: Dart strong typing + freezed 코드 생성
- **Web**: TypeScript Strict Mode
- **Null Safety**: Dart null safety, TypeScript strictNullChecks

### 3. **관심사의 분리** (Separation of Concerns)
- **Mobile (Flutter)**:
  - Entities: 핵심 비즈니스 객체
  - UseCases: 비즈니스 로직 캡슐화
  - Repositories: 데이터 접근 추상화
  - Providers: 상태 관리 (Riverpod)
- **Web (Next.js)**:
  - React Query: 서버 상태 관리
  - Zustand: 클라이언트 상태 관리

### 4. **확장성** (Scalability)
- **Feature-first**: 기능별 모듈화
- **DI (Dependency Injection)**: Riverpod으로 의존성 주입
- **Easy to Add Features**: 일관된 패턴

## 📂 레이어별 상세 설명

### 1. Client Layer

#### Flutter (Mobile) - Clean Architecture

**기술 스택:**
- Flutter 3.x + Dart 3.x
- Riverpod (상태 관리 + DI)
- Go Router (네비게이션)
- Dio (HTTP 클라이언트)
- freezed + json_serializable (코드 생성)
- dartz (함수형 에러 처리)

**디렉토리 구조:**
```
flutter_app/lib/
├── core/                    # 핵심 공통 모듈
│   ├── constants/           # AppColors, AppConfig, ApiEndpoints
│   ├── errors/              # Failure (freezed), Exceptions
│   ├── network/             # DioClient, AppRouter, Interceptors
│   └── utils/               # Extensions, Validators
│
├── features/                # Feature 모듈 (Feature-first)
│   └── {feature}/
│       ├── domain/          # 비즈니스 로직 (순수 Dart)
│       │   ├── entities/    # Entity 클래스 (freezed)
│       │   ├── repositories/# Repository 인터페이스
│       │   └── usecases/    # UseCase 클래스
│       ├── data/            # 데이터 접근
│       │   ├── datasources/ # Remote/Local DataSource
│       │   ├── models/      # DTO (freezed + json_serializable)
│       │   └── repositories/# Repository 구현체
│       └── presentation/    # UI
│           ├── providers/   # Riverpod StateNotifier
│           ├── pages/       # 화면
│           └── widgets/     # 위젯
│
└── shared/                  # 공유 모듈
    ├── providers/           # DI Providers
    └── widgets/             # 공통 위젯
```

**Clean Architecture 레이어:**

```
┌────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│   ┌────────────┐    ┌────────────┐    ┌────────────┐      │
│   │   Pages    │ ←  │  Providers │ ←  │   Widgets  │      │
│   └────────────┘    └─────┬──────┘    └────────────┘      │
└───────────────────────────┼────────────────────────────────┘
                            │ depends on
┌───────────────────────────▼────────────────────────────────┐
│                      Domain Layer                           │
│   ┌────────────┐    ┌────────────┐    ┌────────────┐      │
│   │  UseCases  │ →  │Repositories│ ←  │  Entities  │      │
│   │            │    │ (interface)│    │            │      │
│   └────────────┘    └─────┬──────┘    └────────────┘      │
└───────────────────────────┼────────────────────────────────┘
                            │ implements
┌───────────────────────────▼────────────────────────────────┐
│                       Data Layer                            │
│   ┌────────────┐    ┌────────────┐    ┌────────────┐      │
│   │DataSources │ →  │Repositories│ →  │   Models   │      │
│   │            │    │   (impl)   │    │   (DTO)    │      │
│   └────────────┘    └────────────┘    └────────────┘      │
└────────────────────────────────────────────────────────────┘
```

#### Next.js 14 (Web)

**기술 스택:**
- Next.js 14 (App Router)
- Tailwind CSS
- React Query
- Zustand
- TypeScript

**디렉토리 구조:**
```
web-app/
├── app/              # App Router (페이지)
├── lib/
│   ├── hooks/       # Custom React Query Hooks
│   └── stores/      # Zustand stores
├── components/       # 재사용 컴포넌트
└── public/           # 정적 파일
```

### 2. Flutter Clean Architecture 상세

#### Domain Layer (비즈니스 로직)

**순수 Dart로 작성 - Flutter 의존성 없음**

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
  Future<Either<Failure, (UserEntity, AuthTokens)>> login({
    required String email,
    required String password,
  });
}

// UseCase
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, (UserEntity, AuthTokens)>> call({
    required String email,
    required String password,
  }) => _repository.login(email: email, password: password);
}
```

#### Data Layer (데이터 접근)

**DTO 변환 및 외부 데이터 소스 접근**

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
  final AuthLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, (UserEntity, AuthTokens)>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return Right((response.user.toEntity(), tokens));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } on NetworkException {
      return Left(const Failure.network());
    }
  }
}
```

#### Presentation Layer (UI)

**Riverpod으로 상태 관리**

```dart
// State (freezed)
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.error(String message) = _Error;
}

// Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;

  AuthNotifier({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(const AuthState.initial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) => state = AuthState.error(failure.errorMessage),
      (data) => state = AuthState.authenticated(data.$1),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      authenticated: (user) => const FeedPage(),
      error: (message) => _buildLoginForm(error: message),
    );
  }
}
```

### 3. State Management

#### React Query (Server State)

**사용 이유:**
- 서버 데이터 캐싱 및 동기화
- 자동 재요청 (stale-while-revalidate)
- Optimistic UI 업데이트
- 무한 스크롤 지원

**Hook 패턴:**
```typescript
// Query Keys
export const POST_KEYS = {
  all: ['posts'] as const,
  lists: () => [...POST_KEYS.all, 'list'] as const,
  list: (params) => [...POST_KEYS.lists(), params] as const,
  detail: (postId) => [...POST_KEYS.all, 'detail', postId] as const,
};

// Query Hook
export const useFeed = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: POST_KEYS.list(params),
    queryFn: ({ pageParam = 1 }) =>
      postsService.getFeed({ ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

// Mutation Hook
export const useCreatePost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreatePostDto) => postsService.createPost(data),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: POST_KEYS.lists(),
      });
    },
  });
};
```

#### Zustand (Client State)

**사용 이유:**
- 간단한 API
- TypeScript 친화적
- Persist 미들웨어
- 작은 번들 사이즈

**Store 예시:**
```typescript
interface AuthState {
  token: string | null;
  user: User | null;
  isAuthenticated: boolean;

  login: (token: string, user: User) => void;
  logout: () => void;
  updateUser: (user: User) => void;
  loadAuth: () => Promise<void>;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      token: null,
      user: null,
      isAuthenticated: false,

      login: (token, user) => {
        apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        set({ token, user, isAuthenticated: true });
      },

      logout: () => {
        delete apiClient.defaults.headers.common['Authorization'];
        AsyncStorage.removeItem('auth-storage');
        set({ token: null, user: null, isAuthenticated: false });
      },

      updateUser: (user) => set({ user }),

      loadAuth: async () => {
        const stored = await AsyncStorage.getItem('auth-storage');
        if (stored) {
          const { state } = JSON.parse(stored);
          if (state.token) {
            apiClient.defaults.headers.common['Authorization'] =
              `Bearer ${state.token}`;
            set(state);
          }
        }
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

## 🔐 인증 플로우

```
┌─────────────┐
│   User      │
└─────┬───────┘
      │
      │ 1. Enter credentials
      ▼
┌─────────────────────────┐
│  Login Screen           │
│  (useAuthStore.login)   │
└─────────┬───────────────┘
          │
          │ 2. POST /api/v1/auth/login
          ▼
┌─────────────────────────┐
│  Backend API            │
│  (Verify credentials)   │
└─────────┬───────────────┘
          │
          │ 3. Return JWT token + User
          ▼
┌─────────────────────────┐
│  Axios Interceptor      │
│  (Set Authorization     │
│   header)               │
└─────────┬───────────────┘
          │
          │ 4. Store in Zustand + AsyncStorage
          ▼
┌─────────────────────────┐
│  App State              │
│  isAuthenticated: true  │
└─────────┬───────────────┘
          │
          │ 5. Navigate to Main App
          ▼
┌─────────────────────────┐
│  Main Tabs              │
│  (Feed, Profile, etc)   │
└─────────────────────────┘

// Token Refresh Flow
┌─────────────────────────┐
│  API Request            │
│  (with expired token)   │
└─────────┬───────────────┘
          │
          │ Response 401 Unauthorized
          ▼
┌─────────────────────────┐
│  Axios Interceptor      │
│  (Detect 401)           │
└─────────┬───────────────┘
          │
          │ POST /api/v1/auth/refresh
          ▼
┌─────────────────────────┐
│  Backend API            │
│  (Issue new token)      │
└─────────┬───────────────┘
          │
          │ New JWT token
          ▼
┌─────────────────────────┐
│  Retry original request │
│  (with new token)       │
└─────────────────────────┘
```

## 📱 Navigation 구조

### React Native

```
RootNavigator
├── AuthStack (Not Authenticated)
│   ├── Login
│   └── Signup
│
└── Main (Authenticated)
    ├── MainTabs (Bottom Tab Navigator)
    │   ├── Home (FeedScreen)
    │   ├── Search (SearchScreen)
    │   ├── CreatePost (CreatePostScreen)
    │   ├── Notifications (NotificationsScreen)
    │   └── Profile (ProfileScreen)
    │
    └── Stack Screens
        ├── PostDetail
        ├── UserProfile
        ├── EditProfile
        ├── Messages
        ├── Chat
        ├── Stories
        ├── CreateStory
        ├── Bookmarks
        └── Reels
```

### Next.js

```
app/
├── auth/
│   ├── login/page.tsx
│   └── signup/page.tsx
│
├── page.tsx (홈/피드)
├── posts/
│   ├── [postId]/page.tsx
│   └── create/page.tsx
│
├── profile/
│   ├── [userId]/page.tsx
│   └── edit/page.tsx
│
├── messages/
│   ├── page.tsx
│   └── [conversationId]/page.tsx
│
├── notifications/page.tsx
├── stories/
│   ├── [userId]/page.tsx
│   └── create/page.tsx
│
├── bookmarks/page.tsx
└── reels/page.tsx
```

## 🔄 데이터 흐름

### 게시물 생성 예시

```
┌──────────────────┐
│  CreatePostScreen│
│  (User uploads   │
│   photo + caption)
└────────┬─────────┘
         │
         │ 1. useCreatePost()
         ▼
┌──────────────────┐
│  Custom Hook     │
│  (useMutation)   │
└────────┬─────────┘
         │
         │ 2. postsService.createPost()
         ▼
┌──────────────────┐
│  API Service     │
│  (Axios POST)    │
└────────┬─────────┘
         │
         │ 3. POST /api/v1/posts
         ▼
┌──────────────────┐
│  Backend API     │
│  (Validate +     │
│   Save to DB)    │
└────────┬─────────┘
         │
         │ 4. Return Post object
         ▼
┌──────────────────┐
│  React Query     │
│  (onSuccess:     │
│   invalidate feed)
└────────┬─────────┘
         │
         │ 5. Refetch feed
         ▼
┌──────────────────┐
│  Feed Screen     │
│  (Show new post) │
└──────────────────┘
```

### 무한 스크롤 예시

```
┌──────────────────┐
│  FeedScreen      │
│  (useInfiniteQuery)
└────────┬─────────┘
         │
         │ Initial load: page=1
         ▼
┌──────────────────┐
│  API Service     │
│  getFeed({page:1})
└────────┬─────────┘
         │
         │ GET /api/v1/posts/feed?page=1&limit=20
         ▼
┌──────────────────┐
│  Backend         │
│  Returns:        │
│  - data: Post[]  │
│  - hasMore: true │
└────────┬─────────┘
         │
         │ React Query caches result
         ▼
┌──────────────────┐
│  FlatList        │
│  (Display posts) │
└────────┬─────────┘
         │
         │ User scrolls to end
         │ onEndReached()
         ▼
┌──────────────────┐
│  fetchNextPage() │
│  (page=2)        │
└────────┬─────────┘
         │
         │ GET /api/v1/posts/feed?page=2&limit=20
         ▼
┌──────────────────┐
│  Append new data │
│  to existing list│
└──────────────────┘
```

## 🎨 UI 패턴

### Optimistic UI (좋아요 예시)

```typescript
export const useLikePost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (postId: string) => postsService.likePost(postId),

    // Optimistic Update: UI 즉시 업데이트
    onMutate: async (postId) => {
      // 진행 중인 refetch 취소
      await queryClient.cancelQueries({ queryKey: POST_KEYS.detail(postId) });

      // 이전 데이터 백업
      const previousPost = queryClient.getQueryData(POST_KEYS.detail(postId));

      // 낙관적 업데이트
      queryClient.setQueryData(POST_KEYS.detail(postId), (old: Post) => ({
        ...old,
        likes: old.likes + 1,
        isLiked: true,
      }));

      return { previousPost };
    },

    // 에러 시 롤백
    onError: (err, postId, context) => {
      queryClient.setQueryData(POST_KEYS.detail(postId), context.previousPost);
    },

    // 성공 시 서버 데이터로 동기화
    onSuccess: (_, postId) => {
      queryClient.invalidateQueries({ queryKey: POST_KEYS.detail(postId) });
    },
  });
};
```

### Pull to Refresh

```typescript
const { data, refetch, isRefetching } = useFeed();

<FlatList
  data={posts}
  refreshing={isRefetching}
  onRefresh={refetch}
  // ...
/>
```

## 🔧 개발 도구

### TypeScript 설정

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

### ESLint + Prettier

```json
// .eslintrc.json
{
  "extends": [
    "expo",
    "prettier"
  ],
  "plugins": ["prettier"],
  "rules": {
    "prettier/prettier": "error",
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/explicit-function-return-type": "off"
  }
}
```

## 📊 성능 최적화

### 1. React Query 캐싱 전략

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5분
      cacheTime: 1000 * 60 * 30, // 30분
      retry: 3,
      refetchOnWindowFocus: false,
    },
  },
});
```

### 2. Image Optimization

**Mobile:**
```typescript
import { Image } from 'expo-image';

<Image
  source={{ uri: imageUrl }}
  contentFit="cover"
  transition={200}
  cachePolicy="memory-disk"
/>
```

**Web:**
```typescript
import Image from 'next/image';

<Image
  src={imageUrl}
  alt="Post"
  fill
  sizes="(max-width: 768px) 100vw, 50vw"
  priority
/>
```

### 3. Code Splitting (Web)

```typescript
// Dynamic import
const InvestmentPortfolio = dynamic(
  () => import('./components/InvestmentPortfolio'),
  { loading: () => <Loading /> }
);
```

## 🔮 확장 가능성

### 새로운 기능 추가 시 체크리스트

- [ ] `shared/types/`에 타입 정의
- [ ] `shared/constants/api.ts`에 API 엔드포인트 추가
- [ ] `shared/api/`에 서비스 클래스 생성
- [ ] `mobile/src/hooks/`에 React Query hooks 생성
- [ ] `web-app/lib/hooks/`에 동일한 hooks 복사
- [ ] Mobile 화면 컴포넌트 구현
- [ ] Web 페이지 컴포넌트 구현
- [ ] Navigation 타입 및 라우팅 업데이트
- [ ] 테스트 작성

### 백엔드 API와의 계약

**Request/Response 형식:**
```typescript
// Request
POST /api/v1/posts
Content-Type: application/json
Authorization: Bearer {token}

{
  "caption": "Hello World",
  "imageUrls": ["https://..."],
  "hashtags": ["#hello", "#world"]
}

// Response
200 OK
Content-Type: application/json

{
  "postId": "uuid",
  "userId": "uuid",
  "username": "john",
  "caption": "Hello World",
  "imageUrls": ["https://..."],
  "hashtags": ["#hello", "#world"],
  "likes": 0,
  "comments": 0,
  "createdAt": "2025-01-01T00:00:00Z"
}
```

## 📝 베스트 프랙티스

### 1. 에러 핸들링

```typescript
try {
  const post = await postsService.createPost(data);
  Alert.alert('성공', '게시물이 생성되었습니다.');
} catch (error) {
  if (error.response?.status === 401) {
    Alert.alert('인증 오류', '다시 로그인해주세요.');
    navigation.navigate('Login');
  } else {
    Alert.alert('오류', '게시물 생성에 실패했습니다.');
  }
}
```

### 2. Loading States

```typescript
const { data, isLoading, error } = useFeed();

if (isLoading) return <Loading />;
if (error) return <Error message={error.message} />;

return <FlatList data={data.pages.flatMap(p => p.data)} />;
```

### 3. 타입 가드

```typescript
function isPost(item: Post | Reel): item is Post {
  return 'caption' in item;
}

if (isPost(item)) {
  // TypeScript knows item is Post
  console.log(item.caption);
}
```

---

이 아키텍처는 확장 가능하고, 유지보수가 쉬우며, 타입 안전한 풀스택 SNS 애플리케이션을 구축하기 위해 설계되었습니다.
