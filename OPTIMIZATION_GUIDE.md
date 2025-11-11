# 🚀 SNS App - Optimization Guide

이 문서는 SNS 앱에 적용된 UI/UX 최적화, 성능 최적화, 테스트 전략에 대해 설명합니다.

## 📑 목차

1. [UI/UX 최적화](#uiux-최적화)
2. [성능 최적화](#성능-최적화)
3. [테스트 전략](#테스트-전략)
4. [모범 사례](#모범-사례)

---

## UI/UX 최적화

### 🎨 애니메이션 시스템

#### 페이지 전환 애니메이션
`lib/core/animations/page_transitions.dart`에 구현된 다양한 전환 효과:

```dart
// 슬라이드 전환
Navigator.push(
  context,
  SlideRightRoute(page: NextScreen()),
);

// 페이드 전환
Navigator.push(
  context,
  FadeRoute(page: NextScreen()),
);

// 스케일 전환
Navigator.push(
  context,
  ScaleRoute(page: NextScreen()),
);

// 복합 전환 (페이드 + 스케일)
Navigator.push(
  context,
  FadeScaleRoute(page: NextScreen()),
);
```

**사용 가능한 전환:**
- `SlideRightRoute` - 오른쪽에서 슬라이드
- `FadeRoute` - 페이드 인/아웃
- `ScaleRoute` - 확대/축소
- `SlideUpRoute` - 아래에서 슬라이드 (바텀시트용)
- `FadeScaleRoute` - 페이드 + 스케일 조합
- `RotationFadeRoute` - 회전 + 페이드
- `SharedAxisRoute` - Material 공유 축 전환

#### 마이크로 인터랙션

**바운스 버튼:**
```dart
BounceButton(
  onTap: () {
    // 탭 이벤트 처리
  },
  child: Text('Press Me'),
)
```

**애니메이션 좋아요 버튼:**
```dart
AnimatedLikeButton(
  isLiked: isLiked,
  onTap: () {
    setState(() {
      isLiked = !isLiked;
    });
  },
  size: 28,
)
```

**페이드 인 애니메이션:**
```dart
FadeInAnimation(
  delay: Duration(milliseconds: 200),
  duration: Duration(milliseconds: 500),
  child: YourWidget(),
)
```

**슬라이드 인 애니메이션:**
```dart
SlideInAnimation(
  delay: Duration(milliseconds: 200),
  child: YourWidget(),
)
```

**Staggered 리스트 애니메이션:**
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return StaggeredListAnimation(
      index: index,
      child: ListItem(),
    );
  },
)
```

**펄스 애니메이션:**
```dart
PulseAnimation(
  child: Icon(Icons.notifications),
)
```

### 💀 로딩 스켈레톤

사용자 경험 향상을 위한 스켈레톤 로더들:

```dart
// 게시물 카드 스켈레톤
PostCardSkeleton()

// 사용자 프로필 스켈레톤
UserProfileSkeleton()

// 그리드 스켈레톤
GridSkeleton(itemCount: 9)

// 리스트 아이템 스켈레톤
ListItemSkeleton(itemCount: 5)

// 스토리 서클 스켈레톤
StoryCircleSkeleton()

// 상품 카드 스켈레톤
ProductCardSkeleton()

// 댓글 스켈레톤
CommentSkeleton(itemCount: 3)
```

**Shimmer 효과:**
```dart
ShimmerLoading(
  baseColor: Color(0xFFE0E0E0),
  highlightColor: Color(0xFFF5F5F5),
  child: YourWidget(),
)
```

---

## 성능 최적화

### 🔄 페이지네이션 및 무한 스크롤

#### PaginationController 사용법

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final ScrollController _scrollController = ScrollController();
  late PaginationController<PostModel> _paginationController;

  @override
  void initState() {
    super.initState();
    _paginationController = PaginationController<PostModel>(
      fetchItems: _fetchPosts,
      scrollController: _scrollController,
      pageSize: 20,
    );
  }

  Future<List<PostModel>> _fetchPosts(int page, int pageSize) async {
    // API 호출 또는 데이터베이스 쿼리
    final posts = await databaseService.getPosts(
      offset: page * pageSize,
      limit: pageSize,
    );
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedListView<PostModel>(
      controller: _paginationController,
      itemBuilder: (context, post, index) {
        return PostCard(post: post);
      },
      emptyBuilder: (context) {
        return Center(child: Text('No posts found'));
      },
      errorBuilder: (context, error) {
        return Center(child: Text('Error: $error'));
      },
    );
  }

  @override
  void dispose() {
    _paginationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
```

#### PaginatedGridView 사용법

```dart
PaginatedGridView<ProductModel>(
  controller: _paginationController,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.7,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  itemBuilder: (context, product, index) {
    return ProductCard(product: product);
  },
)
```

**주요 기능:**
- ✅ 자동 무한 스크롤 (80% 지점에서 트리거)
- ✅ Pull-to-refresh
- ✅ 에러 핸들링 및 재시도
- ✅ 로딩 상태 관리
- ✅ 빈 상태 처리

### 💾 캐싱 시스템

#### CacheManager (영구 캐시)

```dart
final cacheManager = CacheManager();

// 초기화
await cacheManager.init();

// 데이터 저장 (만료 시간 설정)
await cacheManager.set(
  'user_profile_123',
  userData,
  expiry: Duration(hours: 24),
);

// 데이터 가져오기
final userData = await cacheManager.get<Map>('user_profile_123');

// 데이터 삭제
await cacheManager.remove('user_profile_123');

// 전체 캐시 삭제
await cacheManager.clearAll();
```

#### MemoryCache (메모리 캐시)

```dart
// 캐시 생성
final cache = MemoryCache<String, UserModel>(
  maxSize: 100,
  defaultExpiry: Duration(minutes: 30),
);

// 저장
cache.set('user_123', userModel);

// 가져오기
final user = cache.get('user_123');

// 만료 시간 지정
cache.set(
  'user_123',
  userModel,
  expiry: Duration(hours: 1),
);

// 확인
if (cache.has('user_123')) {
  // 캐시 존재
}

// 삭제
cache.remove('user_123');
cache.clear(); // 전체 삭제
```

**캐시 전략:**

```dart
// 사용자 프로필 캐싱 예제
Future<UserModel?> getUserProfile(String userId) async {
  // 1. 메모리 캐시 확인
  final cached = _memoryCache.get(userId);
  if (cached != null) return cached;

  // 2. 영구 캐시 확인
  final persisted = await _cacheManager.get<Map>(
    CacheKeys.userProfileKey(userId),
  );
  if (persisted != null) {
    final user = UserModel.fromMap(persisted);
    _memoryCache.set(userId, user);
    return user;
  }

  // 3. 네트워크에서 가져오기
  final user = await _databaseService.getUserById(userId);
  if (user != null) {
    // 양쪽 캐시에 저장
    _memoryCache.set(userId, user);
    await _cacheManager.set(
      CacheKeys.userProfileKey(userId),
      user.toMap(),
      expiry: Duration(hours: 24),
    );
  }

  return user;
}
```

### 🖼️ 이미지 최적화

앱은 이미 `cached_network_image` 패키지를 사용하고 있습니다:

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => ShimmerLoading(
    child: Container(color: Colors.grey[300]),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheHeight: 800, // 메모리 캐시 최적화
  memCacheWidth: 800,
)
```

**권장 사항:**
- 썸네일에는 작은 크기 사용
- 적절한 캐시 크기 설정
- 에러 핸들링 구현

---

## 테스트 전략

### 🧪 유닛 테스트

**모델 테스트 (`test/models/`)**

```bash
flutter test test/models/user_model_test.dart
flutter test test/models/post_model_test.dart
```

**테스트 커버리지:**
- ✅ fromMap 변환
- ✅ toMap 변환
- ✅ copyWith 메서드
- ✅ 기본값 처리
- ✅ 해시태그 추출 (PostModel)

**유틸리티 테스트 (`test/utils/`)**

```bash
flutter test test/utils/cache_manager_test.dart
```

**테스트 커버리지:**
- ✅ 값 저장 및 조회
- ✅ 만료 시간 처리
- ✅ LRU 캐시 eviction
- ✅ 최대 크기 제한

### 🎨 위젯 테스트

**애니메이션 위젯 테스트 (`test/widgets/`)**

```bash
flutter test test/widgets/bounce_button_test.dart
```

**테스트 커버리지:**
- ✅ BounceButton 탭 애니메이션
- ✅ AnimatedLikeButton 상태 변경
- ✅ FadeInAnimation 지연 시간
- ✅ SlideInAnimation 동작
- ✅ PulseAnimation 반복

### 🔗 통합 테스트

**앱 통합 테스트 (`integration_test/`)**

```bash
flutter test integration_test/app_test.dart
```

**테스트 시나리오:**
- ✅ 앱 로딩 및 로그인 화면 표시
- ✅ 회원가입 화면으로 네비게이션
- ✅ 빈 로그인 폼 검증
- ✅ 비밀번호 필드 obscureText
- ✅ 화면 간 네비게이션
- ✅ 다양한 화면 크기 대응

**통합 테스트 실행:**

```bash
# Android
flutter test integration_test/app_test.dart

# iOS
flutter test integration_test/app_test.dart --device-id=<device-id>
```

### 📊 테스트 커버리지

**전체 테스트 실행:**

```bash
# 모든 유닛/위젯 테스트
flutter test

# 커버리지 리포트 생성
flutter test --coverage

# HTML 리포트 생성 (genhtml 필요)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**목표 커버리지:**
- 모델: 90%+
- 유틸리티: 85%+
- 위젯: 70%+
- 통합: 주요 플로우 커버

---

## 모범 사례

### ⚡ 성능 최적화 체크리스트

- [ ] 이미지에 `CachedNetworkImage` 사용
- [ ] 긴 리스트에 `PaginatedListView` 사용
- [ ] 자주 사용하는 데이터에 `MemoryCache` 적용
- [ ] 로딩 중 스켈레톤 UI 표시
- [ ] `const` 생성자 최대한 활용
- [ ] 불필요한 `setState` 호출 최소화
- [ ] `ListView.builder` 사용 (전체 리스트 렌더링 X)
- [ ] 큰 위젯 트리에서 `RepaintBoundary` 사용

### 🎯 UI/UX 최적화 체크리스트

- [ ] 모든 버튼에 적절한 피드백 애니메이션
- [ ] 페이지 전환에 부드러운 애니메이션 적용
- [ ] 로딩 상태에 스켈레톤 UI 표시
- [ ] 에러 상태에 명확한 메시지와 재시도 버튼
- [ ] 빈 상태에 의미 있는 메시지와 액션
- [ ] Pull-to-refresh 제스처 지원
- [ ] 적절한 터치 타겟 크기 (최소 48x48)
- [ ] 색상 대비 접근성 준수

### 🧪 테스트 모범 사례

- [ ] 모든 public 메서드에 유닛 테스트
- [ ] 핵심 사용자 플로우에 통합 테스트
- [ ] 위젯 렌더링 테스트
- [ ] 에지 케이스 및 에러 처리 테스트
- [ ] Mock 데이터 사용으로 테스트 격리
- [ ] CI/CD에서 자동 테스트 실행

### 📱 크로스 플랫폼 고려사항

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // 웹 전용 로직
} else {
  // 모바일 전용 로직
}
```

**플랫폼별 최적화:**
- 웹: 큰 번들 크기 주의, code splitting 고려
- 모바일: 배터리 및 메모리 관리
- 태블릿: 반응형 레이아웃

---

## 📈 성능 모니터링

### DevTools 사용

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

**모니터링 항목:**
- CPU 사용률
- 메모리 사용량
- 프레임 렌더링 속도
- 네트워크 요청

### 성능 프로파일링

```bash
flutter run --profile
```

**주의 사항:**
- Debug 모드는 성능이 느립니다
- Profile/Release 모드에서 성능 측정
- 실제 기기에서 테스트 (에뮬레이터 X)

---

## 🔧 추가 최적화 제안

1. **이미지 압축**: 업로드 전 이미지 압축
2. **비디오 스트리밍**: HLS/DASH 사용
3. **데이터베이스 인덱싱**: Firestore 복합 인덱스
4. **CDN 사용**: 정적 assets
5. **서버 사이드 캐싱**: API 응답 캐싱
6. **Rate Limiting**: API 호출 제한
7. **Lazy Loading**: 화면 밖 콘텐츠 지연 로딩
8. **Tree Shaking**: 사용하지 않는 코드 제거

---

## 📚 참고 자료

- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/rendering/best-practices)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Material Design Guidelines](https://material.io/design)

---

**마지막 업데이트**: 2025-11-11
**작성자**: Claude AI
