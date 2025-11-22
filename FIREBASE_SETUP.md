# Firebase Cloud Messaging (FCM) 설정 가이드

SNS 앱에서 푸시 알림을 사용하기 위한 Firebase 설정 방법입니다.

## 📱 사전 준비

- Firebase 계정 (무료)
- Expo 계정 (푸시 알림 서비스 사용)
- Android/iOS 프로젝트 설정 완료

## 🔥 Firebase 프로젝트 생성

### 1. Firebase 콘솔에서 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. **"프로젝트 추가"** 클릭
3. 프로젝트 이름 입력 (예: `sns-app`)
4. Google Analytics 설정 (선택사항)
5. 프로젝트 생성 완료

### 2. Android 앱 추가

1. Firebase 콘솔에서 프로젝트 선택
2. **Android 아이콘** 클릭
3. 패키지 이름 입력:
   ```
   com.yourcompany.snsapp
   ```
   > ⚠️ `app.json`의 `android.package`와 동일해야 합니다
4. **앱 등록** 클릭
5. `google-services.json` 다운로드
6. 파일을 `mobile/` 폴더에 저장

### 3. iOS 앱 추가

1. Firebase 콘솔에서 **iOS 아이콘** 클릭
2. 번들 ID 입력:
   ```
   com.yourcompany.snsapp
   ```
   > ⚠️ `app.json`의 `ios.bundleIdentifier`와 동일해야 합니다
3. **앱 등록** 클릭
4. `GoogleService-Info.plist` 다운로드
5. 파일을 `mobile/` 폴더에 저장

## 📝 Expo 프로젝트 설정

### 1. app.json 업데이트

```json
{
  "expo": {
    "name": "SNS App",
    "slug": "sns-app",
    "version": "1.0.0",
    "android": {
      "package": "com.yourcompany.snsapp",
      "googleServicesFile": "./google-services.json",
      "permissions": [
        "NOTIFICATIONS",
        "VIBRATE"
      ]
    },
    "ios": {
      "bundleIdentifier": "com.yourcompany.snsapp",
      "googleServicesFile": "./GoogleService-Info.plist",
      "infoPlist": {
        "UIBackgroundModes": [
          "remote-notification"
        ]
      }
    },
    "plugins": [
      [
        "expo-notifications",
        {
          "icon": "./assets/notification-icon.png",
          "color": "#007AFF",
          "sounds": ["./assets/notification-sound.wav"],
          "mode": "production"
        }
      ]
    ]
  }
}
```

### 2. Firebase 서버 키 가져오기

1. Firebase 콘솔에서 프로젝트 선택
2. **⚙️ 프로젝트 설정** > **클라우드 메시징**
3. **서버 키** 복사 (FCM Token)
4. 환경 변수에 저장:

```env
# .env.development
FIREBASE_SERVER_KEY=your-firebase-server-key
```

### 3. Expo 프로젝트 ID 가져오기

1. Expo 웹사이트에 로그인
2. 프로젝트 선택
3. 프로젝트 ID 복사
4. `notificationService.ts` 파일에서 업데이트:

```typescript
const tokenData = await Notifications.getExpoPushTokenAsync({
  projectId: 'your-expo-project-id', // 여기에 실제 프로젝트 ID 입력
});
```

## 🔔 알림 타입별 설정

### Android 알림 채널

알림은 다음 채널로 분류됩니다:

- **default**: 일반 알림
- **likes**: 좋아요 알림
- **comments**: 댓글 알림
- **follows**: 팔로우 알림
- **messages**: 메시지 알림 (우선순위 높음)

각 채널은 다른 소리, 진동 패턴, 중요도를 가집니다.

### iOS 알림 권한

iOS에서는 사용자가 알림 권한을 허용해야 푸시 알림을 받을 수 있습니다.

앱 첫 실행 시 권한 요청 팝업이 표시됩니다.

## 📡 백엔드 통합

### 1. 푸시 토큰 저장

사용자가 로그인하면 푸시 토큰을 서버에 저장합니다:

```typescript
// 로그인 후
const { pushToken } = useNotifications();

if (pushToken) {
  await apiClient.post('/users/push-token', { token: pushToken });
}
```

### 2. 서버에서 푸시 알림 발송

#### Expo Push API 사용 (권장)

```javascript
// Node.js 백엔드 예시
const { Expo } = require('expo-server-sdk');
const expo = new Expo();

async function sendPushNotification(pushToken, title, body, data) {
  const messages = [{
    to: pushToken,
    sound: 'default',
    title: title,
    body: body,
    data: data,
  }];

  const chunks = expo.chunkPushNotifications(messages);

  for (let chunk of chunks) {
    try {
      const ticketChunk = await expo.sendPushNotificationsAsync(chunk);
      console.log(ticketChunk);
    } catch (error) {
      console.error(error);
    }
  }
}

// 사용 예시
await sendPushNotification(
  userPushToken,
  '새 좋아요',
  'John님이 게시물을 좋아합니다',
  { type: 'like', postId: '123' }
);
```

#### Firebase Admin SDK 사용

```javascript
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function sendFCMNotification(fcmToken, title, body, data) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data,
    token: fcmToken,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
  } catch (error) {
    console.error('Error sending message:', error);
  }
}
```

## 🧪 테스트

### 1. 로컬 알림 테스트

```typescript
import { notificationService } from './services/notificationService';

// 즉시 알림 표시
await notificationService.showLocalNotification(
  '테스트 알림',
  '이것은 테스트 알림입니다',
  { type: 'test' }
);
```

### 2. Expo Push Tool로 테스트

1. [Expo Push Notification Tool](https://expo.dev/notifications) 접속
2. 푸시 토큰 입력
3. 메시지 작성 후 전송

## 📊 알림 데이터 구조

### 알림 타입별 데이터

```typescript
// 좋아요 알림
{
  type: 'like',
  postId: 'post-id',
  userId: 'user-id',
  username: 'username'
}

// 댓글 알림
{
  type: 'comment',
  postId: 'post-id',
  commentId: 'comment-id',
  userId: 'user-id',
  username: 'username'
}

// 팔로우 알림
{
  type: 'follow',
  userId: 'user-id',
  username: 'username'
}

// 메시지 알림
{
  type: 'message',
  conversationId: 'conversation-id',
  senderId: 'user-id',
  senderName: 'username'
}
```

## 🔒 보안 고려사항

1. **서버 키 보호**: Firebase 서버 키를 절대 클라이언트에 노출하지 마세요
2. **토큰 갱신**: 푸시 토큰은 변경될 수 있으므로 주기적으로 업데이트하세요
3. **권한 확인**: 알림 전송 전 사용자 권한을 확인하세요
4. **스팸 방지**: 과도한 알림 발송을 방지하는 로직을 구현하세요

## 📱 플랫폼별 주의사항

### Android

- **채널**: Android 8.0 이상에서는 알림 채널이 필수입니다
- **아이콘**: 투명 배경의 흰색 아이콘이 권장됩니다
- **소리**: 커스텀 소리는 `assets/sounds/` 폴더에 저장

### iOS

- **Certificate**: APNs 인증서가 필요합니다 (Expo가 자동 처리)
- **배지**: 앱 아이콘에 배지 카운트 표시 가능
- **조용한 알림**: Background fetch를 위한 silent notification 지원

## ⚙️ 고급 설정

### 알림 스케줄링

```typescript
// 특정 시간에 알림 예약
await Notifications.scheduleNotificationAsync({
  content: {
    title: "예약 알림",
    body: "5초 후에 표시됩니다",
  },
  trigger: {
    seconds: 5,
  },
});

// 매일 반복 알림
await Notifications.scheduleNotificationAsync({
  content: {
    title: "일일 알림",
    body: "매일 오전 9시에 표시됩니다",
  },
  trigger: {
    hour: 9,
    minute: 0,
    repeats: true,
  },
});
```

### 알림 액션 버튼

```typescript
await Notifications.setNotificationCategoryAsync('message', [
  {
    identifier: 'reply',
    buttonTitle: '답장',
    options: {
      opensAppToForeground: true,
    },
  },
  {
    identifier: 'dismiss',
    buttonTitle: '무시',
    options: {
      isDestructive: true,
    },
  },
]);
```

## 🐛 문제 해결

### 알림이 표시되지 않는 경우

1. **권한 확인**: 설정에서 알림 권한이 허용되어 있는지 확인
2. **토큰 확인**: 푸시 토큰이 올바르게 생성되었는지 확인
3. **실제 기기**: 에뮬레이터/시뮬레이터가 아닌 실제 기기에서 테스트
4. **앱 상태**: 앱이 종료된 상태에서도 테스트

### 앱이 foreground일 때 알림이 표시되지 않는 경우

`setNotificationHandler`에서 `shouldShowAlert: true`로 설정했는지 확인:

```typescript
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true, // 이 값이 true여야 합니다
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});
```

## 📚 참고 자료

- [Expo Notifications Documentation](https://docs.expo.dev/versions/latest/sdk/notifications/)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Expo Push Notifications](https://docs.expo.dev/push-notifications/overview/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

---

Made with ❤️ for SNS App
