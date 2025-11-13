# Firebase 제거 완료 ✅

Firebase가 프로젝트에서 완전히 제거되었습니다!

## 변경 사항 요약

### ❌ 제거된 Firebase 패키지
```yaml
# pubspec.yaml에서 제거됨
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
cloud_firestore: ^4.13.6
firebase_storage: ^11.5.6
firebase_messaging: ^14.7.9
```

### ✅ 대체 솔루션

| Firebase 서비스 | 대체 솔루션 | 파일 |
|----------------|-----------|------|
| **Firebase Auth** | JWT + REST API | `lib/services/auth_service_rest.dart` |
| **Cloud Firestore** | PostgreSQL/MySQL + REST API | `lib/services/investment_service_rest.dart` |
| **Firebase Storage** | AWS S3 / Cloudinary | `lib/services/storage_service_rest.dart` |
| **Firebase Messaging** | OneSignal | `lib/services/notification_service_onesignal.dart` |
| **Firebase Core** | 제거됨 | - |

## 새로운 서비스 사용법

### 1. 인증 (AuthServiceRest)

```dart
import 'package:sns_app/services/auth_service_rest.dart';

final authService = AuthServiceRest();

// 회원가입
final result = await authService.register(
  email: 'user@example.com',
  password: 'password123',
  username: 'username',
  fullName: 'John Doe',
);

if (result.success) {
  print('Registration successful: ${result.userId}');
} else {
  print('Error: ${result.error}');
}

// 로그인
final loginResult = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

// 로그인 상태 확인
final isLoggedIn = await authService.isLoggedIn();

// 현재 사용자 ID
final userId = await authService.getCurrentUserId();

// 로그아웃
await authService.logout();
```

### 2. 데이터베이스 (InvestmentServiceRest)

```dart
import 'package:sns_app/services/investment_service_rest.dart';

final investmentService = InvestmentServiceRest();

// 포트폴리오 생성
final portfolioId = await investmentService.createPortfolio(portfolio);

// 포트폴리오 목록 조회
final portfolios = await investmentService.getUserPortfolios(userId);

// 포트폴리오 상세 조회
final portfolio = await investmentService.getPortfolio(portfolioId);

// 자산 보유 추가
final holdingId = await investmentService.addHolding(holding);

// 거래 기록 추가
final tradeId = await investmentService.addTrade(trade);
```

### 3. 파일 저장소 (StorageServiceRest)

```dart
import 'package:sns_app/services/storage_service_rest.dart';

final storageService = StorageServiceRest();

// 이미지 업로드
final imageUrl = await storageService.uploadImage(
  imageFile: imageFile,
  folder: StorageFolder.profileImages,
  quality: ImageQuality.high,
  onProgress: (sent, total) {
    print('Progress: ${(sent / total * 100).toStringAsFixed(0)}%');
  },
);

// 여러 이미지 업로드
final imageUrls = await storageService.uploadMultipleImages(
  imageFiles: [image1, image2, image3],
  folder: StorageFolder.postImages,
);

// 동영상 업로드
final videoUrl = await storageService.uploadVideo(
  videoFile: videoFile,
  folder: StorageFolder.postVideos,
  quality: VideoQuality.high,
);

// 파일 삭제
await storageService.deleteFile(fileUrl: imageUrl);
```

### 4. 푸시 알림 (NotificationServiceOneSignal)

```dart
import 'package:sns_app/services/notification_service_onesignal.dart';

final notificationService = NotificationServiceOneSignal();

// 초기화 (main.dart에서 이미 완료)
await notificationService.initialize();

// 로그인 후 사용자 설정
await notificationService.setUserId(user.userId);
await notificationService.registerDeviceToken(user.userId);

// 태그 설정 (세그먼트 타겟팅)
await notificationService.setTags({
  'language': 'ko',
  'interests': 'stocks,crypto',
  'subscription': 'premium',
});

// 로그아웃 시
await notificationService.removeUserId();
```

## 수정된 파일

### 핵심 파일
1. **lib/main.dart**
   - Firebase 초기화 제거
   - API Service 초기화 추가
   - OneSignal 초기화 추가

2. **lib/core/utils/error_handler.dart**
   - Firebase Exception 제거
   - Dio Exception만 처리

3. **pubspec.yaml**
   - 모든 Firebase 패키지 제거
   - OneSignal 추가 (onesignal_flutter: ^5.0.4)

### 새로 생성된 서비스 파일

1. **lib/services/api_service.dart** (267 lines)
   - Dio HTTP 클라이언트
   - JWT 토큰 자동 관리
   - 인터셉터 (Request/Response/Error)
   - 파일 업로드/다운로드

2. **lib/services/auth_service_rest.dart** (424 lines)
   - 회원가입/로그인
   - 비밀번호 변경/재설정
   - 이메일 인증
   - 계정 삭제

3. **lib/services/investment_service_rest.dart** (737 lines)
   - 포트폴리오 관리
   - 자산 보유 관리
   - 거래 기록
   - 투자 게시물
   - 워치리스트
   - 리더보드

4. **lib/services/storage_service_rest.dart** (384 lines)
   - 파일 업로드 (이미지/동영상)
   - 자동 최적화
   - 썸네일 생성
   - 파일 삭제
   - 다운로드

5. **lib/services/notification_service_onesignal.dart** (330 lines)
   - OneSignal 푸시 알림
   - 디바이스 토큰 관리
   - 알림 네비게이션
   - 세그먼트 타겟팅

## 레거시 파일 (사용 안 함)

다음 파일들은 Firebase를 사용하므로 **더 이상 사용하지 마세요**:

- ❌ `lib/services/auth_service.dart` (Firebase Auth) → ✅ `auth_service_rest.dart` 사용
- ❌ `lib/services/storage_service.dart` (Firebase Storage) → ✅ `storage_service_rest.dart` 사용
- ❌ `lib/services/notification_service.dart` (Firebase Messaging) → ✅ `notification_service_onesignal.dart` 사용
- ❌ `lib/services/investment_service.dart` (Firestore) → ✅ `investment_service_rest.dart` 사용
- ❌ `lib/providers/auth_provider.dart` (Firebase Auth) → 새로운 Provider 필요
- ❌ `lib/providers/auth_provider_riverpod.dart` (Firebase Auth) → 새로운 Provider 필요

## 백엔드 서버 요구사항

이제 백엔드 REST API 서버가 필요합니다:

### 필수 API 엔드포인트

참고: **API_ENDPOINTS.md** 문서를 확인하세요 (100+ 엔드포인트 정의)

**주요 엔드포인트:**
- `POST /auth/register` - 회원가입
- `POST /auth/login` - 로그인
- `POST /auth/refresh` - 토큰 갱신
- `GET /portfolios` - 포트폴리오 목록
- `POST /portfolios` - 포트폴리오 생성
- `POST /upload` - 파일 업로드
- `POST /notifications/send` - 알림 전송
- ... (자세한 내용은 API_ENDPOINTS.md 참조)

### 백엔드 구현 예제

**Node.js + Express + PostgreSQL:**
```javascript
// server.js
const express = require('express');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

const app = express();
const db = new Pool({ /* postgres config */ });

// JWT 인증 미들웨어
const authenticateToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.sendStatus(401);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// 로그인
app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;
  // Verify credentials...
  const accessToken = jwt.sign({ userId, email }, process.env.JWT_SECRET, { expiresIn: '1h' });
  res.json({ userId, accessToken, refreshToken });
});

// 포트폴리오 목록
app.get('/portfolios', authenticateToken, async (req, res) => {
  const portfolios = await db.query('SELECT * FROM investment_portfolios WHERE user_id = $1', [req.user.userId]);
  res.json({ portfolios: portfolios.rows });
});

app.listen(3000, () => console.log('Server running on port 3000'));
```

## 데이터베이스

Firebase Firestore 대신 **PostgreSQL** 또는 **MySQL** 사용:

### PostgreSQL 스키마

참고: **FIREBASE_REMOVAL_GUIDE.md**에 완전한 SQL 스키마 포함

**주요 테이블:**
- `users` - 사용자 정보
- `posts` - 게시물
- `investment_portfolios` - 포트폴리오
- `asset_holdings` - 자산 보유
- `trade_history` - 거래 기록
- `bookmarks` - 북마크
- `watchlists` - 워치리스트
- `notifications` - 알림
- `followed_portfolios` - 팔로우한 포트폴리오

## 다음 단계

### 1. 백엔드 API 서버 구현

**옵션 A: Node.js + Express**
```bash
npm install express jsonwebtoken bcrypt pg cors
```

**옵션 B: Python + Django/FastAPI**
```bash
pip install django djangorestframework pyjwt psycopg2
```

**옵션 C: Go + Gin**
```bash
go get github.com/gin-gonic/gin
go get github.com/golang-jwt/jwt
```

### 2. 데이터베이스 설정

**PostgreSQL 설치 및 스키마 실행:**
```bash
# PostgreSQL 설치 (macOS)
brew install postgresql

# 데이터베이스 생성
createdb sns_app

# 스키마 실행
psql sns_app < schema.sql
```

### 3. OneSignal 설정

1. [OneSignal](https://onesignal.com) 계정 생성
2. 앱 생성 및 App ID 복사
3. `lib/services/notification_service_onesignal.dart`에 App ID 입력
4. iOS APNs 설정
5. Android FCM 설정

자세한 내용: **NOTIFICATION_ARCHITECTURE.md**

### 4. 파일 저장소 설정

**옵션 A: AWS S3**
```bash
npm install aws-sdk multer multer-s3
```

**옵션 B: Cloudinary (추천)**
```bash
npm install cloudinary multer-storage-cloudinary
```

### 5. API Service 설정

`lib/services/api_service.dart`에서 Base URL 수정:

```dart
static const String _baseUrl = 'https://your-api-server.com/api/v1';
```

### 6. OneSignal App ID 설정

`lib/services/notification_service_onesignal.dart`에서:

```dart
static const String _oneSignalAppId = "YOUR_ONESIGNAL_APP_ID";
```

## 관련 문서

- **API_ENDPOINTS.md** - REST API 엔드포인트 전체 문서 (1,100+ lines)
- **MIGRATION_TO_REST.md** - Firebase → REST API 마이그레이션 가이드
- **FIREBASE_REMOVAL_GUIDE.md** - Firebase 제거 단계별 가이드 (700+ lines)
- **NOTIFICATION_ARCHITECTURE.md** - OneSignal 통합 가이드 (650+ lines)

## 문제 해결

### "Could not find firebase_core" 에러
```bash
flutter clean
flutter pub get
```

### API 연결 실패
1. `api_service.dart`에서 Base URL 확인
2. 백엔드 서버가 실행 중인지 확인
3. CORS 설정 확인 (웹의 경우)

### OneSignal 알림이 오지 않음
1. OneSignal App ID 확인
2. iOS APNs 인증서 확인
3. Android 권한 확인
4. 실제 기기에서 테스트 (시뮬레이터 불가)

### JWT 토큰 만료
- ApiService가 자동으로 401 에러 시 토큰 갱신
- 갱신 실패 시 로그인 화면으로 이동

## 요약

✅ **Firebase 완전 제거 완료**
- 모든 Firebase 패키지 제거
- 5개의 새로운 REST API 서비스 생성
- OneSignal 푸시 알림 통합
- 완전한 문서화 (3,000+ lines)

✅ **장점**
- 데이터베이스 자유롭게 선택
- 백엔드 완전 제어
- 예측 가능한 비용
- 벤더 종속성 없음

⚠️ **필요한 작업**
- 백엔드 REST API 서버 구현
- 데이터베이스 설정
- OneSignal 설정
- 파일 저장소 설정

📚 **참고 문서**
- API_ENDPOINTS.md
- MIGRATION_TO_REST.md
- FIREBASE_REMOVAL_GUIDE.md
- NOTIFICATION_ARCHITECTURE.md
