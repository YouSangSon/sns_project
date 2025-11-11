# UI 미리보기 가이드

현재 구현된 세련된 UI를 확인하는 방법입니다.

## 🚀 방법 1: 로컬에서 실행 (권장)

### Flutter가 설치된 경우

```bash
# 1. 프로젝트 디렉토리로 이동
cd /path/to/sns_project

# 2. 패키지 설치
flutter pub get

# 3. 웹에서 실행 (가장 빠름)
flutter run -d chrome

# 또는 Android 에뮬레이터
flutter run -d android

# 또는 iOS 시뮬레이터 (macOS only)
flutter run -d ios
```

### Flutter가 없는 경우

1. **Flutter 설치**: https://docs.flutter.dev/get-started/install
2. 위 명령어 실행

---

## 🎨 방법 2: UI 설명서

### 로그인 화면 (login_screen.dart)

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│         ╔═══════════════╗          │
│         ║    ✨ (아이콘)  ║          │  ← 그라데이션 로고 (보라색)
│         ║               ║          │    100x100, 둥근 모서리 28px
│         ╚═══════════════╝          │    부드러운 그림자
│                                     │
│        Welcome Back                 │  ← 큰 헤더 (32px, 굵게)
│        Sign in to continue          │  ← 부제목 (16px, 회색)
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 📧  Email                     │ │  ← 그라데이션 아이콘
│  │     Enter your email          │ │    둥근 Input (16px radius)
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🔒  Password            👁️    │ │  ← 그라데이션 아이콘
│  │     Enter your password       │ │    비밀번호 토글
│  └───────────────────────────────┘ │
│                                     │
│  ╔═══════════════════════════════╗ │
│  ║                               ║ │  ← 그라데이션 버튼
│  ║         Log In                ║ │    높이 56px, 그림자
│  ╚═══════════════════════════════╝ │
│                                     │
│  ──────────  OR  ──────────        │  ← 구분선
│                                     │
│  ┌───────────────────────────────┐ │
│  │ [G] Continue with Google      │ │  ← 외곽선 버튼
│  └───────────────────────────────┘ │
│                                     │
│   Don't have an account? Sign Up   │  ← Sign Up은 그라데이션
│                                     │
└─────────────────────────────────────┘
```

### 색상 팔레트

```
Primary (보라색):     #6C63FF  ████████
Secondary (핑크):     #FF6584  ████████
Accent (청록):       #4ECDC4  ████████
Success (민트):      #95E1D3  ████████
Warning (코랄):      #F38181  ████████

배경 (라이트):       #FAFAFA  ████████
카드 (라이트):       #FFFFFF  ████████
텍스트 (라이트):     #2D3436  ████████

배경 (다크):         #0D0D0D  ████████
카드 (다크):         #262626  ████████
텍스트 (다크):       #F5F5F5  ████████
```

### 그라데이션

**Modern Gradient (보라색)**
```
┌──────────────────┐
│ #6C63FF          │  ← 시작
│   ↘              │
│      #8E79FF     │  ← 중간
│         ↘        │
│            #B08F │  ← 끝
└──────────────────┘
```

**Instagram Gradient**
```
┌──────────────────┐
│ 🟣 → 💜 → 💗 → 🔴 │
│ 보라→자주→핑크→빨강│
└──────────────────┘
```

### 디자인 특징

#### 1. **둥근 모서리**
- 로고: 28px
- 카드: 20px
- 버튼: 16px
- Input: 16px

#### 2. **그림자 효과**
```
Card Shadow:
- 흐림: 20px
- 오프셋: (0, 10px)
- 투명도: 10%

Button Shadow:
- 흐림: 12px
- 오프셋: (0, 6px)
- 색상: Primary의 30%
```

#### 3. **애니메이션**
- Fade-in: 1200ms
- 곡선: easeOutCubic
- 로고 스케일: 0 → 1
- 투명도: 0 → 1

#### 4. **타이포그래피**
```
폰트: Inter (Google Fonts)

헤더 Large:  32px, 굵기 700
헤더 Medium: 28px, 굵기 600
헤더 Small:  24px, 굵기 600
본문 Large:  16px, 굵기 400
본문 Medium: 14px, 굵기 400
본문 Small:  12px, 굵기 400
```

---

## 📱 방법 3: UI 스크린샷 요청

현재 환경에서는 Flutter를 직접 실행할 수 없지만,
로컬에서 실행하시면 다음과 같은 화면을 보실 수 있습니다:

### 예상 화면 구성

**로그인 화면**
- ✨ 중앙의 빛나는 로고 (그라데이션 + 그림자)
- 부드러운 fade-in 애니메이션
- 모던한 Input 필드 (그라데이션 아이콘)
- 그라데이션 로그인 버튼 (hover 효과)
- 세련된 Google 로그인 버튼

**색상 느낌**
- 전체적으로 밝고 현대적
- 보라색 계열의 그라데이션
- 부드러운 그림자로 깊이감
- 여백이 넉넉한 레이아웃

---

## 🎯 방법 4: Flutter DevTools

```bash
# 앱 실행 후
flutter pub global activate devtools
flutter pub global run devtools

# 브라우저에서 UI Inspector 사용
# - 위젯 트리 확인
# - 레이아웃 디버깅
# - 컬러 피커
```

---

## 💡 추천 방법

1. **가장 빠른 방법**: `flutter run -d chrome`
   - 웹 브라우저에서 즉시 확인
   - 핫 리로드로 실시간 수정
   - 개발자 도구로 검사

2. **모바일 느낌 확인**: Android 에뮬레이터 또는 실제 기기
   - 터치 인터랙션 확인
   - 실제 사용 경험 테스트

3. **빠른 프로토타입**: Web 빌드
   ```bash
   flutter build web --release
   cd build/web
   python3 -m http.server 8000
   # http://localhost:8000 접속
   ```

---

## 🔍 코드로 UI 이해하기

### 로고 컴포넌트
```dart
Container(
  height: 100,
  width: 100,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [#6C63FF, #8E79FF, #B08FFF],
    ),
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
  child: Icon(Icons.auto_awesome, size: 48, color: white),
)
```

### 그라데이션 버튼
```dart
Container(
  height: 56,
  decoration: BoxDecoration(
    gradient: modernGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [...],
  ),
  child: InkWell(
    onTap: () {},
    child: Center(
      child: Text('Log In', style: ...),
    ),
  ),
)
```

---

## ✅ 확인 체크리스트

실행 후 확인할 사항:

- [ ] 로고가 부드럽게 나타나는가?
- [ ] 그라데이션이 잘 보이는가?
- [ ] Input 필드 포커스 시 보라색 테두리가 나타나는가?
- [ ] 버튼을 누르면 잔물결 효과가 있는가?
- [ ] 전체적으로 세련되고 현대적인가?
- [ ] 다크모드가 잘 작동하는가?
- [ ] 애니메이션이 부드러운가?

---

**로컬에서 실행하시면 위의 모든 디자인 요소를 직접 확인하실 수 있습니다!** 🎨
