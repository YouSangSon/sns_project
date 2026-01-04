# Mock 서버 가이드

백엔드 없이 Flutter 앱을 개발하고 테스트하기 위한 Mock 데이터 시스템 가이드입니다.

## 📋 목차

1. [개요](#개요)
2. [Mock 모드 활성화](#mock-모드-활성화)
3. [Mock 데이터 구조](#mock-데이터-구조)
4. [사용 방법](#사용-방법)
5. [커스텀 Mock 데이터](#커스텀-mock-데이터)

---

## 📖 개요

Mock 서버는 실제 백엔드 없이 앱을 개발할 수 있게 해주는 기능입니다.

### 장점

- ✅ **빠른 개발**: 백엔드 서버 없이 즉시 시작
- ✅ **오프라인 작업**: 인터넷 연결 불필요
- ✅ **UI 테스트**: 다양한 데이터 시나리오 테스트
- ✅ **데모**: 실제 데이터 없이 앱 시연

### 제한사항

- ❌ 실제 API 호출 테스트 불가
- ❌ 데이터 영속성 없음 (앱 재시작 시 초기화)
- ❌ 실시간 기능 (메시지, 알림) 제한적

---

## 🔧 Mock 모드 활성화

### 1. 환경 설정 파일 수정

`flutter_app/config/dev.yaml` 파일을 열고:

```yaml
# Feature Flags
features:
  enable_mock_data: true  # 이 값을 true로 설정
```

### 2. 앱 실행

```bash
flutter run --dart-define=ENV=dev
```

또는 기본값이 dev이므로:

```bash
flutter run
```

### 3. Mock 모드 확인

앱 실행 시 콘솔에 다음 메시지가 표시됩니다:

```
✅ EnvConfig initialized: development
   API Base URL: http://localhost:8080
   Mock Data: true
```

---

## 📊 Mock 데이터 구조

### Mock 데이터 제공자

**위치**: `lib/core/mock/mock_data.dart`

Mock 데이터는 다음과 같은 엔티티를 포함합니다:

```dart
class MockData {
  // 사용자
  static List<UserEntity> get users;

  // 게시물
  static List<PostEntity> get posts;

  // 댓글
  static List<CommentEntity> get comments;

  // 메시지
  static List<MessageEntity> get messages;

  // 알림
  static List<NotificationEntity> get notifications;

  // 스토리
  static List<StoryEntity> get stories;
}
```

### 기본 테스트 계정

Mock 모드에서는 다음 계정으로 로그인할 수 있습니다:

```
이메일: test@example.com
비밀번호: (아무거나 입력 가능)
```

---

## 🚀 사용 방법

### DataSource 레벨에서 Mock 분기

**예시**: `auth_remote_datasource.dart`

```dart
import '../../core/config/env_config.dart';
import '../../core/mock/mock_data.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    // Mock 모드 체크
    if (EnvConfig.instance.enableMockData) {
      // Mock 데이터 반환
      await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

      return LoginResponseModel(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        user: MockData.currentUser,
      );
    }

    // 실제 API 호출
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    return LoginResponseModel.fromJson(response.data);
  }
}
```

### Repository 레벨에서 Mock 분기

**예시**: `post_repository_impl.dart`

```dart
class PostRepositoryImpl implements PostRepository {
  @override
  Future<Either<Failure, List<PostEntity>>> getFeed({
    required int page,
    required int limit,
  }) async {
    try {
      if (EnvConfig.instance.enableMockData) {
        // Mock 데이터
        await Future.delayed(const Duration(milliseconds: 500));

        final posts = MockData.posts
            .skip(page * limit)
            .take(limit)
            .toList();

        return Right(posts);
      }

      // 실제 API 호출
      final posts = await _remoteDataSource.getFeed(page: page, limit: limit);
      return Right(posts.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    }
  }
}
```

---

## 🎨 커스텀 Mock 데이터

### Mock 데이터 추가

**위치**: `lib/core/mock/mock_data.dart`

```dart
class MockData {
  // 사용자 목록
  static List<UserEntity> get users => [
    UserEntity(
      id: '1',
      email: 'alice@example.com',
      username: 'alice',
      displayName: 'Alice Johnson',
      bio: 'Travel enthusiast 🌍',
      profileImageUrl: 'https://i.pravatar.cc/150?img=1',
      followersCount: 1234,
      followingCount: 567,
      postsCount: 89,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    UserEntity(
      id: '2',
      email: 'bob@example.com',
      username: 'bob',
      displayName: 'Bob Smith',
      bio: 'Photographer 📷',
      profileImageUrl: 'https://i.pravatar.cc/150?img=2',
      followersCount: 5678,
      followingCount: 890,
      postsCount: 234,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    // 더 많은 사용자 추가...
  ];

  // 현재 로그인 사용자
  static UserEntity get currentUser => users.first;

  // 게시물 목록
  static List<PostEntity> get posts => [
    PostEntity(
      id: '1',
      userId: '1',
      caption: 'Beautiful sunset 🌅',
      imageUrls: [
        'https://picsum.photos/seed/1/800/600',
        'https://picsum.photos/seed/2/800/600',
      ],
      likesCount: 234,
      commentsCount: 12,
      isLiked: false,
      isBookmarked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      user: users[0],
    ),
    PostEntity(
      id: '2',
      userId: '2',
      caption: 'Coffee time ☕',
      imageUrls: [
        'https://picsum.photos/seed/3/800/600',
      ],
      likesCount: 567,
      commentsCount: 34,
      isLiked: true,
      isBookmarked: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      user: users[1],
    ),
    // 더 많은 게시물 추가...
  ];

  // 댓글 목록
  static List<CommentEntity> commentsForPost(String postId) {
    return [
      CommentEntity(
        id: '1',
        postId: postId,
        userId: '2',
        text: 'Amazing photo! 😍',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        user: users[1],
      ),
      // 더 많은 댓글...
    ];
  }
}
```

### 동적 Mock 데이터

시간에 따라 변하는 데이터:

```dart
class MockData {
  // 랜덤 좋아요 수
  static int get randomLikesCount =>
      Random().nextInt(1000) + 10;

  // 최근 게시물 (항상 현재 시간 기준)
  static List<PostEntity> get recentPosts {
    final now = DateTime.now();
    return posts.map((post) {
      return post.copyWith(
        createdAt: now.subtract(
          Duration(hours: Random().nextInt(24)),
        ),
      );
    }).toList();
  }
}
```

---

## 🔄 Mock과 실제 API 전환

### 런타임에 전환

개발 중 Mock과 실제 API를 쉽게 전환하려면:

**디버그 메뉴 추가** (`lib/features/settings/presentation/pages/debug_menu_page.dart`):

```dart
class DebugMenuPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Menu')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mock 데이터 사용'),
            subtitle: Text(
              EnvConfig.instance.enableMockData
                ? 'Mock 데이터 모드'
                : '실제 API 모드'
            ),
            value: EnvConfig.instance.enableMockData,
            onChanged: (value) {
              // TODO: 런타임 전환 구현
              // 앱 재시작 필요
            },
          ),

          ListTile(
            title: const Text('환경 정보'),
            subtitle: Text(
              'Environment: ${EnvConfig.instance.environment}\n'
              'API: ${EnvConfig.instance.apiBaseUrl}'
            ),
          ),
        ],
      ),
    );
  }
}
```

### 빌드 타임에 전환

```bash
# Mock 모드 (개발)
flutter run --dart-define=ENV=dev

# 실제 API 모드 (스테이징)
flutter run --dart-define=ENV=staging
```

---

## 📝 Mock 데이터 시나리오

### 1. 빈 상태 테스트

```dart
class MockData {
  static List<PostEntity> get emptyFeed => [];

  static List<NotificationEntity> get noNotifications => [];
}
```

### 2. 에러 시나리오

```dart
class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    if (EnvConfig.instance.enableMockData) {
      await Future.delayed(const Duration(seconds: 1));

      // 특정 이메일로 에러 시뮬레이션
      if (email == 'error@example.com') {
        throw ServerException(message: 'Invalid credentials');
      }

      return MockData.loginResponse;
    }

    // 실제 API...
  }
}
```

### 3. 로딩 지연 시뮬레이션

```dart
if (EnvConfig.instance.enableMockData) {
  // 느린 네트워크 시뮬레이션
  await Future.delayed(const Duration(seconds: 3));

  return MockData.posts;
}
```

---

## 🧪 테스트에서 Mock 사용

### Unit Test

```dart
test('Mock 데이터로 피드를 가져와야 한다', () async {
  // Arrange
  final repository = PostRepositoryImpl(
    remoteDataSource: mockRemoteDataSource,
  );

  when(mockRemoteDataSource.getFeed())
      .thenAnswer((_) async => MockData.posts);

  // Act
  final result = await repository.getFeed(page: 0, limit: 10);

  // Assert
  expect(result.isRight(), true);
});
```

### Widget Test

```dart
testWidgets('Mock 데이터로 피드 렌더링', (tester) async {
  await tester.pumpWidget(
    createTestableWidget(
      overrides: [
        feedProvider.overrideWith((ref) => MockData.posts),
      ],
      child: FeedPage(),
    ),
  );

  expect(find.byType(PostCard), findsWidgets);
});
```

---

## 🎯 Best Practices

### 1. 일관된 Mock 데이터

```dart
// ✅ 좋은 예: 중앙 집중식 Mock 데이터
class MockData {
  static final currentUser = UserEntity(...);
}

// ❌ 나쁜 예: 여러 곳에서 직접 생성
final user = UserEntity(id: '1', ...);
```

### 2. 현실적인 데이터

```dart
// ✅ 좋은 예
static List<PostEntity> get posts => [
  PostEntity(
    caption: 'Just finished my morning run! 🏃‍♂️ #fitness',
    likesCount: 234,  // 현실적인 수치
  ),
];

// ❌ 나쁜 예
static List<PostEntity> get posts => [
  PostEntity(
    caption: 'test',
    likesCount: 999999,  // 비현실적
  ),
];
```

### 3. Mock 플래그 명확히

```dart
// ✅ 좋은 예
if (EnvConfig.instance.enableMockData) {
  return MockData.posts;
}

// ❌ 나쁜 예
if (kDebugMode) {  // 디버그 모드와 Mock 모드는 다름
  return MockData.posts;
}
```

---

## 🔍 트러블슈팅

### Mock 데이터가 표시되지 않음

**확인 사항**:
1. `config/dev.yaml`에서 `enable_mock_data: true`인지 확인
2. `EnvConfig.initialize()`가 호출되었는지 확인
3. 콘솔에서 "Mock Data: true" 로그 확인

### 앱 재시작 시 데이터 사라짐

**해결**: Mock 데이터는 메모리에만 저장되므로 정상입니다.
영속성이 필요하다면 `shared_preferences` 또는 로컬 DB 사용을 고려하세요.

---

## 📚 추가 자료

- [Flutter 개발 환경 가이드](./DEVELOPMENT.md)
- [테스트 가이드](./flutter_app/test/README.md)
- [Supabase 설정](./SUPABASE_SETUP.md)

---

**Happy Mocking! 🎭**
