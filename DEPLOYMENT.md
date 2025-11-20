# 배포 가이드 (Deployment Guide)

이 문서는 SNS 프로젝트의 모바일 앱(Android/iOS)과 웹 앱 배포 및 업데이트 가이드입니다.

## 목차

1. [React Native (모바일) 배포](#react-native-모바일-배포)
2. [Next.js (웹) 배포](#nextjs-웹-배포)
3. [버전 관리](#버전-관리)
4. [환경 변수 관리](#환경-변수-관리)
5. [CI/CD 설정](#cicd-설정)

---

## React Native (모바일) 배포

이 프로젝트는 Expo를 사용하므로 Expo의 빌드 시스템(EAS Build)를 활용합니다.

### 사전 준비

#### 1. Expo 계정 생성
```bash
# Expo 계정 생성 (https://expo.dev)
# EAS CLI 설치
npm install -g eas-cli

# EAS에 로그인
eas login
```

#### 2. 프로젝트 설정
```bash
cd mobile

# EAS 초기화
eas build:configure
```

이 명령은 `eas.json` 파일을 생성합니다:

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "android": {
        "buildType": "apk"
      }
    },
    "production": {
      "android": {
        "buildType": "apk"
      },
      "ios": {
        "autoIncrement": true
      }
    }
  },
  "submit": {
    "production": {}
  }
}
```

### Android 배포

#### 1. 개발/테스트 빌드 (APK)

```bash
# Preview 빌드 (내부 테스트용)
eas build --platform android --profile preview

# 빌드 완료 후 APK 다운로드 링크를 받습니다
# QR 코드를 스캔하거나 직접 설치 가능
```

#### 2. 프로덕션 빌드 (AAB)

Google Play Store에 업로드할 AAB 파일을 생성합니다.

```bash
# 프로덕션 빌드
eas build --platform android --profile production
```

**필요한 정보:**
- **Keystore**: 처음 빌드 시 EAS가 자동으로 생성하거나 기존 keystore 업로드
- **Package name**: `app.json`에서 설정 (예: `com.yourcompany.sns`)

#### 3. Google Play Console 설정

1. [Google Play Console](https://play.google.com/console) 접속
2. 새 앱 만들기
3. 앱 정보 입력 (이름, 설명, 스크린샷, 아이콘)
4. AAB 파일 업로드
5. 내부 테스트 → 비공개 테스트 → 공개 테스트 → 프로덕션 순으로 진행

#### 4. 자동 제출 (옵션)

```bash
# Google Play Store에 자동 제출
eas submit --platform android

# 또는 빌드와 동시에 제출
eas build --platform android --profile production --auto-submit
```

**필요한 정보:**
- Google Play Service Account JSON 키
- 앱 ID

### iOS 배포

#### 1. Apple Developer 계정 준비

- [Apple Developer Program](https://developer.apple.com/programs/) 가입 ($99/year)
- Bundle Identifier 등록 (예: `com.yourcompany.sns`)

#### 2. 개발/테스트 빌드

```bash
# 시뮬레이터용 빌드
eas build --platform ios --profile development

# TestFlight용 내부 테스트 빌드
eas build --platform ios --profile preview
```

#### 3. 프로덕션 빌드

```bash
# App Store용 프로덕션 빌드
eas build --platform ios --profile production
```

**EAS가 자동으로 처리:**
- Provisioning Profile 생성
- Distribution Certificate 관리
- App Store Connect API 연동

#### 4. App Store Connect 설정

1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. 새 앱 등록
3. 앱 정보 입력 (이름, 부제목, 설명, 키워드, 스크린샷)
4. TestFlight로 내부/외부 테스트
5. 앱 심사 제출

#### 5. 자동 제출 (옵션)

```bash
# App Store Connect에 자동 제출
eas submit --platform ios

# 또는 빌드와 동시에 제출
eas build --platform ios --profile production --auto-submit
```

**필요한 정보:**
- Apple ID
- App-specific password
- ASC API Key (권장)

### 동시 빌드 (Android + iOS)

```bash
# 두 플랫폼 동시 빌드
eas build --platform all --profile production
```

### OTA 업데이트 (Over-The-Air Updates)

코드 변경 시 앱 스토어 재심사 없이 업데이트 가능 (네이티브 코드 변경 제외):

```bash
# expo-updates 설치
npm install expo-updates

# 업데이트 배포
eas update --branch production --message "Bug fixes and improvements"

# 자동 업데이트 채널 설정
eas channel:create production
eas channel:edit production --branch production
```

**app.json 설정:**
```json
{
  "expo": {
    "updates": {
      "url": "https://u.expo.dev/[your-project-id]"
    },
    "runtimeVersion": {
      "policy": "sdkVersion"
    }
  }
}
```

### 버전 업데이트

#### app.json 수정
```json
{
  "expo": {
    "version": "1.0.1",
    "android": {
      "versionCode": 2
    },
    "ios": {
      "buildNumber": "2"
    }
  }
}
```

- **version**: 사용자에게 보이는 버전 (1.0.0, 1.0.1, 1.1.0)
- **versionCode** (Android): 정수로 증가 (1, 2, 3...)
- **buildNumber** (iOS): 빌드 번호 (1, 2, 3... 또는 1.0, 1.1)

---

## Next.js (웹) 배포

### 배포 플랫폼 옵션

1. **Vercel** (권장 - Next.js 제작사)
2. **Netlify**
3. **AWS Amplify**
4. **Docker + 클라우드 서버** (자체 호스팅)

### 1. Vercel 배포 (권장)

Vercel은 Next.js에 최적화되어 있으며 무료 플랜 제공:

#### 초기 설정

```bash
cd web-app

# Vercel CLI 설치
npm install -g vercel

# Vercel 로그인
vercel login

# 배포
vercel
```

#### 프로덕션 배포

```bash
# 프로덕션 배포
vercel --prod
```

#### GitHub 연동 (자동 배포)

1. [Vercel 대시보드](https://vercel.com/dashboard) 접속
2. "Import Project" 클릭
3. GitHub 저장소 선택
4. 환경 변수 설정
5. Deploy 클릭

**자동 배포 설정:**
- `main` 브랜치 푸시 → 프로덕션 배포
- 다른 브랜치 푸시 → 프리뷰 배포

#### 환경 변수 설정 (Vercel)

Vercel 대시보드에서:
1. Project Settings → Environment Variables
2. 다음 변수 추가:
   ```
   NEXT_PUBLIC_API_BASE_URL=https://your-api-server.com
   ```

### 2. Netlify 배포

```bash
# Netlify CLI 설치
npm install -g netlify-cli

# 로그인
netlify login

# 배포
netlify deploy

# 프로덕션 배포
netlify deploy --prod
```

#### netlify.toml 설정

```toml
[build]
  command = "npm run build"
  publish = ".next"

[[plugins]]
  package = "@netlify/plugin-nextjs"
```

### 3. Docker로 자체 호스팅

#### Dockerfile 생성

```dockerfile
FROM node:18-alpine AS base

# 의존성 설치
FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# 빌드
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# 프로덕션 이미지
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
```

#### next.config.js 수정

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
}

module.exports = nextConfig
```

#### Docker 빌드 및 실행

```bash
# 빌드
docker build -t sns-web-app .

# 실행
docker run -p 3000:3000 -e NEXT_PUBLIC_API_BASE_URL=https://your-api-server.com sns-web-app
```

### 4. AWS Amplify 배포

```bash
# Amplify CLI 설치
npm install -g @aws-amplify/cli

# 초기화
amplify init

# 호스팅 추가
amplify add hosting

# 배포
amplify publish
```

### 프로덕션 빌드 테스트

배포 전 로컬에서 프로덕션 빌드 테스트:

```bash
cd web-app

# 프로덕션 빌드
npm run build

# 프로덕션 서버 실행
npm start

# http://localhost:3000 에서 확인
```

### 성능 최적화 체크리스트

배포 전 확인사항:

- [ ] 이미지 최적화 (Next.js Image 컴포넌트 사용)
- [ ] 코드 스플리팅 확인
- [ ] 환경 변수 설정 확인
- [ ] API 엔드포인트 HTTPS 사용
- [ ] CORS 설정 확인
- [ ] 캐싱 전략 설정
- [ ] lighthouse 성능 점수 확인 (90+ 목표)

---

## 버전 관리

### Semantic Versioning (유의적 버전)

**버전 형식: MAJOR.MINOR.PATCH** (예: 1.2.3)

- **MAJOR**: 하위 호환성 없는 변경 (1.0.0 → 2.0.0)
- **MINOR**: 하위 호환성 있는 기능 추가 (1.0.0 → 1.1.0)
- **PATCH**: 하위 호환성 있는 버그 수정 (1.0.0 → 1.0.1)

### 버전 업데이트 전략

#### 모바일 앱 (React Native)

```bash
cd mobile

# package.json 버전 업데이트
npm version patch  # 1.0.0 → 1.0.1
npm version minor  # 1.0.0 → 1.1.0
npm version major  # 1.0.0 → 2.0.0

# app.json도 함께 업데이트
```

**app.json 자동 업데이트 스크립트 (package.json):**
```json
{
  "scripts": {
    "version:patch": "npm version patch && node scripts/update-app-version.js",
    "version:minor": "npm version minor && node scripts/update-app-version.js",
    "version:major": "npm version major && node scripts/update-app-version.js"
  }
}
```

**scripts/update-app-version.js:**
```javascript
const fs = require('fs');
const packageJson = require('../package.json');
const appJson = require('../app.json');

appJson.expo.version = packageJson.version;
appJson.expo.android.versionCode += 1;
appJson.expo.ios.buildNumber = String(parseInt(appJson.expo.ios.buildNumber) + 1);

fs.writeFileSync('./app.json', JSON.stringify(appJson, null, 2));
console.log(`Updated app version to ${packageJson.version}`);
```

#### 웹 앱 (Next.js)

```bash
cd web-app

# package.json 버전 업데이트
npm version patch
npm version minor
npm version major
```

### Git 태그 활용

버전 릴리즈 시 Git 태그 생성:

```bash
# 태그 생성
git tag -a v1.0.1 -m "Release version 1.0.1 - Bug fixes"

# 태그 푸시
git push origin v1.0.1

# 모든 태그 푸시
git push origin --tags
```

### CHANGELOG.md 관리

**CHANGELOG.md 예시:**
```markdown
# Changelog

## [1.0.1] - 2024-01-15

### Fixed
- 프로필 이미지 업로드 버그 수정
- 댓글 삭제 시 UI 업데이트 문제 해결

### Changed
- 피드 로딩 성능 개선

## [1.0.0] - 2024-01-01

### Added
- 초기 릴리즈
- 인증 시스템
- 게시물 CRUD
- 댓글/좋아요 기능
```

---

## 환경 변수 관리

### 환경별 설정

#### 개발 환경 (Development)
```env
# mobile/.env.development
API_BASE_URL=http://localhost:8080
ENV=development

# web-app/.env.development.local
NEXT_PUBLIC_API_BASE_URL=http://localhost:8080
NEXT_PUBLIC_ENV=development
```

#### 스테이징 환경 (Staging)
```env
# mobile/.env.staging
API_BASE_URL=https://staging-api.yourapp.com
ENV=staging

# web-app/.env.staging.local
NEXT_PUBLIC_API_BASE_URL=https://staging-api.yourapp.com
NEXT_PUBLIC_ENV=staging
```

#### 프로덕션 환경 (Production)
```env
# mobile/.env.production
API_BASE_URL=https://api.yourapp.com
ENV=production

# web-app/.env.production.local
NEXT_PUBLIC_API_BASE_URL=https://api.yourapp.com
NEXT_PUBLIC_ENV=production
```

### 모바일 앱 환경 변수 (Expo)

#### 1. EAS Secrets 사용 (권장)

```bash
# 시크릿 추가
eas secret:create --name API_BASE_URL --value https://api.yourapp.com --type string

# 시크릿 목록 확인
eas secret:list

# eas.json에서 사용
```

**eas.json:**
```json
{
  "build": {
    "production": {
      "env": {
        "API_BASE_URL": "https://api.yourapp.com"
      }
    }
  }
}
```

#### 2. app.config.js 활용

**app.config.js:**
```javascript
export default {
  expo: {
    name: process.env.ENV === 'production' ? 'SNS App' : 'SNS App (Dev)',
    extra: {
      apiBaseUrl: process.env.API_BASE_URL,
      env: process.env.ENV,
    },
  },
};
```

**코드에서 사용:**
```typescript
import Constants from 'expo-constants';

const API_BASE_URL = Constants.expoConfig?.extra?.apiBaseUrl;
```

### 웹 앱 환경 변수 (Next.js)

**환경 변수 접근:**
```typescript
// 클라이언트에서 접근 (NEXT_PUBLIC_ 접두사 필요)
const apiUrl = process.env.NEXT_PUBLIC_API_BASE_URL;

// 서버에서만 접근 (SSR, API Routes)
const secretKey = process.env.SECRET_KEY;
```

### 환경 변수 보안

**⚠️ 절대 커밋하지 말 것:**
- `.env.local`
- `.env.*.local`
- API 키, 시크릿 키
- 데이터베이스 비밀번호

**.gitignore에 추가:**
```gitignore
# Environment variables
.env
.env.local
.env.development.local
.env.staging.local
.env.production.local
.env.*.local
```

---

## CI/CD 설정

### GitHub Actions

이 프로젝트는 GitHub Actions를 사용하여 자동 빌드, 테스트, 배포를 수행합니다.

#### 워크플로우 파일 위치

모든 GitHub Actions 워크플로우는 `.github/workflows/` 디렉토리에 있습니다:

1. **`mobile-build.yml`** - 모바일 앱 빌드 및 배포
   - Lint, TypeScript 체크, 테스트
   - Android/iOS 프로덕션 빌드
   - OTA 업데이트 배포
   - 스토어 자동 제출 (옵션)

2. **`web-deploy.yml`** - 웹 앱 배포
   - Lint, TypeScript 체크, 테스트
   - Next.js 빌드
   - Vercel/Netlify 배포
   - Lighthouse 성능 체크

3. **`pr-checks.yml`** - Pull Request 검증
   - PR 제목 형식 검증 (Conventional Commits)
   - 의존성 보안 취약점 검사
   - 민감한 파일 체크 (.env 등)
   - 번들 사이즈 체크

4. **`release.yml`** - 자동 릴리즈
   - Git 태그 생성
   - GitHub Release 생성
   - Changelog 자동 생성
   - Slack 알림 (옵션)

5. **`codeql.yml`** - 보안 스캔
   - CodeQL 정적 분석
   - 매주 월요일 자동 실행

#### GitHub Secrets 설정 가이드

GitHub 저장소 **Settings → Secrets and variables → Actions**에서 다음 시크릿을 추가하세요:

##### 필수 Secrets

**모바일 앱 관련:**
- `EXPO_TOKEN`
  - 설명: Expo 액세스 토큰
  - 발급: https://expo.dev/accounts/[username]/settings/access-tokens
  - 생성: "Create Token" → 이름 입력 → 토큰 복사

**웹 앱 관련 (Vercel):**
- `VERCEL_TOKEN`
  - 설명: Vercel 인증 토큰
  - 발급: https://vercel.com/account/tokens
  - 생성: "Create" → 이름 입력 → 토큰 복사

- `VERCEL_ORG_ID`
  - 설명: Vercel 조직 ID
  - 확인: 프로젝트 Settings → General → "Project ID" 섹션의 "Your ID"
  - 또는 `.vercel/project.json` 파일의 `orgId` 값

- `VERCEL_PROJECT_ID`
  - 설명: Vercel 프로젝트 ID
  - 확인: 프로젝트 Settings → General → "Project ID"
  - 또는 `.vercel/project.json` 파일의 `projectId` 값

**API 관련:**
- `API_BASE_URL`
  - 설명: 백엔드 API 서버 URL
  - 예시: `https://api.yourdomain.com`
  - 환경별로 다를 수 있음 (production/staging)

##### 선택 Secrets

**Netlify 사용 시:**
- `NETLIFY_SITE_ID`: Netlify 사이트 ID
- `NETLIFY_AUTH_TOKEN`: Netlify 인증 토큰

**Slack 알림:**
- `SLACK_WEBHOOK_URL`: Slack Incoming Webhook URL
  - 발급: Slack Workspace → Apps → Incoming Webhooks 활성화

**앱 스토어 자동 제출 (고급):**
- `APPLE_ID`: Apple Developer 계정 이메일
- `APPLE_APP_SPECIFIC_PASSWORD`: App-specific password
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: Google Play 서비스 계정 JSON (base64 인코딩)

#### Secrets 추가 방법

1. GitHub 저장소 페이지에서 **Settings** 탭 클릭
2. 왼쪽 메뉴에서 **Secrets and variables → Actions** 클릭
3. **New repository secret** 버튼 클릭
4. Secret 이름과 값을 입력
5. **Add secret** 버튼 클릭

#### 워크플로우 활성화

워크플로우 파일을 `main` 브랜치에 푸시하면 자동으로 활성화됩니다:

```bash
git add .github/workflows/
git commit -m "ci: GitHub Actions 워크플로우 추가"
git push origin main
```

**Actions** 탭에서 워크플로우 실행 상태를 확인할 수 있습니다.

---

## 배포 체크리스트

### 모바일 앱 (첫 배포)

#### Android
- [ ] Google Play Developer 계정 생성 ($25 일회성)
- [ ] 앱 아이콘 및 스크린샷 준비 (다양한 화면 크기)
- [ ] 앱 설명 및 키워드 작성
- [ ] 개인정보 처리방침 URL 준비
- [ ] 연령 등급 설정
- [ ] 내부 테스트 진행
- [ ] 비공개/공개 테스트 진행
- [ ] 프로덕션 출시

#### iOS
- [ ] Apple Developer Program 가입 ($99/년)
- [ ] Bundle Identifier 등록
- [ ] 앱 아이콘 및 스크린샷 준비 (다양한 디바이스)
- [ ] 앱 설명 및 키워드 작성
- [ ] 개인정보 처리방침 URL 준비
- [ ] TestFlight 내부 테스트
- [ ] TestFlight 외부 테스트
- [ ] App Store 심사 제출 (평균 24-48시간)

### 웹 앱 (첫 배포)

- [ ] 도메인 구매 및 설정
- [ ] SSL 인증서 설정 (Vercel/Netlify는 자동)
- [ ] 환경 변수 설정 확인
- [ ] API CORS 설정 확인
- [ ] 성능 테스트 (Lighthouse)
- [ ] SEO 메타 태그 설정
- [ ] robots.txt, sitemap.xml 생성
- [ ] Google Analytics 설정 (옵션)
- [ ] 에러 트래킹 설정 (Sentry 등)

### 공통

- [ ] 백엔드 API 서버 배포 및 테스트
- [ ] 데이터베이스 백업 설정
- [ ] 모니터링 시스템 구축
- [ ] 장애 대응 계획 수립
- [ ] 사용자 피드백 수집 채널 준비

---

## 업데이트 배포

### 마이너 업데이트 (버그 수정, 작은 기능 추가)

#### 모바일
```bash
# 1. 코드 수정
# 2. 버전 업데이트
npm run version:patch

# 3. OTA 업데이트 (네이티브 코드 변경 없을 경우)
eas update --branch production --message "Bug fixes"

# 4. 전체 빌드 (네이티브 코드 변경 시)
eas build --platform all --profile production --auto-submit
```

#### 웹
```bash
# 1. 코드 수정
# 2. Git 푸시 (자동 배포)
git push origin main

# 또는 수동 배포
vercel --prod
```

### 메이저 업데이트 (대규모 기능 추가)

1. **베타 테스트 진행**
   - 모바일: TestFlight / 내부 테스트
   - 웹: 스테이징 환경 배포

2. **버전 업데이트**
   ```bash
   npm run version:major  # 2.0.0
   ```

3. **변경 사항 문서화**
   - CHANGELOG.md 업데이트
   - 릴리즈 노트 작성

4. **배포 및 모니터링**
   - 점진적 롤아웃 (10% → 50% → 100%)
   - 에러율 모니터링
   - 사용자 피드백 수집

---

## 롤백 전략

### 모바일 앱

#### OTA 업데이트 롤백
```bash
# 이전 업데이트로 롤백
eas update:republish --branch production --group [previous-update-id]
```

#### 앱 스토어 버전 롤백
- 새 버전으로 긴급 패치 릴리즈 (앱 스토어는 이전 버전으로 롤백 불가)

### 웹 앱

#### Vercel
- Vercel 대시보드에서 이전 배포로 롤백 (클릭 한 번)

#### Docker
```bash
# 이전 이미지로 재배포
docker run -p 3000:3000 sns-web-app:[previous-tag]
```

---

## 모니터링 및 분석

### 추천 도구

#### 에러 트래킹
- **Sentry**: 실시간 에러 모니터링
  ```bash
  npm install @sentry/react-native @sentry/nextjs
  ```

#### 성능 모니터링
- **Firebase Performance Monitoring**
- **New Relic**
- **Datadog**

#### 분석
- **Google Analytics**
- **Mixpanel**
- **Amplitude**

### 핵심 지표 (KPI)

모니터링할 주요 지표:
- **Crash-free rate**: 99.9% 이상 목표
- **App load time**: 2초 이내
- **API response time**: 500ms 이내
- **Daily Active Users (DAU)**
- **Monthly Active Users (MAU)**
- **Retention rate**: 1일/7일/30일

---

## 참고 자료

### 공식 문서
- [Expo EAS Build](https://docs.expo.dev/build/introduction/)
- [Expo EAS Submit](https://docs.expo.dev/submit/introduction/)
- [Expo Updates](https://docs.expo.dev/eas-update/introduction/)
- [Next.js Deployment](https://nextjs.org/docs/deployment)
- [Vercel Deployment](https://vercel.com/docs)

### 스토어 가이드
- [Google Play Console](https://developer.android.com/distribute/console)
- [App Store Connect](https://developer.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### CI/CD
- [GitHub Actions for Expo](https://docs.expo.dev/build/building-on-ci/)
- [GitHub Actions for Next.js](https://github.com/vercel/next.js/tree/canary/examples/with-github-actions)

---

## 문의 및 지원

배포 과정에서 문제가 발생하면:
1. 해당 플랫폼 공식 문서 확인
2. 커뮤니티 포럼 검색 (Expo Forums, Stack Overflow)
3. GitHub Issues 확인
4. 프로젝트 관리자에게 문의
