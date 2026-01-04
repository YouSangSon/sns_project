# 로컬 개발 환경 가이드

이 문서는 SNS App을 로컬 환경에서 개발하고 테스트하기 위한 완전한 가이드입니다.

## 📋 목차

1. [사전 준비](#사전-준비)
2. [환경 설정](#환경-설정)
3. [프로젝트 설치](#프로젝트-설치)
4. [백엔드 설정](#백엔드-설정)
5. [앱 실행](#앱-실행)
6. [테스트](#테스트)
7. [트러블슈팅](#트러블슈팅)

---

## 🔧 사전 준비

### 필수 요구사항

- **Flutter SDK**: 3.2.0 이상
- **Dart SDK**: 3.2.0 이상
- **Git**: 최신 버전
- **IDE**: VS Code 또는 Android Studio
- **Chrome**: 웹 개발용 (최신 버전)

### 선택 사항

- **Android Studio**: Android 앱 개발 시
- **Xcode**: iOS 앱 개발 시 (macOS 전용)
- **Docker**: 백엔드 서버 실행 시
- **Node.js**: Mock 서버 실행 시

### Flutter 설치 확인

```bash
flutter doctor -v
```

모든 항목이 체크되어야 합니다. 문제가 있다면 [Flutter 공식 문서](https://flutter.dev/docs/get-started/install)를 참고하세요.

---

## ⚙️ 환경 설정

### YAML 기반 환경 설정

이 프로젝트는 `.env` 파일 대신 **YAML 파일**로 환경을 관리합니다.

#### 환경 파일 구조

```
flutter_app/
└── config/
    ├── dev.yaml        # 개발 환경
    ├── staging.yaml    # 스테이징 환경
    └── prod.yaml       # 프로덕션 환경
```

#### 환경 파일 수정

**개발 환경** (`config/dev.yaml`)을 열어 필요한 설정을 수정하세요:

```yaml
# 개발 환경 설정
environment: development

# API Configuration
api:
  base_url: http://localhost:8080  # 백엔드 서버 URL
  connection_timeout: 30
  receive_timeout: 30
  enable_logging: true

# Supabase (사용하는 경우)
supabase:
  url: http://localhost:54321
  anon_key: your-supabase-anon-key-here
  service_role_key: your-supabase-service-role-key-here

# Feature Flags
features:
  enable_analytics: false
  enable_crash_reporting: false
  enable_debug_menu: true
  enable_mock_data: true  # Mock 데이터 사용 여부
```

#### 환경별 실행 방법

환경은 `--dart-define` 플래그로 지정합니다:

```bash
# 개발 환경 (기본값)
flutter run

# 개발 환경 (명시적)
flutter run --dart-define=ENV=dev

# 스테이징 환경
flutter run --dart-define=ENV=staging

# 프로덕션 환경
flutter run --dart-define=ENV=prod
```

---

## 📦 프로젝트 설치

### 1. 저장소 클론

```bash
git clone https://github.com/YouSangSon/sns_project.git
cd sns_project/flutter_app
```

### 2. 의존성 설치

```bash
# 패키지 설치
flutter pub get

# 코드 생성 (freezed, json_serializable, riverpod)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Assets 확인

이미지 및 아이콘 assets이 있는지 확인:

```bash
mkdir -p assets/images
mkdir -p assets/icons
```

---

## 🖥️ 백엔드 설정

로컬에서 앱을 테스트하려면 백엔드 서버가 필요합니다. 세 가지 옵션이 있습니다:

### 옵션 1: Mock 데이터 사용 (추천 - 빠른 시작)

가장 간단한 방법입니다. 백엔드 없이 앱을 실행할 수 있습니다.

1. **`config/dev.yaml`에서 Mock 데이터 활성화:**

```yaml
features:
  enable_mock_data: true
```

2. **앱 실행:** Mock 데이터로 바로 테스트 가능

```bash
flutter run -d chrome
```

> **참고**: Mock 데이터는 개발 중 UI를 빠르게 테스트할 때 유용합니다.

### 옵션 2: Supabase 사용 (추천 - 실전 테스트)

Supabase는 무료로 시작할 수 있는 백엔드 서비스입니다.

#### 2-1. Supabase 프로젝트 생성

1. [Supabase](https://supabase.com)에 가입
2. 새 프로젝트 생성
3. Database 비밀번호 설정

#### 2-2. 로컬 Supabase 실행 (선택사항)

Docker로 로컬에서 Supabase를 실행할 수 있습니다:

```bash
# Supabase CLI 설치
npm install -g supabase

# 프로젝트 초기화
cd sns_project
supabase init

# 로컬 Supabase 시작
supabase start
```

시작되면 다음 정보가 표시됩니다:

```
API URL: http://localhost:54321
anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 2-3. 환경 설정 업데이트

`config/dev.yaml` 파일에 Supabase 정보 입력:

```yaml
supabase:
  url: http://localhost:54321  # 로컬 Supabase
  # 또는: https://your-project.supabase.co  # 클라우드 Supabase
  anon_key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  service_role_key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

자세한 설정은 [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)를 참고하세요.

### 옵션 3: Kotlin/Spring Boot 백엔드 실행

자체 백엔드 서버를 실행하려면:

1. **백엔드 저장소 클론:**

```bash
git clone https://github.com/YouSangSon/rest_server.git
cd rest_server
```

2. **PostgreSQL 실행:**

Docker로 PostgreSQL 실행:

```bash
docker run --name sns-postgres \
  -e POSTGRES_DB=snsdb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  -d postgres:15
```

3. **백엔드 서버 실행:**

```bash
./gradlew bootRun
```

서버가 `http://localhost:8080`에서 실행됩니다.

4. **환경 설정 확인:**

`config/dev.yaml`:

```yaml
api:
  base_url: http://localhost:8080
```

---

## 🚀 앱 실행

### 웹 (Chrome)

가장 빠른 개발 환경:

```bash
flutter run -d chrome
```

또는 핫 리로드를 위한 개발 서버:

```bash
flutter run -d chrome --web-port 8000
```

### Android

에뮬레이터 또는 실제 디바이스:

```bash
# 에뮬레이터 시작
flutter emulators --launch <emulator_id>

# 앱 실행
flutter run -d android
```

### iOS (macOS 전용)

```bash
# 시뮬레이터 실행
open -a Simulator

# 앱 실행
flutter run -d ios
```

### 연결된 디바이스 확인

```bash
flutter devices
```

---

## 🧪 테스트

### 단위 테스트

```bash
# 모든 테스트 실행
flutter test

# 특정 테스트 실행
flutter test test/features/auth/domain/usecases/login_usecase_test.dart

# 커버리지 포함
flutter test --coverage

# 커버리지 리포트 생성 (macOS/Linux)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 위젯 테스트

```bash
flutter test test/features/auth/presentation/pages/login_page_test.dart
```

### 통합 테스트

```bash
flutter test integration_test/app_test.dart
```

### 테스트 계정

개발 환경에서 사용할 테스트 계정:

```
이메일: test@example.com
비밀번호: Test123!@#
사용자명: testuser
```

---

## 🔨 개발 워크플로우

### 코드 생성

Entity, Model 등을 변경한 후:

```bash
# 일회성 빌드
flutter pub run build_runner build --delete-conflicting-outputs

# 감시 모드 (파일 변경 시 자동 생성)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 린트 및 포맷팅

```bash
# 코드 분석
flutter analyze

# 코드 포맷팅
dart format lib/ test/

# 포맷팅 확인만
dart format --output=none --set-exit-if-changed lib/
```

### 빌드

```bash
# 웹 빌드
flutter build web --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS 필요)
flutter build ios --release
```

---

## 🐛 트러블슈팅

### 1. "EnvConfig가 초기화되지 않았습니다" 오류

**원인**: `EnvConfig.initialize()`가 호출되지 않음

**해결**:
- `main.dart`에서 `EnvConfig.initialize()`가 먼저 호출되는지 확인
- config yaml 파일이 `pubspec.yaml`의 assets에 등록되어 있는지 확인

### 2. "Failed to load config file" 오류

**원인**: config yaml 파일을 찾을 수 없음

**해결**:
```bash
# assets 확인
ls -la flutter_app/config/

# pubspec.yaml 확인
cat flutter_app/pubspec.yaml | grep -A 5 assets

# 패키지 재설치
flutter clean
flutter pub get
```

### 3. 백엔드 연결 오류 (Network Error)

**원인**: 백엔드 서버가 실행되지 않았거나 URL이 잘못됨

**해결**:
```bash
# 백엔드 서버 확인
curl http://localhost:8080/health

# config/dev.yaml의 base_url 확인
cat flutter_app/config/dev.yaml | grep base_url

# Mock 데이터 모드로 전환 (임시)
# config/dev.yaml에서 enable_mock_data: true
```

### 4. 코드 생성 오류

**원인**: `build_runner`가 실행되지 않았거나 freezed 어노테이션 오류

**해결**:
```bash
# 캐시 정리 후 재생성
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Hot Reload가 작동하지 않음

**해결**:
```bash
# 앱 재시작 (r 키)
r

# Hot Restart (R 키)
R

# 완전 재빌드
flutter run
```

---

## 📚 추가 문서

- [아키텍처 가이드](./ARCHITECTURE.md)
- [API 엔드포인트](./API_ENDPOINTS.md)
- [Supabase 설정](./SUPABASE_SETUP.md)
- [배포 가이드](./DEPLOYMENT.md)
- [보안 가이드](./SECURITY.md)

---

## 💡 개발 팁

### 1. 환경별 테스트

각 환경에서 앱이 제대로 작동하는지 확인:

```bash
# 개발 환경
flutter run --dart-define=ENV=dev

# 스테이징 환경
flutter run --dart-define=ENV=staging

# 프로덕션 환경 (주의!)
flutter run --dart-define=ENV=prod
```

### 2. 빠른 개발을 위한 설정

**VS Code 설정** (`.vscode/launch.json`):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Dev)",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=ENV=dev"]
    },
    {
      "name": "Flutter (Staging)",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=ENV=staging"]
    }
  ]
}
```

### 3. 디버그 메뉴 활용

개발 환경에서는 디버그 메뉴가 활성화됩니다:

- 환경 정보 확인
- Mock 데이터 토글
- API 로그 확인
- 캐시 클리어

앱 우측 상단의 디버그 아이콘을 클릭하세요.

### 4. 로그 확인

```dart
// EnvConfig 정보 출력
EnvConfig.instance.printConfig();

// 개발 모드에서만 로그 출력
if (EnvConfig.instance.isDevelopment) {
  print('Debug: API request sent');
}
```

---

## 🤝 기여하기

1. Feature 브랜치 생성: `git checkout -b feature/amazing-feature`
2. 변경사항 커밋: `git commit -m 'feat: Add amazing feature'`
3. 브랜치 푸시: `git push origin feature/amazing-feature`
4. Pull Request 생성

---

**Happy Coding! 🚀**
