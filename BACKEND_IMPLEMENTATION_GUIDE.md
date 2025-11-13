# Backend Server Implementation Guide

투자 SNS 앱의 완벽한 백엔드 REST API 서버 구현 가이드입니다.

## 목차
1. [아키텍처 개요](#아키텍처-개요)
2. [기술 스택](#기술-스택)
3. [프로젝트 구조](#프로젝트-구조)
4. [데이터베이스 스키마](#데이터베이스-스키마)
5. [API 엔드포인트 상세](#api-엔드포인트-상세)
6. [인증 & 인가](#인증--인가)
7. [Database Service 레이어](#database-service-레이어)
8. [구현 예제](#구현-예제)
9. [배포 가이드](#배포-가이드)

---

## 아키텍처 개요

```
┌─────────────────────┐
│   Flutter App       │
│   (Dio Client)      │
└──────────┬──────────┘
           │ HTTP/HTTPS
           │ JWT Token
           ↓
┌─────────────────────┐
│   REST API Server   │
│   (Express.js)      │
│                     │
│   ┌──────────────┐  │
│   │ Routes       │  │
│   └──────┬───────┘  │
│          │          │
│   ┌──────▼───────┐  │
│   │ Controllers  │  │
│   └──────┬───────┘  │
│          │          │
│   ┌──────▼───────┐  │
│   │ Services     │  │
│   └──────┬───────┘  │
│          │          │
│   ┌──────▼───────┐  │
│   │ DB Service   │  │
│   └──────┬───────┘  │
└──────────┼──────────┘
           │
           ↓
┌─────────────────────┐
│   PostgreSQL DB     │
│   (pgAdmin)         │
└─────────────────────┘

┌─────────────────────┐
│   OneSignal API     │
│   (Push Notif)      │
└─────────────────────┘

┌─────────────────────┐
│   Cloudinary API    │
│   (File Storage)    │
└─────────────────────┘
```

### 레이어 설명

1. **Routes Layer**: HTTP 요청 라우팅
2. **Controllers Layer**: 요청 검증, 응답 포맷팅
3. **Services Layer**: 비즈니스 로직
4. **Database Service Layer**: CRUD 작업

---

## 기술 스택

### Backend Framework
- **Node.js** v18+ (LTS)
- **Express.js** v4.18+ (웹 프레임워크)
- **TypeScript** v5.0+ (타입 안정성)

### Database
- **PostgreSQL** v15+ (주 데이터베이스)
- **Redis** v7.0+ (캐싱, 세션)

### Authentication
- **jsonwebtoken** v9.0+ (JWT)
- **bcrypt** v5.1+ (비밀번호 해싱)

### File Storage
- **Cloudinary** SDK (이미지/동영상)
- **multer** (파일 업로드)

### Push Notifications
- **OneSignal** REST API

### Real-time
- **Socket.IO** v4.6+ (WebSocket)

### Others
- **express-validator** (입력 검증)
- **cors** (CORS 처리)
- **helmet** (보안 헤더)
- **morgan** (로깅)
- **dotenv** (환경 변수)

---

## 프로젝트 구조

```
backend/
├── src/
│   ├── config/
│   │   ├── database.ts          # DB 연결 설정
│   │   ├── cloudinary.ts        # Cloudinary 설정
│   │   ├── onesignal.ts         # OneSignal 설정
│   │   └── redis.ts             # Redis 설정
│   │
│   ├── middleware/
│   │   ├── auth.ts              # JWT 인증 미들웨어
│   │   ├── validation.ts        # 입력 검증
│   │   ├── errorHandler.ts      # 에러 핸들러
│   │   └── rateLimiter.ts       # Rate limiting
│   │
│   ├── routes/
│   │   ├── auth.routes.ts       # 인증 라우트
│   │   ├── users.routes.ts      # 사용자 라우트
│   │   ├── posts.routes.ts      # 게시물 라우트
│   │   ├── portfolios.routes.ts # 포트폴리오 라우트
│   │   ├── trades.routes.ts     # 거래 라우트
│   │   ├── upload.routes.ts     # 파일 업로드 라우트
│   │   └── notifications.routes.ts # 알림 라우트
│   │
│   ├── controllers/
│   │   ├── auth.controller.ts
│   │   ├── users.controller.ts
│   │   ├── posts.controller.ts
│   │   ├── portfolios.controller.ts
│   │   ├── trades.controller.ts
│   │   ├── upload.controller.ts
│   │   └── notifications.controller.ts
│   │
│   ├── services/
│   │   ├── auth.service.ts
│   │   ├── users.service.ts
│   │   ├── posts.service.ts
│   │   ├── portfolios.service.ts
│   │   ├── trades.service.ts
│   │   ├── upload.service.ts
│   │   ├── onesignal.service.ts
│   │   └── cache.service.ts
│   │
│   ├── db/
│   │   ├── db.service.ts        # Database Service 레이어
│   │   ├── queries/
│   │   │   ├── users.queries.ts
│   │   │   ├── posts.queries.ts
│   │   │   ├── portfolios.queries.ts
│   │   │   └── trades.queries.ts
│   │   └── migrations/
│   │       ├── 001_create_users_table.sql
│   │       ├── 002_create_posts_table.sql
│   │       └── ...
│   │
│   ├── types/
│   │   ├── express.d.ts         # Express 타입 확장
│   │   ├── user.types.ts
│   │   ├── post.types.ts
│   │   └── portfolio.types.ts
│   │
│   ├── utils/
│   │   ├── jwt.utils.ts
│   │   ├── password.utils.ts
│   │   ├── validation.utils.ts
│   │   └── response.utils.ts
│   │
│   ├── websocket/
│   │   ├── socket.ts            # Socket.IO 설정
│   │   └── handlers/
│   │       ├── price.handler.ts
│   │       └── notification.handler.ts
│   │
│   ├── app.ts                   # Express 앱 설정
│   └── server.ts                # 서버 시작
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── .env.example                 # 환경 변수 예제
├── .gitignore
├── package.json
├── tsconfig.json
└── README.md
```

---

## 데이터베이스 스키마

### 1. Users Table
```sql
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
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

### 2. Posts Table
```sql
CREATE TABLE posts (
  post_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  caption TEXT,
  image_urls TEXT[],
  location VARCHAR(255),
  like_count INT DEFAULT 0,
  comment_count INT DEFAULT 0,
  bookmark_count INT DEFAULT 0,
  view_count INT DEFAULT 0,
  is_hidden BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_like_count ON posts(like_count DESC);
```

### 3. Post Likes Table
```sql
CREATE TABLE post_likes (
  like_id VARCHAR(255) PRIMARY KEY,
  post_id VARCHAR(255) REFERENCES posts(post_id) ON DELETE CASCADE,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(post_id, user_id)
);

CREATE INDEX idx_post_likes_post_id ON post_likes(post_id);
CREATE INDEX idx_post_likes_user_id ON post_likes(user_id);
```

### 4. Comments Table
```sql
CREATE TABLE comments (
  comment_id VARCHAR(255) PRIMARY KEY,
  post_id VARCHAR(255) REFERENCES posts(post_id) ON DELETE CASCADE,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  parent_comment_id VARCHAR(255) REFERENCES comments(comment_id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  like_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_comment_id);
```

### 5. Follows Table
```sql
CREATE TABLE follows (
  follow_id VARCHAR(255) PRIMARY KEY,
  follower_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  following_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(follower_id, following_id)
);

CREATE INDEX idx_follows_follower_id ON follows(follower_id);
CREATE INDEX idx_follows_following_id ON follows(following_id);
```

### 6. Investment Portfolios Table
```sql
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

CREATE INDEX idx_portfolios_user_id ON investment_portfolios(user_id);
CREATE INDEX idx_portfolios_return_rate ON investment_portfolios(return_rate DESC);
CREATE INDEX idx_portfolios_is_public ON investment_portfolios(is_public);
```

### 7. Asset Holdings Table
```sql
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

CREATE INDEX idx_holdings_portfolio_id ON asset_holdings(portfolio_id);
CREATE INDEX idx_holdings_symbol ON asset_holdings(symbol);
```

### 8. Trade History Table
```sql
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

CREATE INDEX idx_trades_portfolio_id ON trade_history(portfolio_id);
CREATE INDEX idx_trades_user_id ON trade_history(user_id);
CREATE INDEX idx_trades_symbol ON trade_history(asset_symbol);
CREATE INDEX idx_trades_date ON trade_history(trade_date DESC);
```

### 9. Investment Posts Table
```sql
CREATE TABLE investment_posts (
  post_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  portfolio_id VARCHAR(255) REFERENCES investment_portfolios(portfolio_id) ON DELETE SET NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  image_urls TEXT[],
  tags TEXT[],
  related_assets JSONB,
  post_type VARCHAR(50),
  like_count INT DEFAULT 0,
  comment_count INT DEFAULT 0,
  bookmark_count INT DEFAULT 0,
  view_count INT DEFAULT 0,
  bullish_count INT DEFAULT 0,
  bearish_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_investment_posts_user_id ON investment_posts(user_id);
CREATE INDEX idx_investment_posts_portfolio_id ON investment_posts(portfolio_id);
CREATE INDEX idx_investment_posts_created_at ON investment_posts(created_at DESC);
CREATE INDEX idx_investment_posts_tags ON investment_posts USING GIN(tags);
```

### 10. Bookmarks Table
```sql
CREATE TABLE bookmarks (
  bookmark_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  content_id VARCHAR(255) NOT NULL,
  content_type VARCHAR(50) NOT NULL, -- 'post', 'investmentPost', 'reel'
  content_preview TEXT,
  content_image_url TEXT,
  author_username VARCHAR(50),
  author_photo_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, content_id, content_type)
);

CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX idx_bookmarks_content_id ON bookmarks(content_id);
```

### 11. Watchlist Table
```sql
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
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, asset_symbol)
);

CREATE INDEX idx_watchlists_user_id ON watchlists(user_id);
CREATE INDEX idx_watchlists_symbol ON watchlists(asset_symbol);
```

### 12. Notifications Table
```sql
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

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
```

### 13. Followed Portfolios Table
```sql
CREATE TABLE followed_portfolios (
  follow_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  portfolio_id VARCHAR(255) REFERENCES investment_portfolios(portfolio_id) ON DELETE CASCADE,
  followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, portfolio_id)
);

CREATE INDEX idx_followed_portfolios_user_id ON followed_portfolios(user_id);
CREATE INDEX idx_followed_portfolios_portfolio_id ON followed_portfolios(portfolio_id);
```

### 14. Device Tokens Table
```sql
CREATE TABLE device_tokens (
  token_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  device_token VARCHAR(500) NOT NULL,
  platform VARCHAR(20) NOT NULL, -- 'onesignal', 'ios', 'android'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, platform)
);

CREATE INDEX idx_device_tokens_user_id ON device_tokens(user_id);
```

### 15. Notification Settings Table
```sql
CREATE TABLE notification_settings (
  user_id VARCHAR(255) PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
  likes_enabled BOOLEAN DEFAULT true,
  comments_enabled BOOLEAN DEFAULT true,
  follows_enabled BOOLEAN DEFAULT true,
  messages_enabled BOOLEAN DEFAULT true,
  price_alerts_enabled BOOLEAN DEFAULT true,
  portfolio_updates_enabled BOOLEAN DEFAULT true,
  marketing_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 16. Refresh Tokens Table
```sql
CREATE TABLE refresh_tokens (
  token_id VARCHAR(255) PRIMARY KEY,
  user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
  token VARCHAR(500) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(token)
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);
```

---

## API 엔드포인트 상세

### 1. Authentication APIs

#### 1.1 POST /api/v1/auth/register
**회원가입**

**Request:**
```json
{
  "email": "user@example.com",
  "password": "Password123!",
  "username": "username",
  "fullName": "John Doe"
}
```

**Validation:**
- email: 이메일 형식, 중복 확인
- password: 최소 8자, 대문자/소문자/숫자 포함
- username: 3-50자, 영문/숫자/언더스코어, 중복 확인
- fullName: 1-100자

**Response: 201 Created**
```json
{
  "userId": "uuid-here",
  "accessToken": "jwt-token",
  "refreshToken": "refresh-token",
  "expiresIn": 3600
}
```

**Database Operations:**
1. `users` 테이블에 INSERT
2. `notification_settings` 테이블에 기본값 INSERT
3. bcrypt로 비밀번호 해싱

**Error Codes:**
- 400: Invalid input
- 409: Email or username already exists

---

#### 1.2 POST /api/v1/auth/login
**로그인**

**Request:**
```json
{
  "email": "user@example.com",
  "password": "Password123!"
}
```

**Response: 200 OK**
```json
{
  "userId": "uuid-here",
  "accessToken": "jwt-token",
  "refreshToken": "refresh-token",
  "expiresIn": 3600
}
```

**Database Operations:**
1. `users` 테이블에서 email로 SELECT
2. bcrypt로 비밀번호 검증
3. `refresh_tokens` 테이블에 INSERT

**Error Codes:**
- 401: Invalid credentials
- 403: Account is disabled

---

#### 1.3 POST /api/v1/auth/refresh
**토큰 갱신**

**Request:**
```json
{
  "refreshToken": "refresh-token"
}
```

**Response: 200 OK**
```json
{
  "accessToken": "new-jwt-token",
  "refreshToken": "new-refresh-token",
  "expiresIn": 3600
}
```

**Database Operations:**
1. `refresh_tokens` 테이블에서 검증
2. 만료된 토큰 DELETE
3. 새 토큰 INSERT

---

### 2. User APIs

#### 2.1 GET /api/v1/users/:userId
**사용자 프로필 조회**

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response: 200 OK**
```json
{
  "userId": "uuid",
  "username": "username",
  "email": "user@example.com",
  "fullName": "John Doe",
  "bio": "User bio",
  "profileImageUrl": "https://...",
  "followerCount": 100,
  "followingCount": 50,
  "postCount": 25,
  "isVerified": false,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

**Database Operations:**
```sql
SELECT * FROM users WHERE user_id = $1
```

---

#### 2.2 PUT /api/v1/users/:userId
**프로필 업데이트**

**Request:**
```json
{
  "fullName": "John Doe",
  "bio": "Updated bio",
  "profileImageUrl": "https://..."
}
```

**Response: 200 OK**
```json
{
  "message": "Profile updated successfully"
}
```

**Database Operations:**
```sql
UPDATE users
SET full_name = $1, bio = $2, profile_image_url = $3, updated_at = NOW()
WHERE user_id = $4
```

---

### 3. Post APIs

#### 3.1 POST /api/v1/posts
**게시물 생성**

**Request:**
```json
{
  "caption": "Post caption",
  "imageUrls": ["https://...", "https://..."],
  "location": "Seoul, Korea",
  "taggedUsers": ["user_id_1", "user_id_2"]
}
```

**Response: 201 Created**
```json
{
  "postId": "uuid",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

**Database Operations:**
```sql
BEGIN TRANSACTION;

INSERT INTO posts (post_id, user_id, caption, image_urls, location, created_at)
VALUES ($1, $2, $3, $4, $5, NOW());

UPDATE users
SET post_count = post_count + 1
WHERE user_id = $2;

COMMIT;
```

---

#### 3.2 GET /api/v1/posts/feed
**피드 조회**

**Query Parameters:**
- limit: 페이지당 개수 (기본 20)
- offset: 오프셋 (기본 0)

**Response: 200 OK**
```json
{
  "posts": [
    {
      "postId": "uuid",
      "userId": "uuid",
      "username": "username",
      "userPhotoUrl": "https://...",
      "caption": "Post caption",
      "imageUrls": ["https://..."],
      "location": "Seoul",
      "likeCount": 100,
      "commentCount": 25,
      "bookmarkCount": 10,
      "isLiked": true,
      "isBookmarked": false,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "hasMore": true
}
```

**Database Operations:**
```sql
SELECT
  p.*,
  u.username,
  u.profile_image_url as user_photo_url,
  EXISTS(SELECT 1 FROM post_likes WHERE post_id = p.post_id AND user_id = $1) as is_liked,
  EXISTS(SELECT 1 FROM bookmarks WHERE content_id = p.post_id AND user_id = $1) as is_bookmarked
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.user_id IN (
  SELECT following_id FROM follows WHERE follower_id = $1
) OR p.user_id = $1
ORDER BY p.created_at DESC
LIMIT $2 OFFSET $3
```

---

#### 3.3 POST /api/v1/posts/:postId/like
**게시물 좋아요**

**Response: 200 OK**
```json
{
  "message": "Liked successfully",
  "likeCount": 101
}
```

**Database Operations:**
```sql
BEGIN TRANSACTION;

INSERT INTO post_likes (like_id, post_id, user_id, created_at)
VALUES (gen_random_uuid(), $1, $2, NOW())
ON CONFLICT (post_id, user_id) DO NOTHING;

UPDATE posts
SET like_count = like_count + 1
WHERE post_id = $1;

COMMIT;
```

**Notification Trigger:**
```javascript
// 게시물 작성자에게 알림 전송
if (postOwnerId !== currentUserId) {
  await sendNotification(postOwnerId, {
    type: 'like',
    title: '새로운 좋아요',
    message: `${username}님이 회원님의 게시물을 좋아합니다`,
    data: { postId, fromUserId: currentUserId }
  });
}
```

---

### 4. Portfolio APIs

#### 4.1 POST /api/v1/portfolios
**포트폴리오 생성**

**Request:**
```json
{
  "name": "My Portfolio",
  "description": "Long-term investment",
  "isPublic": true
}
```

**Response: 201 Created**
```json
{
  "portfolioId": "uuid",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

**Database Operations:**
```sql
INSERT INTO investment_portfolios (
  portfolio_id, user_id, name, description, is_public, created_at
)
VALUES (gen_random_uuid(), $1, $2, $3, $4, NOW())
RETURNING portfolio_id, created_at
```

---

#### 4.2 GET /api/v1/portfolios
**포트폴리오 목록**

**Query Parameters:**
- userId: 사용자 ID (선택)
- limit: 20 (기본)
- offset: 0 (기본)

**Response: 200 OK**
```json
{
  "portfolios": [
    {
      "portfolioId": "uuid",
      "userId": "uuid",
      "name": "My Portfolio",
      "description": "...",
      "totalValue": 100000.50,
      "totalCost": 90000.00,
      "totalReturn": 10000.50,
      "returnPercentage": 11.11,
      "isPublic": true,
      "followerCount": 50,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-02T00:00:00Z"
    }
  ],
  "hasMore": false
}
```

**Database Operations:**
```sql
SELECT * FROM investment_portfolios
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3
```

---

#### 4.3 POST /api/v1/portfolios/:portfolioId/holdings
**자산 보유 추가**

**Request:**
```json
{
  "assetSymbol": "AAPL",
  "assetName": "Apple Inc.",
  "assetType": "stock",
  "quantity": 10,
  "averagePrice": 150.50
}
```

**Response: 201 Created**
```json
{
  "holdingId": "uuid",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

**Database Operations:**
```sql
BEGIN TRANSACTION;

INSERT INTO asset_holdings (
  holding_id, portfolio_id, asset_symbol, asset_name, asset_type,
  quantity, average_price, current_price, total_value, total_cost,
  purchase_date, updated_at
)
VALUES (
  gen_random_uuid(), $1, $2, $3, $4, $5, $6, $6,
  $5 * $6, $5 * $6, NOW(), NOW()
)
RETURNING holding_id;

-- Update portfolio totals
UPDATE investment_portfolios
SET
  total_cost = total_cost + ($5 * $6),
  total_value = total_value + ($5 * $6),
  updated_at = NOW()
WHERE portfolio_id = $1;

COMMIT;
```

---

### 5. Upload APIs

#### 5.1 POST /api/v1/upload
**파일 업로드**

**Request:**
```
Content-Type: multipart/form-data

file: (binary)
folder: profileImages
fileName: profile.jpg
```

**Response: 200 OK**
```json
{
  "url": "https://res.cloudinary.com/.../image.jpg",
  "fileId": "file_uuid",
  "size": 1024000,
  "mimeType": "image/jpeg"
}
```

**Implementation:**
```javascript
// Multer + Cloudinary
const upload = multer({ storage: cloudinaryStorage });

router.post('/upload', upload.single('file'), async (req, res) => {
  const { folder, fileName } = req.body;

  // File is automatically uploaded to Cloudinary
  const url = req.file.path;
  const fileId = req.file.filename;

  res.json({
    url,
    fileId,
    size: req.file.size,
    mimeType: req.file.mimetype
  });
});
```

---

### 6. Notification APIs

#### 6.1 POST /api/v1/notifications/send
**알림 전송**

**Request:**
```json
{
  "recipientUserId": "uuid",
  "title": "새로운 좋아요",
  "message": "username님이 회원님의 게시물을 좋아합니다",
  "data": {
    "type": "like",
    "postId": "uuid",
    "fromUserId": "uuid"
  }
}
```

**Response: 200 OK**
```json
{
  "success": true,
  "notificationId": "onesignal-notification-id"
}
```

**Implementation:**
```javascript
// OneSignal API 호출
await oneSignalClient.createNotification({
  app_id: process.env.ONESIGNAL_APP_ID,
  include_external_user_ids: [recipientUserId],
  headings: { en: title, ko: title },
  contents: { en: message, ko: message },
  data: data
});

// DB에 알림 저장
await db.query(`
  INSERT INTO notifications (notification_id, user_id, type, title, message, data, created_at)
  VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, NOW())
`, [recipientUserId, data.type, title, message, JSON.stringify(data)]);
```

---

## 인증 & 인가

### JWT 토큰 구조

**Access Token (1시간 유효):**
```json
{
  "userId": "uuid",
  "email": "user@example.com",
  "iat": 1234567890,
  "exp": 1234571490
}
```

**Refresh Token (7일 유효):**
```json
{
  "userId": "uuid",
  "tokenId": "uuid",
  "iat": 1234567890,
  "exp": 1235172690
}
```

### 인증 미들웨어

```typescript
// src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface AuthRequest extends Request {
  user?: {
    userId: string;
    email: string;
  };
}

export const authenticateToken = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        error: {
          code: 'NO_TOKEN',
          message: '인증 토큰이 필요합니다'
        }
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
      userId: string;
      email: string;
    };

    req.user = decoded;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      return res.status(401).json({
        error: {
          code: 'TOKEN_EXPIRED',
          message: '토큰이 만료되었습니다'
        }
      });
    }

    return res.status(403).json({
      error: {
        code: 'INVALID_TOKEN',
        message: '유효하지 않은 토큰입니다'
      }
    });
  }
};
```

---

## Database Service 레이어

### DB Service 구조

```typescript
// src/db/db.service.ts
import { Pool, PoolClient } from 'pg';

export class DatabaseService {
  private pool: Pool;

  constructor() {
    this.pool = new Pool({
      host: process.env.DB_HOST,
      port: parseInt(process.env.DB_PORT || '5432'),
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      max: 20, // 최대 연결 수
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });
  }

  // Single query
  async query(text: string, params?: any[]) {
    const start = Date.now();
    try {
      const result = await this.pool.query(text, params);
      const duration = Date.now() - start;
      console.log('Executed query', { text, duration, rows: result.rowCount });
      return result;
    } catch (error) {
      console.error('Database query error:', error);
      throw error;
    }
  }

  // Get client for transactions
  async getClient(): Promise<PoolClient> {
    return await this.pool.connect();
  }

  // Transaction wrapper
  async transaction<T>(
    callback: (client: PoolClient) => Promise<T>
  ): Promise<T> {
    const client = await this.getClient();
    try {
      await client.query('BEGIN');
      const result = await callback(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  // Close pool
  async close() {
    await this.pool.end();
  }
}

export const db = new DatabaseService();
```

### Query 예제

```typescript
// src/db/queries/users.queries.ts
import { db } from '../db.service';

export class UserQueries {
  // Create user
  async createUser(data: {
    userId: string;
    email: string;
    password: string;
    username: string;
    fullName: string;
  }) {
    const query = `
      INSERT INTO users (user_id, email, password, username, full_name, created_at)
      VALUES ($1, $2, $3, $4, $5, NOW())
      RETURNING user_id, email, username, full_name, created_at
    `;

    const result = await db.query(query, [
      data.userId,
      data.email,
      data.password,
      data.username,
      data.fullName,
    ]);

    return result.rows[0];
  }

  // Find user by email
  async findByEmail(email: string) {
    const query = `
      SELECT * FROM users WHERE email = $1
    `;

    const result = await db.query(query, [email]);
    return result.rows[0];
  }

  // Find user by ID
  async findById(userId: string) {
    const query = `
      SELECT
        user_id, email, username, full_name, bio,
        profile_image_url, follower_count, following_count,
        post_count, is_verified, created_at
      FROM users
      WHERE user_id = $1
    `;

    const result = await db.query(query, [userId]);
    return result.rows[0];
  }

  // Update user profile
  async updateProfile(
    userId: string,
    data: { fullName?: string; bio?: string; profileImageUrl?: string }
  ) {
    const updates: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    if (data.fullName) {
      updates.push(`full_name = $${paramIndex++}`);
      values.push(data.fullName);
    }

    if (data.bio) {
      updates.push(`bio = $${paramIndex++}`);
      values.push(data.bio);
    }

    if (data.profileImageUrl) {
      updates.push(`profile_image_url = $${paramIndex++}`);
      values.push(data.profileImageUrl);
    }

    updates.push(`updated_at = NOW()`);
    values.push(userId);

    const query = `
      UPDATE users
      SET ${updates.join(', ')}
      WHERE user_id = $${paramIndex}
      RETURNING user_id, username, full_name, bio, profile_image_url
    `;

    const result = await db.query(query, values);
    return result.rows[0];
  }

  // Increment follower count
  async incrementFollowerCount(userId: string) {
    const query = `
      UPDATE users
      SET follower_count = follower_count + 1
      WHERE user_id = $1
    `;

    await db.query(query, [userId]);
  }

  // Decrement follower count
  async decrementFollowerCount(userId: string) {
    const query = `
      UPDATE users
      SET follower_count = follower_count - 1
      WHERE user_id = $1 AND follower_count > 0
    `;

    await db.query(query, [userId]);
  }
}

export const userQueries = new UserQueries();
```

---

## 구현 예제

### 완전한 Auth Controller

```typescript
// src/controllers/auth.controller.ts
import { Request, Response } from 'express';
import { authService } from '../services/auth.service';
import { validationResult } from 'express-validator';

export class AuthController {
  // Register
  async register(req: Request, res: Response) {
    try {
      // Validation
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: '입력 데이터가 올바르지 않습니다',
            details: errors.array()
          }
        });
      }

      const { email, password, username, fullName } = req.body;

      // Call service
      const result = await authService.register({
        email,
        password,
        username,
        fullName
      });

      return res.status(201).json(result);
    } catch (error: any) {
      console.error('Register error:', error);

      if (error.code === 'USER_EXISTS') {
        return res.status(409).json({
          error: {
            code: 'USER_EXISTS',
            message: '이미 존재하는 이메일 또는 사용자명입니다'
          }
        });
      }

      return res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: '서버 오류가 발생했습니다'
        }
      });
    }
  }

  // Login
  async login(req: Request, res: Response) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: '입력 데이터가 올바르지 않습니다',
            details: errors.array()
          }
        });
      }

      const { email, password } = req.body;

      const result = await authService.login(email, password);

      return res.status(200).json(result);
    } catch (error: any) {
      console.error('Login error:', error);

      if (error.code === 'INVALID_CREDENTIALS') {
        return res.status(401).json({
          error: {
            code: 'INVALID_CREDENTIALS',
            message: '이메일 또는 비밀번호가 올바르지 않습니다'
          }
        });
      }

      return res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: '서버 오류가 발생했습니다'
        }
      });
    }
  }

  // Refresh token
  async refreshToken(req: Request, res: Response) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({
          error: {
            code: 'NO_REFRESH_TOKEN',
            message: 'Refresh token이 필요합니다'
          }
        });
      }

      const result = await authService.refreshToken(refreshToken);

      return res.status(200).json(result);
    } catch (error: any) {
      console.error('Refresh token error:', error);

      if (error.code === 'INVALID_TOKEN') {
        return res.status(401).json({
          error: {
            code: 'INVALID_TOKEN',
            message: '유효하지 않은 refresh token입니다'
          }
        });
      }

      return res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: '서버 오류가 발생했습니다'
        }
      });
    }
  }
}

export const authController = new AuthController();
```

### Auth Service

```typescript
// src/services/auth.service.ts
import { v4 as uuidv4 } from 'uuid';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { userQueries } from '../db/queries/users.queries';
import { db } from '../db/db.service';

export class AuthService {
  // Register
  async register(data: {
    email: string;
    password: string;
    username: string;
    fullName: string;
  }) {
    // Check if user exists
    const existingUser = await userQueries.findByEmail(data.email);
    if (existingUser) {
      throw { code: 'USER_EXISTS', message: 'Email already exists' };
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(data.password, 10);

    // Generate user ID
    const userId = uuidv4();

    // Create user
    const user = await userQueries.createUser({
      userId,
      email: data.email,
      password: hashedPassword,
      username: data.username,
      fullName: data.fullName
    });

    // Generate tokens
    const accessToken = this.generateAccessToken(userId, data.email);
    const refreshToken = this.generateRefreshToken(userId);

    // Save refresh token
    await this.saveRefreshToken(userId, refreshToken);

    return {
      userId: user.user_id,
      accessToken,
      refreshToken,
      expiresIn: 3600
    };
  }

  // Login
  async login(email: string, password: string) {
    // Find user
    const user = await userQueries.findByEmail(email);
    if (!user) {
      throw { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password' };
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      throw { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password' };
    }

    // Generate tokens
    const accessToken = this.generateAccessToken(user.user_id, user.email);
    const refreshToken = this.generateRefreshToken(user.user_id);

    // Save refresh token
    await this.saveRefreshToken(user.user_id, refreshToken);

    return {
      userId: user.user_id,
      accessToken,
      refreshToken,
      expiresIn: 3600
    };
  }

  // Refresh token
  async refreshToken(refreshToken: string) {
    try {
      // Verify refresh token
      const decoded = jwt.verify(
        refreshToken,
        process.env.JWT_REFRESH_SECRET!
      ) as { userId: string; tokenId: string };

      // Check if token exists in DB
      const result = await db.query(
        `SELECT * FROM refresh_tokens WHERE token = $1 AND user_id = $2`,
        [refreshToken, decoded.userId]
      );

      if (result.rows.length === 0) {
        throw { code: 'INVALID_TOKEN', message: 'Invalid refresh token' };
      }

      // Get user
      const user = await userQueries.findById(decoded.userId);

      // Generate new tokens
      const newAccessToken = this.generateAccessToken(user.user_id, user.email);
      const newRefreshToken = this.generateRefreshToken(user.user_id);

      // Delete old refresh token
      await db.query(`DELETE FROM refresh_tokens WHERE token = $1`, [refreshToken]);

      // Save new refresh token
      await this.saveRefreshToken(user.user_id, newRefreshToken);

      return {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        expiresIn: 3600
      };
    } catch (error) {
      throw { code: 'INVALID_TOKEN', message: 'Invalid refresh token' };
    }
  }

  // Generate access token
  private generateAccessToken(userId: string, email: string): string {
    return jwt.sign(
      { userId, email },
      process.env.JWT_SECRET!,
      { expiresIn: '1h' }
    );
  }

  // Generate refresh token
  private generateRefreshToken(userId: string): string {
    const tokenId = uuidv4();
    return jwt.sign(
      { userId, tokenId },
      process.env.JWT_REFRESH_SECRET!,
      { expiresIn: '7d' }
    );
  }

  // Save refresh token to DB
  private async saveRefreshToken(userId: string, token: string) {
    const tokenId = uuidv4();
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days

    await db.query(
      `INSERT INTO refresh_tokens (token_id, user_id, token, expires_at, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [tokenId, userId, token, expiresAt]
    );
  }
}

export const authService = new AuthService();
```

### Routes

```typescript
// src/routes/auth.routes.ts
import { Router } from 'express';
import { body } from 'express-validator';
import { authController } from '../controllers/auth.controller';

const router = Router();

// POST /api/v1/auth/register
router.post(
  '/register',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 8 }),
    body('username').isLength({ min: 3, max: 50 }).matches(/^[a-zA-Z0-9_]+$/),
    body('fullName').isLength({ min: 1, max: 100 })
  ],
  authController.register.bind(authController)
);

// POST /api/v1/auth/login
router.post(
  '/login',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').notEmpty()
  ],
  authController.login.bind(authController)
);

// POST /api/v1/auth/refresh
router.post('/refresh', authController.refreshToken.bind(authController));

export default router;
```

### Main App Setup

```typescript
// src/app.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import authRoutes from './routes/auth.routes';
import userRoutes from './routes/users.routes';
import postRoutes from './routes/posts.routes';
import portfolioRoutes from './routes/portfolios.routes';
import uploadRoutes from './routes/upload.routes';
import notificationRoutes from './routes/notifications.routes';
import { errorHandler } from './middleware/errorHandler';

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/posts', postRoutes);
app.use('/api/v1/portfolios', portfolioRoutes);
app.use('/api/v1/upload', uploadRoutes);
app.use('/api/v1/notifications', notificationRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Error handler
app.use(errorHandler);

export default app;
```

```typescript
// src/server.ts
import app from './app';
import { db } from './db/db.service';

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // Test database connection
    await db.query('SELECT NOW()');
    console.log('✅ Database connected');

    // Start server
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📝 API: http://localhost:${PORT}/api/v1`);
      console.log(`💚 Health: http://localhost:${PORT}/health`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();
```

---

## 배포 가이드

### 환경 변수 (.env)

```bash
# Server
NODE_ENV=production
PORT=3000

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sns_app
DB_USER=postgres
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-this

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# OneSignal
ONESIGNAL_APP_ID=your_app_id
ONESIGNAL_REST_API_KEY=your_rest_api_key

# Redis (optional)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: sns_app
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
      DB_HOST: postgres
      REDIS_HOST: redis
    depends_on:
      - postgres
      - redis

volumes:
  postgres_data:
```

### Dockerfile

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
```

### 배포 체크리스트

- [ ] 환경 변수 설정
- [ ] PostgreSQL 데이터베이스 생성
- [ ] 데이터베이스 마이그레이션 실행
- [ ] Cloudinary 계정 설정
- [ ] OneSignal App ID 발급
- [ ] HTTPS/SSL 인증서 설정
- [ ] CORS 설정 확인
- [ ] Rate limiting 설정
- [ ] 로깅 설정
- [ ] 모니터링 설정 (PM2, New Relic 등)

---

## 다음 단계

1. **프로젝트 초기화**
   ```bash
   mkdir backend && cd backend
   npm init -y
   npm install express typescript ts-node @types/node @types/express
   npm install pg bcrypt jsonwebtoken express-validator cors helmet morgan
   npm install cloudinary multer multer-storage-cloudinary
   npm install dotenv
   ```

2. **TypeScript 설정**
   ```bash
   npx tsc --init
   ```

3. **데이터베이스 생성**
   ```bash
   createdb sns_app
   psql sns_app < schema.sql
   ```

4. **개발 시작**
   ```bash
   npm run dev
   ```

이 가이드를 기반으로 백엔드 REST API 서버를 구현하시면 됩니다!
