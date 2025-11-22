# Sentry 설정 가이드

SNS 앱에서 에러 모니터링 및 성능 추적을 위한 Sentry 설정 방법입니다.

## 📊 Sentry 프로젝트 생성

1. [Sentry](https://sentry.io/)에 가입
2. 새 프로젝트 생성 (Next.js, React Native 각각)
3. DSN 키 복사

## 🌐 Web (Next.js) 설정

### 1. 패키지 설치

```bash
cd web-app
npm install @sentry/nextjs
```

### 2. Sentry 초기화

```bash
npx @sentry/wizard@latest -i nextjs
```

### 3. 환경 변수 설정

```env
# .env.local
NEXT_PUBLIC_SENTRY_DSN=https://your-dsn@sentry.io/your-project-id
SENTRY_AUTH_TOKEN=your-auth-token
```

### 4. 수동 설정 (선택사항)

`sentry.client.config.ts`:
```typescript
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 1.0,
  environment: process.env.NODE_ENV,
  enabled: process.env.NODE_ENV === 'production',
});
```

`sentry.server.config.ts`:
```typescript
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 1.0,
  environment: process.env.NODE_ENV,
  enabled: process.env.NODE_ENV === 'production',
});
```

## 📱 Mobile (React Native / Expo) 설정

### 1. 패키지 설치

```bash
cd mobile
npm install @sentry/react-native sentry-expo
```

### 2. app.json 설정

```json
{
  "expo": {
    "hooks": {
      "postPublish": [
        {
          "file": "sentry-expo/upload-sourcemaps",
          "config": {
            "organization": "your-org",
            "project": "your-project",
            "authToken": "your-auth-token"
          }
        }
      ]
    }
  }
}
```

### 3. Sentry 초기화

`App.tsx`:
```typescript
import * as Sentry from 'sentry-expo';

Sentry.init({
  dsn: 'https://your-dsn@sentry.io/your-project-id',
  enableInExpoDevelopment: false,
  debug: false,
  tracesSampleRate: 1.0,
});
```

## 🎯 사용 예시

### 에러 캡처

```typescript
try {
  // 에러가 발생할 수 있는 코드
  throw new Error('Something went wrong');
} catch (error) {
  Sentry.captureException(error);
}
```

### 커스텀 이벤트

```typescript
Sentry.captureMessage('Custom event', 'info');
```

### 사용자 정보 설정

```typescript
Sentry.setUser({
  id: user.id,
  username: user.username,
  email: user.email,
});
```

### 성능 추적

```typescript
const transaction = Sentry.startTransaction({
  name: 'User Login',
});

// ... 로그인 로직 ...

transaction.finish();
```

## 📈 주요 기능

- ✅ 에러 모니터링
- ✅ 성능 추적 (Performance Monitoring)
- ✅ 사용자 세션 재생
- ✅ 릴리스 추적
- ✅ Source Maps 업로드
- ✅ 알림 설정 (Slack, Email)

---

Made with ❤️ for SNS App
