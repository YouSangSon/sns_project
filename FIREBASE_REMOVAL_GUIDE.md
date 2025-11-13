# Firebase 완전 제거 가이드

이 문서는 Firebase 의존성을 완전히 제거하고 대안 솔루션으로 전환하는 단계별 가이드입니다.

## Firebase 사용 현황 분석

현재 프로젝트에서 사용 중인 Firebase 서비스:

| Firebase 서비스 | 현재 용도 | 대안 솔루션 | 마이그레이션 난이도 |
|---------------|---------|-----------|-----------------|
| **Firebase Auth** | 사용자 인증 | JWT + REST API | ⭐⭐ (중간) |
| **Cloud Firestore** | 데이터베이스 | PostgreSQL/MySQL + REST API | ⭐⭐⭐ (높음) |
| **Firebase Storage** | 파일 저장 | AWS S3 / Cloudinary | ⭐⭐ (중간) |
| **Firebase Messaging** | 푸시 알림 | OneSignal | ⭐ (쉬움) |
| **Firebase Core** | SDK 기반 | 제거 | ⭐ (쉬움) |

## 단계별 마이그레이션 계획

### Phase 1: 푸시 알림 (Firebase Messaging → OneSignal)

**이미 완료됨 ✅**
- `lib/services/notification_service_onesignal.dart` 생성
- `onesignal_flutter` 패키지 추가
- OneSignal 통합 가이드 작성

**다음 단계:**
```bash
# 1. Firebase Messaging 제거
flutter pub remove firebase_messaging

# 2. pubspec.yaml에서 확인
# firebase_messaging: ^14.7.9  <- 이 줄 삭제됨
```

### Phase 2: 인증 시스템 (Firebase Auth → JWT)

#### 2.1 백엔드 JWT 인증 구현

**필요한 작업:**

1. **회원가입 API** (`POST /auth/register`)
```javascript
// Backend: routes/auth.js
router.post('/register', async (req, res) => {
  const { email, password, username, fullName } = req.body;

  // 1. 비밀번호 해시
  const hashedPassword = await bcrypt.hash(password, 10);

  // 2. 사용자 생성
  const user = await db.query(
    'INSERT INTO users (email, password, username, full_name) VALUES ($1, $2, $3, $4) RETURNING user_id',
    [email, hashedPassword, username, fullName]
  );

  // 3. JWT 토큰 생성
  const accessToken = jwt.sign(
    { userId: user.user_id, email },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );

  const refreshToken = jwt.sign(
    { userId: user.user_id },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: '7d' }
  );

  res.status(201).json({
    userId: user.user_id,
    accessToken,
    refreshToken,
    expiresIn: 3600
  });
});
```

2. **로그인 API** (`POST /auth/login`)
```javascript
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  // 1. 사용자 조회
  const user = await db.query(
    'SELECT * FROM users WHERE email = $1',
    [email]
  );

  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  // 2. 비밀번호 검증
  const validPassword = await bcrypt.compare(password, user.password);

  if (!validPassword) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  // 3. JWT 토큰 생성
  const accessToken = jwt.sign(
    { userId: user.user_id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );

  const refreshToken = jwt.sign(
    { userId: user.user_id },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: '7d' }
  );

  res.json({
    userId: user.user_id,
    accessToken,
    refreshToken,
    expiresIn: 3600
  });
});
```

3. **토큰 갱신 API** (`POST /auth/refresh`)
```javascript
router.post('/refresh', async (req, res) => {
  const { refreshToken } = req.body;

  try {
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

    const accessToken = jwt.sign(
      { userId: decoded.userId },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    const newRefreshToken = jwt.sign(
      { userId: decoded.userId },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      accessToken,
      refreshToken: newRefreshToken,
      expiresIn: 3600
    });
  } catch (error) {
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});
```

#### 2.2 Flutter 앱 인증 서비스 업데이트

```dart
// lib/services/auth_service_rest.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthServiceRest {
  final ApiService _api = ApiService();
  final _storage = const FlutterSecureStorage();

  /// 회원가입
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      final response = await _api.post('/auth/register', data: {
        'email': email,
        'password': password,
        'username': username,
        'fullName': fullName,
      });

      final userId = response.data['userId'];
      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];

      // 토큰 저장
      await _storage.write(key: 'auth_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      await _storage.write(key: 'user_id', value: userId);

      return AuthResult(success: true, userId: userId);
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// 로그인
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final userId = response.data['userId'];
      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];

      // 토큰 저장
      await _storage.write(key: 'auth_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      await _storage.write(key: 'user_id', value: userId);

      return AuthResult(success: true, userId: userId);
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// 현재 사용자 ID 가져오기
  Future<String?> getCurrentUserId() async {
    return await _storage.read(key: 'user_id');
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
}

class AuthResult {
  final bool success;
  final String? userId;
  final String? error;

  AuthResult({required this.success, this.userId, this.error});
}
```

#### 2.3 Firebase Auth 제거

```bash
# pubspec.yaml에서 제거
flutter pub remove firebase_auth

# 기존 FirebaseAuth 사용 코드를 AuthServiceRest로 교체
```

**Before (Firebase Auth):**
```dart
final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

**After (JWT):**
```dart
final authService = AuthServiceRest();
final result = await authService.login(
  email: email,
  password: password,
);
```

### Phase 3: 데이터베이스 (Firestore → PostgreSQL/MySQL)

#### 3.1 데이터베이스 스키마 설계

**PostgreSQL 예제:**

```sql
-- Users table
CREATE TABLE users (
  user_id VARCHAR(255) PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  full_name VARCHAR(100),
  bio TEXT,
  profile_image_url TEXT,
  follower_count INT DEFAULT 0,
  following_count INT DEFAULT 0,
  post_count INT DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts table
CREATE TABLE posts (
  post_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  caption TEXT,
  image_urls TEXT[],
  location VARCHAR(255),
  like_count INT DEFAULT 0,
  comment_count INT DEFAULT 0,
  bookmark_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Investment Portfolios table
CREATE TABLE investment_portfolios (
  portfolio_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  total_value DECIMAL(20, 2) DEFAULT 0,
  total_cost DECIMAL(20, 2) DEFAULT 0,
  total_return DECIMAL(20, 2) DEFAULT 0,
  return_rate DECIMAL(10, 2) DEFAULT 0,
  is_public BOOLEAN DEFAULT false,
  follower_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Asset Holdings table
CREATE TABLE asset_holdings (
  holding_id VARCHAR(255) PRIMARY KEY,
  portfolio_id VARCHAR(255) REFERENCES investment_portfolios(portfolio_id) ON DELETE CASCADE,
  asset_type VARCHAR(50) NOT NULL,
  symbol VARCHAR(50) NOT NULL,
  asset_name VARCHAR(255) NOT NULL,
  quantity DECIMAL(20, 8) NOT NULL,
  average_price DECIMAL(20, 2) NOT NULL,
  current_price DECIMAL(20, 2) NOT NULL,
  total_value DECIMAL(20, 2) NOT NULL,
  total_cost DECIMAL(20, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'KRW',
  purchase_date TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trade History table
CREATE TABLE trade_history (
  trade_id VARCHAR(255) PRIMARY KEY,
  portfolio_id VARCHAR(255) REFERENCES investment_portfolios(portfolio_id) ON DELETE CASCADE,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  asset_symbol VARCHAR(50) NOT NULL,
  asset_name VARCHAR(255) NOT NULL,
  asset_type VARCHAR(50) NOT NULL,
  trade_type VARCHAR(10) NOT NULL, -- 'buy' or 'sell'
  quantity DECIMAL(20, 8) NOT NULL,
  price DECIMAL(20, 2) NOT NULL,
  total_amount DECIMAL(20, 2) NOT NULL,
  fee DECIMAL(20, 2) DEFAULT 0,
  currency VARCHAR(10) DEFAULT 'KRW',
  notes TEXT,
  trade_date TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bookmarks table
CREATE TABLE bookmarks (
  bookmark_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  content_id VARCHAR(255) NOT NULL,
  content_type VARCHAR(50) NOT NULL, -- 'post', 'investmentPost', 'reel'
  content_preview TEXT,
  content_image_url TEXT,
  author_username VARCHAR(50),
  author_photo_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Watchlist table
CREATE TABLE watchlists (
  watchlist_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  asset_symbol VARCHAR(50) NOT NULL,
  asset_name VARCHAR(255) NOT NULL,
  asset_type VARCHAR(50) NOT NULL,
  added_price DECIMAL(20, 2) NOT NULL,
  current_price DECIMAL(20, 2),
  alert_enabled BOOLEAN DEFAULT false,
  alert_condition VARCHAR(20), -- 'above', 'below', 'change'
  target_price DECIMAL(20, 2),
  alert_triggered BOOLEAN DEFAULT false,
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications table
CREATE TABLE notifications (
  notification_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Followed Portfolios table
CREATE TABLE followed_portfolios (
  follow_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  portfolio_id VARCHAR(255) REFERENCES investment_portfolios(portfolio_id) ON DELETE CASCADE,
  followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, portfolio_id)
);

-- Add indexes for performance
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_portfolios_user_id ON investment_portfolios(user_id);
CREATE INDEX idx_portfolios_return_rate ON investment_portfolios(return_rate DESC);
CREATE INDEX idx_holdings_portfolio_id ON asset_holdings(portfolio_id);
CREATE INDEX idx_trades_portfolio_id ON trade_history(portfolio_id);
CREATE INDEX idx_trades_user_id ON trade_history(user_id);
CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX idx_watchlists_user_id ON watchlists(user_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_followed_portfolios_user_id ON followed_portfolios(user_id);
```

#### 3.2 Firestore → SQL 데이터 마이그레이션 스크립트

```javascript
// Backend: scripts/migrateFirestoreToPostgres.js
const admin = require('firebase-admin');
const { Pool } = require('pg');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert('./serviceAccountKey.json')
});

const firestore = admin.firestore();

// Initialize PostgreSQL
const pool = new Pool({
  host: 'localhost',
  database: 'sns_app',
  user: 'postgres',
  password: 'password',
  port: 5432,
});

async function migrateUsers() {
  console.log('Migrating users...');

  const usersSnapshot = await firestore.collection('users').get();

  for (const doc of usersSnapshot.docs) {
    const data = doc.data();

    await pool.query(
      `INSERT INTO users (user_id, email, username, full_name, bio, profile_image_url,
       follower_count, following_count, post_count, is_verified, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       ON CONFLICT (user_id) DO NOTHING`,
      [
        doc.id,
        data.email,
        data.username,
        data.fullName,
        data.bio,
        data.profileImageUrl,
        data.followerCount || 0,
        data.followingCount || 0,
        data.postCount || 0,
        data.isVerified || false,
        data.createdAt?.toDate() || new Date(),
      ]
    );
  }

  console.log(`Migrated ${usersSnapshot.docs.length} users`);
}

async function migratePosts() {
  console.log('Migrating posts...');

  const postsSnapshot = await firestore.collection('posts').get();

  for (const doc of postsSnapshot.docs) {
    const data = doc.data();

    await pool.query(
      `INSERT INTO posts (post_id, user_id, caption, image_urls, location,
       like_count, comment_count, bookmark_count, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       ON CONFLICT (post_id) DO NOTHING`,
      [
        doc.id,
        data.userId,
        data.caption,
        data.imageUrls,
        data.location,
        data.likeCount || 0,
        data.commentCount || 0,
        data.bookmarkCount || 0,
        data.createdAt?.toDate() || new Date(),
      ]
    );
  }

  console.log(`Migrated ${postsSnapshot.docs.length} posts`);
}

async function migratePortfolios() {
  console.log('Migrating portfolios...');

  const portfoliosSnapshot = await firestore.collection('investment_portfolios').get();

  for (const doc of portfoliosSnapshot.docs) {
    const data = doc.data();

    await pool.query(
      `INSERT INTO investment_portfolios (portfolio_id, user_id, name, description,
       total_value, total_cost, total_return, return_rate, is_public, follower_count,
       created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
       ON CONFLICT (portfolio_id) DO NOTHING`,
      [
        doc.id,
        data.userId,
        data.name,
        data.description,
        data.totalValue || 0,
        data.totalCost || 0,
        data.totalReturn || 0,
        data.returnRate || 0,
        data.isPublic || false,
        data.followerCount || 0,
        data.createdAt?.toDate() || new Date(),
        data.updatedAt?.toDate() || new Date(),
      ]
    );
  }

  console.log(`Migrated ${portfoliosSnapshot.docs.length} portfolios`);
}

async function migrate() {
  try {
    await migrateUsers();
    await migratePosts();
    await migratePortfolios();
    // ... migrate other collections

    console.log('Migration completed successfully!');
  } catch (error) {
    console.error('Migration error:', error);
  } finally {
    await pool.end();
    process.exit(0);
  }
}

migrate();
```

#### 3.3 Firestore 제거

```bash
# pubspec.yaml에서 제거
flutter pub remove cloud_firestore

# 모든 InvestmentService, PostService 등을 REST 버전으로 교체
```

### Phase 4: 파일 저장소 (Firebase Storage → AWS S3 / Cloudinary)

#### 4.1 Option A: AWS S3

**Backend 설정:**
```javascript
// Backend: services/storageService.js
const AWS = require('aws-sdk');
const multer = require('multer');
const multerS3 = require('multer-s3');

const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION,
});

const upload = multer({
  storage: multerS3({
    s3: s3,
    bucket: process.env.S3_BUCKET_NAME,
    acl: 'public-read',
    metadata: (req, file, cb) => {
      cb(null, { fieldName: file.fieldname });
    },
    key: (req, file, cb) => {
      const fileName = `${Date.now()}_${file.originalname}`;
      cb(null, fileName);
    },
  }),
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
});

module.exports = upload;
```

**Upload Endpoint:**
```javascript
// Backend: routes/upload.js
router.post('/upload', upload.single('file'), (req, res) => {
  res.json({
    url: req.file.location,
    fileId: req.file.key,
    size: req.file.size,
    mimeType: req.file.mimetype,
  });
});
```

#### 4.2 Option B: Cloudinary (추천)

**Backend 설정:**
```javascript
// Backend: services/cloudinaryService.js
const cloudinary = require('cloudinary').v2;
const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'sns_app',
    allowed_formats: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov'],
    transformation: [
      { width: 1080, height: 1080, crop: 'limit' }
    ],
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 50 * 1024 * 1024 },
});

module.exports = upload;
```

**장점:**
- 자동 이미지 최적화
- CDN 내장
- 동영상 트랜스코딩
- 무료 tier: 25GB 저장, 25GB 대역폭/월

#### 4.3 Firebase Storage 제거

```bash
flutter pub remove firebase_storage

# 기존 Storage 업로드 코드를 REST API로 교체
```

**Before (Firebase Storage):**
```dart
final ref = FirebaseStorage.instance.ref().child('images/$fileName');
await ref.putFile(file);
final url = await ref.getDownloadURL();
```

**After (REST API):**
```dart
final apiService = ApiService();
final url = await apiService.uploadFile(
  '/upload',
  filePath: file.path,
  fieldName: 'file',
);
```

### Phase 5: Firebase Core 제거

모든 Firebase 서비스를 제거한 후:

```bash
# Firebase Core 제거
flutter pub remove firebase_core

# pubspec.yaml 확인
# 모든 firebase_* 패키지가 제거되었는지 확인
```

**main.dart 수정:**

**Before:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 제거
  runApp(MyApp());
}
```

**After:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Service
  ApiService().initialize();

  // Initialize OneSignal
  await NotificationServiceOneSignal().initialize();

  runApp(MyApp());
}
```

## 최종 체크리스트

- [ ] **푸시 알림**: Firebase Messaging → OneSignal
  - [ ] OneSignal 계정 생성
  - [ ] iOS APNs 설정
  - [ ] Android 설정
  - [ ] 백엔드 OneSignal API 통합
  - [ ] `firebase_messaging` 제거

- [ ] **인증**: Firebase Auth → JWT
  - [ ] 백엔드 JWT 인증 구현
  - [ ] 회원가입/로그인 API
  - [ ] 토큰 갱신 로직
  - [ ] Flutter AuthServiceRest 구현
  - [ ] `firebase_auth` 제거

- [ ] **데이터베이스**: Firestore → PostgreSQL/MySQL
  - [ ] 데이터베이스 스키마 설계
  - [ ] REST API 엔드포인트 구현
  - [ ] 데이터 마이그레이션 스크립트 실행
  - [ ] Flutter 서비스 REST 버전으로 교체
  - [ ] `cloud_firestore` 제거

- [ ] **파일 저장소**: Firebase Storage → S3/Cloudinary
  - [ ] S3 또는 Cloudinary 계정 설정
  - [ ] 파일 업로드 API 구현
  - [ ] Flutter 업로드 로직 변경
  - [ ] `firebase_storage` 제거

- [ ] **Core**: Firebase Core 제거
  - [ ] 모든 Firebase 서비스 제거 확인
  - [ ] `firebase_core` 제거
  - [ ] main.dart에서 Firebase 초기화 제거

- [ ] **테스트**: 모든 기능 동작 확인
  - [ ] 회원가입/로그인
  - [ ] 게시물 CRUD
  - [ ] 포트폴리오 관리
  - [ ] 파일 업로드
  - [ ] 푸시 알림
  - [ ] 실시간 기능

## 비용 비교

### Firebase (무료 Tier 제한)
- Firestore: 1GB 저장, 읽기 50k/일, 쓰기 20k/일
- Storage: 5GB 저장, 1GB 다운로드/일
- Auth: 무제한
- Messaging: 무제한
- **초과 시**: 종량제

### 대안 솔루션 (무료 Tier)
- PostgreSQL (Supabase): 500MB 저장
- S3 (AWS Free Tier): 5GB 저장, 20k GET
- Cloudinary: 25GB 저장, 25GB 대역폭
- OneSignal: 10k 사용자
- **초과 시**: 예측 가능한 가격

## 롤백 계획

문제 발생 시 Firebase로 롤백:

1. `pubspec.yaml`에 Firebase 패키지 재추가
2. `main.dart`에서 Firebase 초기화 복원
3. 기존 Firebase 서비스 코드 재활성화
4. Git으로 이전 커밋 복원

```bash
# Firebase 패키지 재설치
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage firebase_messaging

# 이전 커밋으로 복원
git revert HEAD
```

## 참고 자료

- [JWT Authentication Best Practices](https://jwt.io/introduction)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [OneSignal Documentation](https://documentation.onesignal.com/)
- [MIGRATION_TO_REST.md](./MIGRATION_TO_REST.md)
- [NOTIFICATION_ARCHITECTURE.md](./NOTIFICATION_ARCHITECTURE.md)
