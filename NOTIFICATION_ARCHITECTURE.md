# Push Notification Architecture (OneSignal)

Firebase 없이 OneSignal을 사용한 푸시 알림 시스템 아키텍처입니다.

## 아키텍처 개요

```
┌─────────────────┐
│  Flutter App    │
│  (OneSignal SDK)│
└────────┬────────┘
         │ Register Device
         │ (Player ID)
         ↓
┌─────────────────┐      ┌──────────────────┐
│  REST API       │─────→│   OneSignal      │
│  Server         │←─────│   REST API       │
└────────┬────────┘      └──────────────────┘
         │                         ↓
         │                  Push to Devices
         ↓
┌─────────────────┐
│  Database       │
│  (User tokens)  │
└─────────────────┘
```

## OneSignal 설정

### 1. OneSignal 계정 생성

1. [OneSignal](https://onesignal.com) 회원가입
2. 새 앱 생성
3. **App ID** 복사 → `notification_service_onesignal.dart`에 입력

### 2. iOS 설정

**OneSignal Dashboard에서:**
1. Settings → Apple iOS (APNs)
2. APNs 인증서 또는 Key 업로드

**Xcode 설정:**
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<key>OSNotificationServiceExtension</key>
<true/>
```

**Capabilities 활성화:**
- Push Notifications
- Background Modes → Remote notifications

### 3. Android 설정

**OneSignal Dashboard에서:**
1. Settings → Google Android (FCM)
2. Firebase Server Key 입력 (또는 OneSignal이 자동 생성)

**AndroidManifest.xml:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application>
        <!-- OneSignal will automatically add required components -->
    </application>
</manifest>
```

**gradle 설정:**
```gradle
// android/app/build.gradle
android {
    defaultConfig {
        manifestPlaceholders = [
            onesignal_app_id: 'YOUR_ONESIGNAL_APP_ID',
            onesignal_google_project_number: 'REMOTE'
        ]
    }
}
```

## Flutter 앱 통합

### 초기화 (main.dart)

```dart
import 'package:sns_app/services/notification_service_onesignal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal
  final notificationService = NotificationServiceOneSignal();
  await notificationService.initialize();

  runApp(MyApp());
}
```

### 로그인 후 사용자 등록

```dart
// After successful login
Future<void> onUserLogin(User user) async {
  final notificationService = NotificationServiceOneSignal();

  // Set user ID in OneSignal
  await notificationService.setUserId(user.userId);

  // Register device token with your backend
  await notificationService.registerDeviceToken(user.userId);

  // Set user tags for targeting
  await notificationService.setTags({
    'username': user.username,
    'language': 'ko',
    'subscription': user.isPremium ? 'premium' : 'free',
    'interests': 'stocks,crypto', // User preferences
  });
}
```

### 로그아웃 시 정리

```dart
Future<void> onUserLogout() async {
  final notificationService = NotificationServiceOneSignal();

  // Remove user ID from OneSignal
  await notificationService.removeUserId();
}
```

### 알림 권한 요청

```dart
// Ask for permission (iOS)
Future<void> requestNotificationPermission() async {
  final notificationService = NotificationServiceOneSignal();

  final granted = await notificationService.promptForPermission();

  if (granted) {
    print('Notification permission granted');
  } else {
    print('Notification permission denied');
  }
}
```

## Backend 서버 통합

### 1. OneSignal REST API 사용

**환경 변수 설정:**
```env
ONESIGNAL_APP_ID=your_app_id
ONESIGNAL_REST_API_KEY=your_rest_api_key
```

### 2. 알림 발송 (Node.js 예제)

```javascript
// Backend: services/notificationService.js
const axios = require('axios');

class NotificationService {
  constructor() {
    this.appId = process.env.ONESIGNAL_APP_ID;
    this.apiKey = process.env.ONESIGNAL_REST_API_KEY;
    this.baseUrl = 'https://onesignal.com/api/v1';
  }

  /**
   * Send notification to specific user
   */
  async sendToUser(userId, title, message, data = {}) {
    try {
      const response = await axios.post(
        `${this.baseUrl}/notifications`,
        {
          app_id: this.appId,
          include_external_user_ids: [userId],
          headings: { en: title, ko: title },
          contents: { en: message, ko: message },
          data: data,
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Basic ${this.apiKey}`,
          },
        }
      );

      return response.data;
    } catch (error) {
      console.error('Error sending notification:', error);
      throw error;
    }
  }

  /**
   * Send notification to multiple users
   */
  async sendToUsers(userIds, title, message, data = {}) {
    try {
      const response = await axios.post(
        `${this.baseUrl}/notifications`,
        {
          app_id: this.appId,
          include_external_user_ids: userIds,
          headings: { en: title, ko: title },
          contents: { en: message, ko: message },
          data: data,
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Basic ${this.apiKey}`,
          },
        }
      );

      return response.data;
    } catch (error) {
      console.error('Error sending notifications:', error);
      throw error;
    }
  }

  /**
   * Send notification to users with specific tags
   */
  async sendToSegment(filters, title, message, data = {}) {
    try {
      const response = await axios.post(
        `${this.baseUrl}/notifications`,
        {
          app_id: this.appId,
          filters: filters,
          headings: { en: title, ko: title },
          contents: { en: message, ko: message },
          data: data,
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Basic ${this.apiKey}`,
          },
        }
      );

      return response.data;
    } catch (error) {
      console.error('Error sending segment notification:', error);
      throw error;
    }
  }

  /**
   * Send notification to all users
   */
  async sendToAll(title, message, data = {}) {
    try {
      const response = await axios.post(
        `${this.baseUrl}/notifications`,
        {
          app_id: this.appId,
          included_segments: ['All'],
          headings: { en: title, ko: title },
          contents: { en: message, ko: message },
          data: data,
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Basic ${this.apiKey}`,
          },
        }
      );

      return response.data;
    } catch (error) {
      console.error('Error sending broadcast notification:', error);
      throw error;
    }
  }
}

module.exports = new NotificationService();
```

### 3. API 엔드포인트 구현

```javascript
// Backend: routes/notifications.js
const express = require('express');
const router = express.Router();
const notificationService = require('../services/notificationService');
const { authenticateToken } = require('../middleware/auth');

/**
 * POST /api/v1/notifications/send
 * Send notification to a user
 */
router.post('/send', authenticateToken, async (req, res) => {
  try {
    const { recipientUserId, title, message, data } = req.body;

    const result = await notificationService.sendToUser(
      recipientUserId,
      title,
      message,
      data
    );

    res.json({
      success: true,
      notificationId: result.id,
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({
      error: {
        code: 'NOTIFICATION_ERROR',
        message: '알림 전송에 실패했습니다',
      },
    });
  }
});

/**
 * POST /api/v1/notifications/send-bulk
 * Send notification to multiple users
 */
router.post('/send-bulk', authenticateToken, async (req, res) => {
  try {
    const { recipientUserIds, title, message, data } = req.body;

    const result = await notificationService.sendToUsers(
      recipientUserIds,
      title,
      message,
      data
    );

    res.json({
      success: true,
      notificationId: result.id,
      recipients: result.recipients,
    });
  } catch (error) {
    console.error('Error sending bulk notification:', error);
    res.status(500).json({
      error: {
        code: 'NOTIFICATION_ERROR',
        message: '알림 전송에 실패했습니다',
      },
    });
  }
});

/**
 * POST /api/v1/users/:userId/device-token
 * Register device token
 */
router.post('/:userId/device-token', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const { deviceToken, platform } = req.body;

    // Store device token in database
    await db.query(
      'INSERT INTO device_tokens (user_id, token, platform) VALUES ($1, $2, $3) ON CONFLICT (user_id) DO UPDATE SET token = $2, platform = $3',
      [userId, deviceToken, platform]
    );

    res.json({
      success: true,
      message: 'Device token registered',
    });
  } catch (error) {
    console.error('Error registering device token:', error);
    res.status(500).json({
      error: {
        code: 'TOKEN_REGISTRATION_ERROR',
        message: '디바이스 토큰 등록에 실패했습니다',
      },
    });
  }
});

module.exports = router;
```

## 알림 타입별 구현

### 1. 좋아요 알림

```javascript
// Backend: When user likes a post
async function onPostLiked(postId, likerUserId, postAuthorId) {
  if (likerUserId === postAuthorId) return; // Don't notify self

  const liker = await db.query('SELECT username FROM users WHERE user_id = $1', [likerUserId]);

  await notificationService.sendToUser(
    postAuthorId,
    '새로운 좋아요',
    `${liker.username}님이 회원님의 게시물을 좋아합니다`,
    {
      type: 'like',
      postId: postId,
      fromUserId: likerUserId,
    }
  );
}
```

### 2. 댓글 알림

```javascript
async function onCommentAdded(postId, commenterId, postAuthorId, commentText) {
  if (commenterId === postAuthorId) return;

  const commenter = await db.query('SELECT username FROM users WHERE user_id = $1', [commenterId]);

  await notificationService.sendToUser(
    postAuthorId,
    '새로운 댓글',
    `${commenter.username}님이 댓글을 남겼습니다: "${commentText}"`,
    {
      type: 'comment',
      postId: postId,
      fromUserId: commenterId,
    }
  );
}
```

### 3. 팔로우 알림

```javascript
async function onUserFollowed(followerId, followedUserId) {
  const follower = await db.query('SELECT username FROM users WHERE user_id = $1', [followerId]);

  await notificationService.sendToUser(
    followedUserId,
    '새로운 팔로워',
    `${follower.username}님이 회원님을 팔로우하기 시작했습니다`,
    {
      type: 'follow',
      fromUserId: followerId,
    }
  );
}
```

### 4. 가격 알림

```javascript
async function onPriceAlert(userId, symbol, currentPrice, targetPrice, condition) {
  let message = '';

  if (condition === 'above') {
    message = `${symbol}이(가) ₩${currentPrice.toLocaleString()}로 목표가 ₩${targetPrice.toLocaleString()}를 넘었습니다!`;
  } else if (condition === 'below') {
    message = `${symbol}이(가) ₩${currentPrice.toLocaleString()}로 목표가 ₩${targetPrice.toLocaleString()} 아래로 떨어졌습니다!`;
  }

  await notificationService.sendToUser(
    userId,
    '가격 알림',
    message,
    {
      type: 'price_alert',
      symbol: symbol,
      currentPrice: currentPrice,
      targetPrice: targetPrice,
    }
  );
}
```

### 5. 포트폴리오 팔로워 알림

```javascript
async function onPortfolioFollowed(followerId, portfolioId, portfolioOwnerId) {
  if (followerId === portfolioOwnerId) return;

  const follower = await db.query('SELECT username FROM users WHERE user_id = $1', [followerId]);
  const portfolio = await db.query('SELECT name FROM portfolios WHERE portfolio_id = $1', [portfolioId]);

  await notificationService.sendToUser(
    portfolioOwnerId,
    '포트폴리오 팔로워',
    `${follower.username}님이 "${portfolio.name}" 포트폴리오를 팔로우하기 시작했습니다`,
    {
      type: 'portfolio_follower',
      portfolioId: portfolioId,
      fromUserId: followerId,
    }
  );
}
```

### 6. 메시지 알림

```javascript
async function onMessageReceived(senderId, recipientId, conversationId, messageText) {
  const sender = await db.query('SELECT username FROM users WHERE user_id = $1', [senderId]);

  await notificationService.sendToUser(
    recipientId,
    '새로운 메시지',
    `${sender.username}: ${messageText.substring(0, 50)}...`,
    {
      type: 'message',
      conversationId: conversationId,
      fromUserId: senderId,
    }
  );
}
```

## 고급 기능

### 1. 예약 알림

```javascript
async function scheduleNotification(userId, title, message, data, scheduleTime) {
  const response = await axios.post(
    'https://onesignal.com/api/v1/notifications',
    {
      app_id: process.env.ONESIGNAL_APP_ID,
      include_external_user_ids: [userId],
      headings: { en: title, ko: title },
      contents: { en: message, ko: message },
      data: data,
      send_after: scheduleTime.toISOString(), // ISO 8601 format
    },
    {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${process.env.ONESIGNAL_REST_API_KEY}`,
      },
    }
  );

  return response.data;
}
```

### 2. 세그먼트 타겟팅

```javascript
// Send to premium users only
async function sendToPremiumUsers(title, message) {
  await notificationService.sendToSegment(
    [
      { field: 'tag', key: 'subscription', relation: '=', value: 'premium' }
    ],
    title,
    message,
    {}
  );
}

// Send to users interested in stocks
async function sendToStockInvestors(title, message) {
  await notificationService.sendToSegment(
    [
      { field: 'tag', key: 'interests', relation: 'contains', value: 'stocks' }
    ],
    title,
    message,
    {}
  );
}
```

### 3. A/B 테스트

```javascript
async function sendABTestNotification(userId, title, messageA, messageB) {
  const userGroup = Math.random() < 0.5 ? 'A' : 'B';
  const message = userGroup === 'A' ? messageA : messageB;

  await notificationService.sendToUser(
    userId,
    title,
    message,
    {
      ab_test_group: userGroup,
    }
  );
}
```

## 알림 설정 관리

### Database Schema

```sql
CREATE TABLE notification_settings (
  user_id VARCHAR(255) PRIMARY KEY,
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

### API Endpoint

```javascript
// GET /api/v1/users/:userId/notification-settings
router.get('/:userId/notification-settings', authenticateToken, async (req, res) => {
  const { userId } = req.params;

  const settings = await db.query(
    'SELECT * FROM notification_settings WHERE user_id = $1',
    [userId]
  );

  res.json(settings);
});

// PUT /api/v1/users/:userId/notification-settings
router.put('/:userId/notification-settings', authenticateToken, async (req, res) => {
  const { userId } = req.params;
  const settings = req.body;

  await db.query(
    'UPDATE notification_settings SET likes_enabled = $1, comments_enabled = $2, ... WHERE user_id = $3',
    [settings.likes_enabled, settings.comments_enabled, userId]
  );

  res.json({ success: true });
});
```

### Check Before Sending

```javascript
async function sendNotificationIfEnabled(userId, type, title, message, data) {
  // Check user's notification settings
  const settings = await db.query(
    'SELECT * FROM notification_settings WHERE user_id = $1',
    [userId]
  );

  const enabledMap = {
    'like': settings.likes_enabled,
    'comment': settings.comments_enabled,
    'follow': settings.follows_enabled,
    'message': settings.messages_enabled,
    'price_alert': settings.price_alerts_enabled,
  };

  if (enabledMap[type]) {
    await notificationService.sendToUser(userId, title, message, data);
  }
}
```

## 비용 및 제한

### OneSignal 무료 Tier
- **월 사용자**: 10,000명까지 무료
- **알림 수**: 무제한
- **API 호출**: 무제한
- **세그먼트**: 무제한

### OneSignal Paid Plans
- **Growth**: $9/월 (10,000명 이상)
- **Professional**: $99/월 (고급 기능)
- **Enterprise**: 커스텀 가격

### Rate Limits
- API 호출: 초당 50 requests
- 동시 발송: 한 번에 최대 10,000명

## 모니터링 및 분석

OneSignal Dashboard에서 확인 가능:
- 알림 전송 성공/실패율
- 오픈율 (Notification Open Rate)
- 클릭 쓰루율 (Click Through Rate)
- 디바이스 타입 분포
- 플랫폼별 성능

## 문제 해결

### iOS에서 알림이 오지 않는 경우
1. APNs 인증서 확인
2. Capabilities에서 Push Notifications 활성화 확인
3. 실제 기기에서 테스트 (시뮬레이터는 푸시 미지원)
4. 알림 권한 승인 확인

### Android에서 알림이 오지 않는 경우
1. Firebase Server Key 확인
2. AndroidManifest.xml 권한 확인
3. Google Play Services 설치 확인
4. 배터리 최적화 비활성화

### 백그라운드에서 알림이 작동하지 않는 경우
1. Background Modes 확인
2. OneSignal 초기화 코드 확인
3. 알림 클릭 핸들러 설정 확인

## 참고 자료

- [OneSignal Documentation](https://documentation.onesignal.com/)
- [OneSignal Flutter SDK](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [OneSignal REST API](https://documentation.onesignal.com/reference/create-notification)
- [OneSignal Dashboard](https://dashboard.onesignal.com/)

## Firebase vs OneSignal 비교

| 기능 | Firebase (FCM) | OneSignal |
|------|---------------|-----------|
| **비용** | 무료 | 10k 유저까지 무료 |
| **설정 복잡도** | 중간 | 쉬움 |
| **iOS 지원** | APNs 필요 | 내장 지원 |
| **Android 지원** | 기본 지원 | 기본 지원 |
| **웹 푸시** | 지원 | 지원 |
| **A/B 테스트** | 없음 | 지원 |
| **세그먼트** | 제한적 | 강력 |
| **분석** | 기본 | 상세 |
| **예약 발송** | 없음 | 지원 |
| **다국어** | 수동 | 자동 |
| **의존성** | Firebase 필수 | 독립 |
