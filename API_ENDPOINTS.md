# REST API Endpoints Documentation

이 문서는 투자 SNS 앱의 백엔드 REST API 서버가 구현해야 하는 모든 엔드포인트를 정의합니다.

## Base URL
```
https://your-api-server.com/api/v1
```

## Authentication
모든 인증이 필요한 요청은 Authorization 헤더에 JWT 토큰을 포함해야 합니다:
```
Authorization: Bearer <jwt_token>
```

---

## 1. Authentication & User Management

### 1.1 회원가입
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "username": "username",
  "fullName": "John Doe"
}

Response: 201 Created
{
  "userId": "user_id",
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token",
  "expiresIn": 3600
}
```

### 1.2 로그인
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response: 200 OK
{
  "userId": "user_id",
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token",
  "expiresIn": 3600
}
```

### 1.3 토큰 갱신
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "refresh_token"
}

Response: 200 OK
{
  "accessToken": "new_jwt_token",
  "refreshToken": "new_refresh_token",
  "expiresIn": 3600
}
```

### 1.4 로그아웃
```http
POST /auth/logout
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Logged out successfully"
}
```

### 1.5 사용자 프로필 조회
```http
GET /users/:userId
Authorization: Bearer <token>

Response: 200 OK
{
  "userId": "user_id",
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

### 1.6 사용자 프로필 업데이트
```http
PUT /users/:userId
Authorization: Bearer <token>
Content-Type: application/json

{
  "fullName": "John Doe",
  "bio": "Updated bio",
  "profileImageUrl": "https://..."
}

Response: 200 OK
{
  "message": "Profile updated successfully"
}
```

### 1.7 사용자 검색
```http
GET /users/search?query=john&limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "users": [...],
  "total": 100,
  "hasMore": true
}
```

---

## 2. Posts (일반 게시물)

### 2.1 게시물 생성
```http
POST /posts
Authorization: Bearer <token>
Content-Type: application/json

{
  "caption": "Post caption",
  "imageUrls": ["https://...", "https://..."],
  "location": "Seoul, Korea",
  "taggedUsers": ["user_id_1", "user_id_2"]
}

Response: 201 Created
{
  "postId": "post_id",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 2.2 게시물 목록 조회 (피드)
```http
GET /posts/feed?limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "posts": [
    {
      "postId": "post_id",
      "userId": "user_id",
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

### 2.3 게시물 상세 조회
```http
GET /posts/:postId
Authorization: Bearer <token>

Response: 200 OK
{
  "postId": "post_id",
  "userId": "user_id",
  "username": "username",
  "userPhotoUrl": "https://...",
  "caption": "Post caption",
  "imageUrls": ["https://..."],
  "location": "Seoul",
  "taggedUsers": [...],
  "likeCount": 100,
  "commentCount": 25,
  "bookmarkCount": 10,
  "isLiked": true,
  "isBookmarked": false,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 2.4 게시물 수정
```http
PUT /posts/:postId
Authorization: Bearer <token>
Content-Type: application/json

{
  "caption": "Updated caption",
  "location": "Busan, Korea"
}

Response: 200 OK
{
  "message": "Post updated successfully"
}
```

### 2.5 게시물 삭제
```http
DELETE /posts/:postId
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Post deleted successfully"
}
```

### 2.6 사용자의 게시물 목록
```http
GET /users/:userId/posts?limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "posts": [...],
  "total": 50,
  "hasMore": true
}
```

---

## 3. Investment Posts (투자 아이디어)

### 3.1 투자 게시물 생성
```http
POST /investment-posts
Authorization: Bearer <token>
Content-Type: application/json

{
  "portfolioId": "portfolio_id",
  "title": "내 포트폴리오 소개",
  "content": "투자 전략 설명...",
  "imageUrls": ["https://..."],
  "tags": ["주식", "배당"],
  "relatedAssets": [
    {
      "symbol": "AAPL",
      "name": "Apple Inc.",
      "type": "stock"
    }
  ]
}

Response: 201 Created
{
  "postId": "post_id",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 3.2 투자 게시물 목록 조회
```http
GET /investment-posts?limit=20&offset=0&sortBy=recent
Authorization: Bearer <token>

Query Parameters:
- sortBy: recent | popular | trending
- assetType: stock | crypto | etf | bond | commodity | forex
- tags: 주식,배당 (comma-separated)

Response: 200 OK
{
  "posts": [
    {
      "postId": "post_id",
      "userId": "user_id",
      "username": "username",
      "userPhotoUrl": "https://...",
      "portfolioId": "portfolio_id",
      "title": "투자 아이디어",
      "content": "...",
      "imageUrls": ["https://..."],
      "tags": ["주식", "배당"],
      "relatedAssets": [...],
      "likeCount": 50,
      "commentCount": 10,
      "bookmarkCount": 5,
      "viewCount": 500,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "hasMore": true
}
```

### 3.3 투자 게시물 상세 조회
```http
GET /investment-posts/:postId
Authorization: Bearer <token>

Response: 200 OK
{
  "postId": "post_id",
  "userId": "user_id",
  "username": "username",
  "portfolioId": "portfolio_id",
  "portfolioName": "My Portfolio",
  "title": "투자 아이디어",
  "content": "...",
  "imageUrls": ["https://..."],
  "tags": ["주식", "배당"],
  "relatedAssets": [...],
  "likeCount": 50,
  "commentCount": 10,
  "bookmarkCount": 5,
  "viewCount": 500,
  "isLiked": true,
  "isBookmarked": false,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

---

## 4. Comments & Likes

### 4.1 댓글 추가
```http
POST /posts/:postId/comments
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "Great post!",
  "parentCommentId": null
}

Response: 201 Created
{
  "commentId": "comment_id",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 4.2 댓글 목록 조회
```http
GET /posts/:postId/comments?limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "comments": [
    {
      "commentId": "comment_id",
      "userId": "user_id",
      "username": "username",
      "userPhotoUrl": "https://...",
      "content": "Great post!",
      "likeCount": 5,
      "isLiked": false,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 100,
  "hasMore": true
}
```

### 4.3 댓글 삭제
```http
DELETE /comments/:commentId
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Comment deleted successfully"
}
```

### 4.4 좋아요 추가
```http
POST /posts/:postId/like
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Liked successfully",
  "likeCount": 101
}
```

### 4.5 좋아요 취소
```http
DELETE /posts/:postId/like
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Unliked successfully",
  "likeCount": 100
}
```

---

## 5. Following & Followers

### 5.1 팔로우
```http
POST /users/:userId/follow
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Followed successfully"
}
```

### 5.2 언팔로우
```http
DELETE /users/:userId/follow
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Unfollowed successfully"
}
```

### 5.3 팔로워 목록
```http
GET /users/:userId/followers?limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "users": [...],
  "total": 100,
  "hasMore": true
}
```

### 5.4 팔로잉 목록
```http
GET /users/:userId/following?limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "users": [...],
  "total": 50,
  "hasMore": true
}
```

---

## 6. Investment Portfolios

### 6.1 포트폴리오 생성
```http
POST /portfolios
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "My Portfolio",
  "description": "Long-term investment portfolio",
  "isPublic": true
}

Response: 201 Created
{
  "portfolioId": "portfolio_id",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 6.2 포트폴리오 목록 조회
```http
GET /portfolios?userId=user_id&limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "portfolios": [
    {
      "portfolioId": "portfolio_id",
      "userId": "user_id",
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

### 6.3 포트폴리오 상세 조회
```http
GET /portfolios/:portfolioId
Authorization: Bearer <token>

Response: 200 OK
{
  "portfolioId": "portfolio_id",
  "userId": "user_id",
  "username": "username",
  "name": "My Portfolio",
  "description": "...",
  "totalValue": 100000.50,
  "totalCost": 90000.00,
  "totalReturn": 10000.50,
  "returnPercentage": 11.11,
  "isPublic": true,
  "followerCount": 50,
  "holdings": [...],
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-02T00:00:00Z"
}
```

### 6.4 포트폴리오 업데이트
```http
PUT /portfolios/:portfolioId
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Updated Portfolio Name",
  "description": "Updated description",
  "isPublic": false
}

Response: 200 OK
{
  "message": "Portfolio updated successfully"
}
```

### 6.5 포트폴리오 삭제
```http
DELETE /portfolios/:portfolioId
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Portfolio deleted successfully"
}
```

### 6.6 공개 포트폴리오 목록 (탐색)
```http
GET /portfolios/public?sortBy=return&limit=20&offset=0
Authorization: Bearer <token>

Query Parameters:
- sortBy: return | followers | recent
- minReturn: 10 (최소 수익률 %)
- maxRisk: 70 (최대 위험도)

Response: 200 OK
{
  "portfolios": [...],
  "hasMore": true
}
```

---

## 7. Asset Holdings

### 7.1 보유 자산 추가
```http
POST /portfolios/:portfolioId/holdings
Authorization: Bearer <token>
Content-Type: application/json

{
  "assetSymbol": "AAPL",
  "assetName": "Apple Inc.",
  "assetType": "stock",
  "quantity": 10,
  "averagePrice": 150.50
}

Response: 201 Created
{
  "holdingId": "holding_id",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 7.2 보유 자산 목록 조회
```http
GET /portfolios/:portfolioId/holdings
Authorization: Bearer <token>

Response: 200 OK
{
  "holdings": [
    {
      "holdingId": "holding_id",
      "portfolioId": "portfolio_id",
      "assetSymbol": "AAPL",
      "assetName": "Apple Inc.",
      "assetType": "stock",
      "quantity": 10,
      "averagePrice": 150.50,
      "currentPrice": 165.00,
      "totalValue": 1650.00,
      "unrealizedGain": 145.00,
      "unrealizedGainPercent": 9.63,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-02T00:00:00Z"
    }
  ]
}
```

### 7.3 보유 자산 업데이트
```http
PUT /holdings/:holdingId
Authorization: Bearer <token>
Content-Type: application/json

{
  "quantity": 15,
  "averagePrice": 155.00
}

Response: 200 OK
{
  "message": "Holding updated successfully"
}
```

### 7.4 보유 자산 삭제
```http
DELETE /holdings/:holdingId
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Holding deleted successfully"
}
```

---

## 8. Trade History

### 8.1 거래 기록 추가
```http
POST /portfolios/:portfolioId/trades
Authorization: Bearer <token>
Content-Type: application/json

{
  "assetSymbol": "AAPL",
  "assetName": "Apple Inc.",
  "assetType": "stock",
  "tradeType": "buy",
  "quantity": 10,
  "price": 150.50,
  "fee": 1.50,
  "notes": "Long-term investment"
}

Response: 201 Created
{
  "tradeId": "trade_id",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 8.2 거래 기록 목록 조회
```http
GET /portfolios/:portfolioId/trades?limit=50&offset=0
Authorization: Bearer <token>

Query Parameters:
- assetSymbol: AAPL (filter by asset)
- tradeType: buy | sell
- startDate: 2024-01-01
- endDate: 2024-12-31

Response: 200 OK
{
  "trades": [
    {
      "tradeId": "trade_id",
      "portfolioId": "portfolio_id",
      "assetSymbol": "AAPL",
      "assetName": "Apple Inc.",
      "assetType": "stock",
      "tradeType": "buy",
      "quantity": 10,
      "price": 150.50,
      "totalAmount": 1505.00,
      "fee": 1.50,
      "notes": "...",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 100,
  "hasMore": true
}
```

### 8.3 거래 기록 삭제
```http
DELETE /trades/:tradeId
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Trade deleted successfully"
}
```

---

## 9. Bookmarks

### 9.1 북마크 추가
```http
POST /bookmarks
Authorization: Bearer <token>
Content-Type: application/json

{
  "contentId": "post_id",
  "type": "post",
  "contentPreview": "Post preview text",
  "contentImageUrl": "https://...",
  "authorUsername": "username",
  "authorPhotoUrl": "https://..."
}

Response: 201 Created
{
  "bookmarkId": "bookmark_id",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 9.2 북마크 목록 조회
```http
GET /bookmarks?type=post&limit=20&offset=0
Authorization: Bearer <token>

Query Parameters:
- type: post | investmentPost | reel

Response: 200 OK
{
  "bookmarks": [
    {
      "bookmarkId": "bookmark_id",
      "userId": "user_id",
      "contentId": "post_id",
      "type": "post",
      "contentPreview": "...",
      "contentImageUrl": "https://...",
      "authorUsername": "username",
      "authorPhotoUrl": "https://...",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "hasMore": true
}
```

### 9.3 북마크 삭제
```http
DELETE /bookmarks/:bookmarkId
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Bookmark removed successfully"
}
```

### 9.4 북마크 상태 확인
```http
GET /bookmarks/check?contentId=post_id&type=post
Authorization: Bearer <token>

Response: 200 OK
{
  "isBookmarked": true,
  "bookmarkId": "bookmark_id"
}
```

---

## 10. Watchlist & Price Alerts

### 10.1 워치리스트 추가
```http
POST /watchlist
Authorization: Bearer <token>
Content-Type: application/json

{
  "assetSymbol": "AAPL",
  "assetName": "Apple Inc.",
  "assetType": "stock",
  "addedPrice": 150.50,
  "alertEnabled": true,
  "alertCondition": "above",
  "targetPrice": 160.00
}

Response: 201 Created
{
  "watchlistId": "watchlist_id",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 10.2 워치리스트 목록 조회
```http
GET /watchlist?limit=50&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "items": [
    {
      "watchlistId": "watchlist_id",
      "userId": "user_id",
      "assetSymbol": "AAPL",
      "assetName": "Apple Inc.",
      "assetType": "stock",
      "addedPrice": 150.50,
      "currentPrice": 155.00,
      "changePercent": 2.99,
      "alertEnabled": true,
      "alertCondition": "above",
      "targetPrice": 160.00,
      "alertTriggered": false,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 10.3 워치리스트 업데이트
```http
PUT /watchlist/:watchlistId
Authorization: Bearer <token>
Content-Type: application/json

{
  "alertEnabled": true,
  "alertCondition": "below",
  "targetPrice": 145.00
}

Response: 200 OK
{
  "message": "Watchlist updated successfully"
}
```

### 10.4 워치리스트 삭제
```http
DELETE /watchlist/:watchlistId
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Watchlist item removed successfully"
}
```

---

## 11. Notifications

### 11.1 알림 목록 조회
```http
GET /notifications?limit=50&offset=0&unreadOnly=true
Authorization: Bearer <token>

Response: 200 OK
{
  "notifications": [
    {
      "notificationId": "notification_id",
      "userId": "user_id",
      "type": "like",
      "title": "새로운 좋아요",
      "message": "username님이 회원님의 게시물을 좋아합니다",
      "data": {
        "postId": "post_id",
        "fromUserId": "from_user_id"
      },
      "isRead": false,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "unreadCount": 5,
  "hasMore": true
}
```

### 11.2 알림 읽음 처리
```http
PUT /notifications/:notificationId/read
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Notification marked as read"
}
```

### 11.3 모든 알림 읽음 처리
```http
PUT /notifications/read-all
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "All notifications marked as read"
}
```

### 11.4 알림 삭제
```http
DELETE /notifications/:notificationId
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Notification deleted successfully"
}
```

---

## 12. Social Trading

### 12.1 포트폴리오 팔로우
```http
POST /portfolios/:portfolioId/follow
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Portfolio followed successfully",
  "followerCount": 51
}
```

### 12.2 포트폴리오 언팔로우
```http
DELETE /portfolios/:portfolioId/follow
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Portfolio unfollowed successfully",
  "followerCount": 50
}
```

### 12.3 팔로우 중인 포트폴리오 목록
```http
GET /portfolios/followed?limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "portfolios": [...],
  "hasMore": true
}
```

### 12.4 포트폴리오 복사
```http
POST /portfolios/:portfolioId/copy
Authorization: Bearer <token>
Content-Type: application/json

{
  "newPortfolioName": "Copied from Expert Trader"
}

Response: 201 Created
{
  "newPortfolioId": "new_portfolio_id",
  "message": "Portfolio copied successfully"
}
```

### 12.5 트렌딩 포트폴리오
```http
GET /portfolios/trending?limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "portfolios": [
    {
      "portfolioId": "portfolio_id",
      "userId": "user_id",
      "username": "username",
      "userPhotoUrl": "https://...",
      "name": "Portfolio Name",
      "description": "...",
      "returnPercentage": 25.5,
      "followerCount": 1000,
      "riskScore": 45.0,
      "riskLevel": "중간"
    }
  ],
  "hasMore": true
}
```

---

## 13. Portfolio Analytics

### 13.1 포트폴리오 분석 조회
```http
GET /portfolios/:portfolioId/analytics
Authorization: Bearer <token>

Response: 200 OK
{
  "portfolioId": "portfolio_id",
  "riskScore": 45.5,
  "riskLevel": "중간",
  "diversificationScore": 72.3,
  "sharpeRatio": 1.25,
  "sectorAllocation": {
    "주식": 60.0,
    "암호화폐": 20.0,
    "ETF": 15.0,
    "채권": 5.0
  },
  "topPerformers": [
    {
      "assetSymbol": "AAPL",
      "assetName": "Apple Inc.",
      "returnPercentage": 15.5
    }
  ],
  "worstPerformers": [...],
  "calculatedAt": "2024-01-01T00:00:00Z"
}
```

### 13.2 섹터 할당 조회
```http
GET /portfolios/:portfolioId/allocation
Authorization: Bearer <token>

Response: 200 OK
{
  "allocation": {
    "주식": 60.0,
    "암호화폐": 20.0,
    "ETF": 15.0,
    "채권": 5.0
  },
  "totalValue": 100000.00
}
```

---

## 14. Real-time Prices (WebSocket)

### 14.1 WebSocket 연결
```
wss://your-api-server.com/ws/prices?token=<jwt_token>
```

### 14.2 가격 구독 (Client → Server)
```json
{
  "action": "subscribe",
  "assets": [
    {
      "symbol": "AAPL",
      "type": "stock"
    },
    {
      "symbol": "BTC-USD",
      "type": "crypto"
    }
  ]
}
```

### 14.3 가격 업데이트 (Server → Client)
```json
{
  "type": "price_update",
  "data": {
    "symbol": "AAPL",
    "assetType": "stock",
    "price": 155.50,
    "change": 2.50,
    "changePercent": 1.63,
    "volume": 50000000,
    "timestamp": "2024-01-01T12:00:00Z"
  }
}
```

### 14.4 구독 취소 (Client → Server)
```json
{
  "action": "unsubscribe",
  "assets": [
    {
      "symbol": "AAPL",
      "type": "stock"
    }
  ]
}
```

---

## 15. Search

### 15.1 통합 검색
```http
GET /search?query=apple&type=all&limit=20&offset=0
Authorization: Bearer <token>

Query Parameters:
- type: all | users | posts | assets | portfolios
- query: search term

Response: 200 OK
{
  "users": [...],
  "posts": [...],
  "investmentPosts": [...],
  "assets": [...],
  "portfolios": [...],
  "hasMore": true
}
```

### 15.2 자산 검색
```http
GET /assets/search?query=apple&type=stock&limit=20
Authorization: Bearer <token>

Response: 200 OK
{
  "assets": [
    {
      "symbol": "AAPL",
      "name": "Apple Inc.",
      "type": "stock",
      "exchange": "NASDAQ",
      "currentPrice": 155.50,
      "changePercent": 1.63
    }
  ]
}
```

---

## 16. Messages (Direct Messages)

### 16.1 대화 목록 조회
```http
GET /messages/conversations?limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "conversations": [
    {
      "conversationId": "conversation_id",
      "otherUser": {
        "userId": "user_id",
        "username": "username",
        "photoUrl": "https://..."
      },
      "lastMessage": {
        "content": "Hello!",
        "createdAt": "2024-01-01T12:00:00Z"
      },
      "unreadCount": 2
    }
  ],
  "hasMore": true
}
```

### 16.2 메시지 목록 조회
```http
GET /messages/conversations/:conversationId?limit=50&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "messages": [
    {
      "messageId": "message_id",
      "conversationId": "conversation_id",
      "senderId": "user_id",
      "content": "Hello!",
      "isRead": true,
      "createdAt": "2024-01-01T12:00:00Z"
    }
  ],
  "hasMore": true
}
```

### 16.3 메시지 전송
```http
POST /messages/conversations/:conversationId
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "Hello!",
  "type": "text"
}

Response: 201 Created
{
  "messageId": "message_id",
  "createdAt": "2024-01-01T12:00:00Z"
}
```

### 16.4 메시지 읽음 처리
```http
PUT /messages/:messageId/read
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Message marked as read"
}
```

---

## 17. Stories

### 17.1 스토리 생성
```http
POST /stories
Authorization: Bearer <token>
Content-Type: application/json

{
  "mediaUrl": "https://...",
  "mediaType": "image",
  "caption": "Check this out!",
  "backgroundColor": "#000000",
  "duration": 5
}

Response: 201 Created
{
  "storyId": "story_id",
  "createdAt": "2024-01-01T00:00:00Z",
  "expiresAt": "2024-01-02T00:00:00Z"
}
```

### 17.2 스토리 목록 조회 (팔로잉 중인 사용자)
```http
GET /stories?limit=20
Authorization: Bearer <token>

Response: 200 OK
{
  "stories": [
    {
      "userId": "user_id",
      "username": "username",
      "userPhotoUrl": "https://...",
      "hasUnviewed": true,
      "stories": [
        {
          "storyId": "story_id",
          "userId": "user_id",
          "mediaUrl": "https://...",
          "mediaType": "image",
          "caption": "Check this out!",
          "backgroundColor": "#000000",
          "duration": 5,
          "viewCount": 10,
          "hasViewed": false,
          "createdAt": "2024-01-01T00:00:00Z",
          "expiresAt": "2024-01-02T00:00:00Z"
        }
      ]
    }
  ]
}
```

### 17.3 사용자의 스토리 조회
```http
GET /stories/:userId
Authorization: Bearer <token>

Response: 200 OK
{
  "userId": "user_id",
  "username": "username",
  "userPhotoUrl": "https://...",
  "stories": [
    {
      "storyId": "story_id",
      "mediaUrl": "https://...",
      "mediaType": "image",
      "caption": "...",
      "duration": 5,
      "viewCount": 10,
      "hasViewed": false,
      "createdAt": "2024-01-01T00:00:00Z",
      "expiresAt": "2024-01-02T00:00:00Z"
    }
  ]
}
```

### 17.4 스토리 조회 기록 추가
```http
POST /stories/:storyId/view
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Story view recorded"
}
```

### 17.5 스토리 삭제
```http
DELETE /stories/:storyId
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Story deleted successfully"
}
```

---

## 18. Reels

### 18.1 릴스 생성
```http
POST /reels
Authorization: Bearer <token>
Content-Type: application/json

{
  "videoUrl": "https://...",
  "thumbnailUrl": "https://...",
  "caption": "Amazing content!",
  "audioName": "Original Audio",
  "duration": 30
}

Response: 201 Created
{
  "reelId": "reel_id",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 18.2 릴스 피드 조회
```http
GET /reels/feed?limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "reels": [
    {
      "reelId": "reel_id",
      "userId": "user_id",
      "username": "username",
      "userPhotoUrl": "https://...",
      "videoUrl": "https://...",
      "thumbnailUrl": "https://...",
      "caption": "Amazing content!",
      "audioName": "Original Audio",
      "duration": 30,
      "likeCount": 1000,
      "commentCount": 50,
      "shareCount": 25,
      "viewCount": 10000,
      "isLiked": false,
      "isBookmarked": false,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "hasMore": true
}
```

### 18.3 릴스 상세 조회
```http
GET /reels/:reelId
Authorization: Bearer <token>

Response: 200 OK
{
  "reelId": "reel_id",
  "userId": "user_id",
  "username": "username",
  "userPhotoUrl": "https://...",
  "videoUrl": "https://...",
  "thumbnailUrl": "https://...",
  "caption": "Amazing content!",
  "audioName": "Original Audio",
  "duration": 30,
  "likeCount": 1000,
  "commentCount": 50,
  "shareCount": 25,
  "viewCount": 10000,
  "isLiked": false,
  "isBookmarked": false,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 18.4 사용자의 릴스 목록
```http
GET /users/:userId/reels?limit=20&offset=0
Authorization: Bearer <token>

Response: 200 OK
{
  "reels": [...],
  "total": 50,
  "hasMore": true
}
```

### 18.5 릴스 삭제
```http
DELETE /reels/:reelId
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Reel deleted successfully"
}
```

### 18.6 릴스 좋아요
```http
POST /reels/:reelId/like
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Liked successfully",
  "likeCount": 1001
}
```

### 18.7 릴스 좋아요 취소
```http
DELETE /reels/:reelId/like
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Unliked successfully",
  "likeCount": 1000
}
```

### 18.8 릴스 조회수 증가
```http
POST /reels/:reelId/view
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "View recorded",
  "viewCount": 10001
}
```

---

## 19. File Upload

### 19.1 이미지/비디오 업로드
```http
POST /upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

Form Data:
- file: (binary)
- type: image | video
- purpose: profile | post | portfolio

Response: 200 OK
{
  "url": "https://cdn.your-server.com/uploads/file_id.jpg",
  "fileId": "file_id",
  "size": 1024000,
  "mimeType": "image/jpeg"
}
```

---

## Error Responses

모든 에러는 다음 형식으로 반환됩니다:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {}
  }
}
```

### Common Error Codes
- `400` - Bad Request (잘못된 요청)
- `401` - Unauthorized (인증 실패)
- `403` - Forbidden (권한 없음)
- `404` - Not Found (리소스 없음)
- `409` - Conflict (중복 데이터)
- `422` - Unprocessable Entity (검증 실패)
- `429` - Too Many Requests (요청 제한 초과)
- `500` - Internal Server Error (서버 오류)
- `503` - Service Unavailable (서비스 일시 중단)

---

## Rate Limiting

API 요청은 다음과 같이 제한됩니다:

- **일반 요청**: 100 requests/minute per user
- **검색**: 30 requests/minute per user
- **파일 업로드**: 10 uploads/minute per user
- **메시지**: 50 requests/minute per user

Rate limit 초과 시 `429 Too Many Requests` 응답이 반환됩니다.

---

## Pagination

모든 리스트 API는 pagination을 지원합니다:

```
GET /endpoint?limit=20&offset=0
```

Response에는 `hasMore` 필드가 포함됩니다:

```json
{
  "items": [...],
  "total": 100,
  "hasMore": true
}
```

---

## WebSocket Events

실시간 기능을 위한 WebSocket 이벤트:

1. **가격 업데이트**: `price_update`
2. **새 알림**: `notification`
3. **새 메시지**: `new_message`
4. **포트폴리오 업데이트**: `portfolio_update`

---

## Notes

1. 모든 날짜/시간은 **ISO 8601 형식** (UTC)으로 전송됩니다
2. 모든 숫자 필드는 **소수점 2자리**로 반올림됩니다 (가격, 수익률 등)
3. **JWT 토큰**은 1시간 유효하며, refresh token으로 갱신 가능합니다
4. 파일 업로드는 **최대 50MB**로 제한됩니다
5. WebSocket 연결은 **60초 idle timeout**이 적용됩니다
