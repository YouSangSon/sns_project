# Firebase Setup Guide

이 가이드는 SNS App에 Firebase를 설정하는 방법을 안내합니다.

## 사전 준비
- Google 계정
- Flutter 개발 환경 설치
- Android Studio 또는 Xcode (플랫폼에 따라)

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속합니다.
2. "프로젝트 추가"를 클릭합니다.
3. 프로젝트 이름을 입력합니다 (예: "SNS App").
4. Google Analytics 설정 (선택사항)을 완료합니다.
5. "프로젝트 만들기"를 클릭합니다.

## 2. Android 앱 설정

### 2.1 Firebase에 Android 앱 추가

1. Firebase Console에서 생성한 프로젝트를 선택합니다.
2. "Android 앱에 Firebase 추가"를 클릭합니다.
3. 다음 정보를 입력합니다:
   - **Android 패키지 이름**: `com.example.sns_app`
   - **앱 닉네임**: SNS App (선택사항)
   - **디버그 서명 인증서 SHA-1**: (선택사항, Google Sign In을 위해 필요)

### 2.2 SHA-1 인증서 가져오기 (Google Sign In 사용 시 필수)

```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# Mac/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 2.3 google-services.json 다운로드

1. `google-services.json` 파일을 다운로드합니다.
2. 파일을 `android/app/` 디렉토리에 복사합니다.

```
android/
  app/
    google-services.json  <-- 여기에 배치
```

## 3. iOS 앱 설정

### 3.1 Firebase에 iOS 앱 추가

1. Firebase Console에서 "iOS 앱에 Firebase 추가"를 클릭합니다.
2. 다음 정보를 입력합니다:
   - **iOS 번들 ID**: `com.example.snsApp`
   - **앱 닉네임**: SNS App (선택사항)

### 3.2 GoogleService-Info.plist 다운로드

1. `GoogleService-Info.plist` 파일을 다운로드합니다.
2. Xcode에서 프로젝트를 엽니다:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. 파일을 `Runner` 폴더에 드래그합니다.
4. "Copy items if needed"를 체크합니다.

```
ios/
  Runner/
    GoogleService-Info.plist  <-- 여기에 배치
```

## 4. Firebase Authentication 설정

1. Firebase Console에서 "Authentication"을 선택합니다.
2. "시작하기"를 클릭합니다.
3. "Sign-in method" 탭으로 이동합니다.
4. 다음 로그인 방법을 활성화합니다:
   - **이메일/비밀번호**: 활성화
   - **Google**: 활성화 (프로젝트 지원 이메일 설정 필요)

### Google Sign-In 추가 설정 (Android)

1. Firebase Console에서 Google 로그인을 활성화합니다.
2. SHA-1 인증서가 등록되어 있는지 확인합니다.
3. `android/app/build.gradle`에 다음이 포함되어 있는지 확인:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## 5. Cloud Firestore 설정

1. Firebase Console에서 "Firestore Database"를 선택합니다.
2. "데이터베이스 만들기"를 클릭합니다.
3. **테스트 모드로 시작** (개발 중)을 선택합니다.
4. 위치를 선택합니다 (예: asia-northeast3 - Seoul).

### 5.1 보안 규칙 설정

개발 단계에서는 테스트 모드를 사용하지만, 프로덕션에서는 다음 규칙을 사용하세요:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Posts collection
    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
                               request.auth.uid == resource.data.userId;
    }

    // Comments collection
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
                               request.auth.uid == resource.data.userId;
    }

    // Likes collection
    match /likes/{likeId} {
      allow read: if true;
      allow create, delete: if request.auth != null;
    }

    // Follows collection
    match /follows/{followId} {
      allow read: if true;
      allow create, delete: if request.auth != null;
    }

    // Stories collection
    match /stories/{storyId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
                               request.auth.uid == resource.data.userId;
    }

    // Conversations and Messages
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null &&
                           request.auth.uid in resource.data.participants;

      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }

    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if request.auth != null &&
                    request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
                               request.auth.uid == resource.data.userId;
    }
  }
}
```

## 6. Firebase Storage 설정

1. Firebase Console에서 "Storage"를 선택합니다.
2. "시작하기"를 클릭합니다.
3. **테스트 모드로 시작**을 선택합니다.
4. 위치를 선택합니다.

### 6.1 Storage 보안 규칙

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    match /post_images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /story_images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /message_media/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 7. Flutter 패키지 설치

프로젝트 루트 디렉토리에서 다음 명령을 실행합니다:

```bash
flutter pub get
```

## 8. 앱 실행

### Android
```bash
flutter run
```

### iOS
```bash
cd ios
pod install
cd ..
flutter run
```

## 9. 테스트

1. 앱을 실행합니다.
2. 회원가입 기능을 테스트합니다.
3. Firebase Console에서:
   - Authentication에 사용자가 추가되었는지 확인
   - Firestore에 사용자 문서가 생성되었는지 확인

## 문제 해결

### Android 빌드 오류

1. `android/gradle.properties` 파일에 다음을 추가:
```properties
android.useAndroidX=true
android.enableJetifier=true
```

2. Gradle 버전 확인:
```bash
cd android
./gradlew --version
```

### iOS 빌드 오류

1. CocoaPods 재설치:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

2. Xcode에서 Signing & Capabilities 확인

### Google Sign-In 오류

1. SHA-1 인증서가 Firebase Console에 등록되어 있는지 확인
2. `google-services.json` 파일이 최신인지 확인
3. Google Sign-In이 Firebase Console에서 활성화되어 있는지 확인

## 추가 기능 (선택사항)

### Firebase Cloud Messaging (푸시 알림)

1. Firebase Console에서 "Cloud Messaging"을 선택합니다.
2. 서버 키를 복사합니다.
3. iOS의 경우 APNs 인증 키를 업로드합니다.

### Firebase Analytics

이미 기본적으로 포함되어 있습니다. 추가 설정이 필요하지 않습니다.

### Firebase Crashlytics (앱 충돌 보고)

```bash
flutter pub add firebase_crashlytics
```

## 참고 자료

- [Firebase 공식 문서](https://firebase.google.com/docs)
- [FlutterFire 문서](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
