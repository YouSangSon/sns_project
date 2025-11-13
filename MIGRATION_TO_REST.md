# Migration Guide: Firebase/Firestore → REST API

이 문서는 앱을 직접 Firebase/Firestore 접근에서 REST API 서버를 통한 접근으로 마이그레이션하는 방법을 설명합니다.

## 아키텍처 변경

### Before (Firebase 직접 접근)
```
Flutter App
    ↓ (Firebase SDK)
Firebase Authentication
    ↓
Cloud Firestore
Firebase Storage
```

### After (REST API 서버)
```
Flutter App
    ↓ (Dio HTTP Client)
REST API Server
    ↓ (Database Service)
Database (Firebase/Postgres/MySQL/etc.)
```

## 주요 변경 사항

### 1. 인증 방식 변경
**Before: Firebase Authentication**
```dart
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdToken();
```

**After: JWT Token 기반**
```dart
final apiService = ApiService();
// Login
final response = await apiService.post('/auth/login', data: {
  'email': email,
  'password': password,
});
final token = response.data['accessToken'];
// Token은 ApiService에서 자동으로 관리됨 (secure storage)
```

### 2. 데이터 접근 방식 변경
**Before: Firestore 직접 쿼리**
```dart
final snapshot = await FirebaseFirestore.instance
    .collection('investment_portfolios')
    .where('userId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .get();

final portfolios = snapshot.docs
    .map((doc) => InvestmentPortfolio.fromDocument(doc))
    .toList();
```

**After: REST API 호출**
```dart
final apiService = ApiService();
final response = await apiService.get('/portfolios', queryParameters: {
  'userId': userId,
  'sortBy': 'recent',
  'limit': 20,
});

final portfolios = (response.data['portfolios'] as List)
    .map((json) => InvestmentPortfolio.fromMap(json))
    .toList();
```

### 3. 실시간 데이터 (Streams) 변경
**Before: Firestore Streams**
```dart
Stream<List<InvestmentPortfolio>> getUserPortfolios(String userId) {
  return _firestore
      .collection('investment_portfolios')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => InvestmentPortfolio.fromDocument(doc))
          .toList());
}
```

**After: Polling 또는 WebSocket**

**Option 1: Polling (간단)**
```dart
Stream<List<InvestmentPortfolio>> getUserPortfolios(String userId) {
  return Stream.periodic(Duration(seconds: 5)).asyncMap((_) async {
    final response = await _api.get('/portfolios', queryParameters: {
      'userId': userId,
    });

    return (response.data['portfolios'] as List)
        .map((json) => InvestmentPortfolio.fromMap(json))
        .toList();
  });
}
```

**Option 2: WebSocket (실시간)**
```dart
// WebSocket for real-time updates
final socket = await WebSocket.connect('wss://api.server.com/ws/portfolios');

socket.listen((data) {
  final update = jsonDecode(data);
  // Handle portfolio updates
});
```

### 4. 트랜잭션 처리
**Before: Firestore Transactions**
```dart
await FirebaseFirestore.instance.runTransaction((transaction) async {
  final postRef = _firestore.collection('posts').doc(postId);
  final postSnapshot = await transaction.get(postRef);

  if (postSnapshot.exists) {
    transaction.update(postRef, {
      'likes': FieldValue.increment(1),
    });
  }
});
```

**After: API 서버에서 처리**
```dart
// 클라이언트는 단순히 API 호출
await _api.post('/posts/$postId/like');

// 서버에서 트랜잭션 처리:
// - Database transaction
// - Atomic operations
// - Concurrency control
```

### 5. 파일 업로드
**Before: Firebase Storage**
```dart
final ref = FirebaseStorage.instance
    .ref()
    .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

final uploadTask = ref.putFile(file);
final snapshot = await uploadTask;
final url = await snapshot.ref.getDownloadURL();
```

**After: REST API Multipart Upload**
```dart
final apiService = ApiService();
final url = await apiService.uploadFile(
  '/upload',
  filePath: file.path,
  fieldName: 'file',
  data: {
    'type': 'image',
    'purpose': 'post',
  },
);
```

## 서비스 마이그레이션 단계

### Step 1: API Service 초기화
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Service
  final apiService = ApiService();
  apiService.initialize();

  runApp(MyApp());
}
```

### Step 2: 기존 서비스를 REST 버전으로 교체

**Example: InvestmentService**

**Before:**
```dart
import 'package:sns_app/services/investment_service.dart';

final service = InvestmentService();
final portfolios = await service.getUserPortfolios(userId);
```

**After:**
```dart
import 'package:sns_app/services/investment_service_rest.dart';

final service = InvestmentServiceRest();
final portfolios = await service.getUserPortfolios(userId);
```

### Step 3: Model 업데이트
모든 모델에 `fromMap()` 메서드가 있는지 확인:

```dart
class InvestmentPortfolio {
  // ...fields

  // Firestore에서 사용
  factory InvestmentPortfolio.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvestmentPortfolio(
      portfolioId: doc.id,
      // ...parse fields
    );
  }

  // REST API에서 사용
  factory InvestmentPortfolio.fromMap(Map<String, dynamic> map) {
    return InvestmentPortfolio(
      portfolioId: map['portfolioId'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      // ...parse fields
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'portfolioId': portfolioId,
      'userId': userId,
      'name': name,
      // ...all fields
    };
  }
}
```

### Step 4: Provider/Riverpod 업데이트
```dart
// Before
final portfolioProvider = StreamProvider.family<InvestmentPortfolio?, String>(
  (ref, portfolioId) {
    final service = InvestmentService();
    return service.getPortfolioStream(portfolioId);
  },
);

// After (with polling)
final portfolioProvider = StreamProvider.family<InvestmentPortfolio?, String>(
  (ref, portfolioId) {
    final service = InvestmentServiceRest();
    return Stream.periodic(Duration(seconds: 5)).asyncMap((_) async {
      return await service.getPortfolio(portfolioId);
    });
  },
);

// Or use FutureProvider for one-time fetches
final portfolioProvider = FutureProvider.family<InvestmentPortfolio?, String>(
  (ref, portfolioId) async {
    final service = InvestmentServiceRest();
    return await service.getPortfolio(portfolioId);
  },
);
```

## 마이그레이션할 서비스 목록

### 완료된 서비스
- [x] `api_service.dart` - HTTP client with JWT auth
- [x] `investment_service_rest.dart` - REST version created

### 마이그레이션 필요한 서비스
- [ ] `post_service.dart`
- [ ] `user_service.dart`
- [ ] `follow_service.dart`
- [ ] `comment_service.dart`
- [ ] `bookmark_service.dart`
- [ ] `social_trading_service.dart`
- [ ] `portfolio_analytics_service.dart`
- [ ] `price_alert_service.dart`
- [ ] `notification_service.dart`
- [ ] `message_service.dart`

## 실시간 기능 처리

### 1. 가격 업데이트 (WebSocket)
```dart
class RealtimePriceServiceRest {
  WebSocketChannel? _channel;

  Future<void> connect() async {
    final token = await _storage.read(key: 'auth_token');
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://your-api-server.com/ws/prices?token=$token'),
    );
  }

  Stream<PriceUpdate> subscribeToAsset(String symbol, AssetType type) {
    // Subscribe to asset
    _channel!.sink.add(jsonEncode({
      'action': 'subscribe',
      'assets': [
        {'symbol': symbol, 'type': type.toString().split('.').last}
      ],
    }));

    // Listen for updates
    return _channel!.stream
        .map((data) => jsonDecode(data))
        .where((json) => json['type'] == 'price_update')
        .map((json) => PriceUpdate.fromMap(json['data']));
  }
}
```

### 2. 알림 (Server-Sent Events 또는 WebSocket)
```dart
// Option 1: Polling
Stream<List<Notification>> getNotifications() {
  return Stream.periodic(Duration(seconds: 10)).asyncMap((_) async {
    final response = await _api.get('/notifications', queryParameters: {
      'unreadOnly': true,
    });

    return (response.data['notifications'] as List)
        .map((json) => Notification.fromMap(json))
        .toList();
  });
}

// Option 2: WebSocket
Stream<Notification> getNotificationStream() {
  return _channel!.stream
      .map((data) => jsonDecode(data))
      .where((json) => json['type'] == 'notification')
      .map((json) => Notification.fromMap(json['data']));
}
```

### 3. 메시지 (WebSocket)
```dart
class MessageServiceRest {
  WebSocketChannel? _channel;

  Stream<Message> getMessageStream(String conversationId) {
    return _channel!.stream
        .map((data) => jsonDecode(data))
        .where((json) =>
            json['type'] == 'new_message' &&
            json['conversationId'] == conversationId)
        .map((json) => Message.fromMap(json['data']));
  }

  Future<void> sendMessage(String conversationId, String content) async {
    await _api.post('/messages/conversations/$conversationId', data: {
      'content': content,
      'type': 'text',
    });
  }
}
```

## 에러 처리

### Before: Firebase Exceptions
```dart
try {
  // Firestore operation
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    // Handle permission error
  }
}
```

### After: DioException + HTTP Status Codes
```dart
try {
  // API call
} on DioException catch (e) {
  if (e.response?.statusCode == 403) {
    // Handle permission error
  }
}

// ErrorHandler already updated to handle DioException
ErrorHandler.showErrorSnackBar(context, error);
```

## 테스트 전략

### 1. 단위 테스트
```dart
// Mock ApiService for testing
class MockApiService extends Mock implements ApiService {}

void main() {
  test('getUserPortfolios returns portfolios', () async {
    final mockApi = MockApiService();
    final service = InvestmentServiceRest();

    when(mockApi.get('/portfolios', queryParameters: anyNamed('queryParameters')))
        .thenAnswer((_) async => Response(
          data: {
            'portfolios': [
              {'portfolioId': '1', 'name': 'Test Portfolio'}
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/portfolios'),
        ));

    final portfolios = await service.getUserPortfolios('user123');
    expect(portfolios.length, 1);
  });
}
```

### 2. 통합 테스트
```dart
// Test with real API (staging environment)
void main() {
  testWidgets('Portfolio screen loads data', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Verify UI shows portfolio data from API
    expect(find.text('My Portfolio'), findsOneWidget);
  });
}
```

## 성능 최적화

### 1. 캐싱
```dart
class CachedApiService {
  final ApiService _api = ApiService();
  final Map<String, CacheEntry> _cache = {};

  Future<Response> get(String path, {Duration cacheDuration = const Duration(minutes: 5)}) async {
    final cacheKey = path;

    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < cacheDuration) {
        return entry.response;
      }
    }

    final response = await _api.get(path);
    _cache[cacheKey] = CacheEntry(response, DateTime.now());

    return response;
  }
}
```

### 2. Request Batching
```dart
// Batch multiple requests
Future<void> loadDashboardData() async {
  final results = await Future.wait([
    _api.get('/portfolios'),
    _api.get('/investment-posts'),
    _api.get('/notifications'),
  ]);

  // Process results
}
```

### 3. Pagination
```dart
class PaginatedList<T> {
  final List<T> items;
  final int offset;
  final bool hasMore;

  Future<void> loadMore() async {
    if (!hasMore) return;

    final response = await _api.get('/portfolios', queryParameters: {
      'limit': 20,
      'offset': offset + items.length,
    });

    // Add new items
  }
}
```

## 보안 고려사항

### 1. Token 저장
```dart
// ApiService already uses flutter_secure_storage
final storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
```

### 2. HTTPS Only
```dart
// ApiService BaseOptions
BaseOptions(
  baseUrl: 'https://your-api-server.com/api/v1', // HTTPS only
  validateStatus: (status) => status! < 500,
)
```

### 3. Certificate Pinning (선택사항)
```dart
// For high-security apps
final dio = Dio();
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
  (client) {
    client.badCertificateCallback = (cert, host, port) {
      // Verify certificate
      return cert.sha1 == expectedSha1;
    };
    return client;
  };
```

## 롤백 계획

마이그레이션 중 문제가 발생하면:

### 1. Feature Flag 사용
```dart
class FeatureFlags {
  static bool useRestApi = false; // Toggle this
}

// In code
final service = FeatureFlags.useRestApi
    ? InvestmentServiceRest()
    : InvestmentService();
```

### 2. Gradual Migration
- Phase 1: 읽기 전용 API부터 시작 (GET)
- Phase 2: 쓰기 API 추가 (POST, PUT, DELETE)
- Phase 3: 실시간 기능 (WebSocket)
- Phase 4: Firebase 완전 제거

## 체크리스트

- [ ] API 서버 구현 완료
- [ ] API_ENDPOINTS.md 문서 확인
- [ ] ApiService 초기화
- [ ] 모든 모델에 fromMap/toMap 구현
- [ ] 서비스별 REST 버전 구현
- [ ] WebSocket 연결 구현
- [ ] 에러 처리 업데이트
- [ ] Provider/Riverpod 업데이트
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 실행
- [ ] 성능 테스트
- [ ] 보안 검토
- [ ] 프로덕션 배포

## 참고 자료

- [API_ENDPOINTS.md](./API_ENDPOINTS.md) - REST API 엔드포인트 문서
- [lib/services/api_service.dart](./lib/services/api_service.dart) - HTTP client 구현
- [lib/services/investment_service_rest.dart](./lib/services/investment_service_rest.dart) - REST API 서비스 예제
- [lib/core/utils/error_handler.dart](./lib/core/utils/error_handler.dart) - Dio 에러 처리

## 지원

문제가 발생하면:
1. API 서버 로그 확인
2. Flutter DevTools에서 네트워크 요청 확인
3. DioException 상세 정보 확인
4. API_ENDPOINTS.md와 요청 형식 비교
