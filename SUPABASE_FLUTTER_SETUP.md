# Supabase + Flutter 설정 가이드

이 문서는 Flutter 앱에서 Supabase를 백엔드로 사용하는 완전한 가이드입니다.

## 📋 목차

1. [Supabase 프로젝트 생성](#1-supabase-프로젝트-생성)
2. [로컬 Supabase 개발 환경](#2-로컬-supabase-개발-환경)
3. [Flutter 앱 설정](#3-flutter-앱-설정)
4. [데이터베이스 스키마](#4-데이터베이스-스키마)
5. [인증 구현](#5-인증-구현)
6. [데이터 CRUD](#6-데이터-crud)
7. [Storage 사용](#7-storage-사용)
8. [Realtime 기능](#8-realtime-기능)

---

## 1. Supabase 프로젝트 생성

### 1.1 클라우드 Supabase 프로젝트

**개발/스테이징/프로덕션용**

1. [Supabase](https://supabase.com) 접속 및 로그인
2. "New Project" 클릭
3. 프로젝트 정보 입력:
   ```
   Name: sns-app-prod
   Database Password: [강력한 비밀번호]
   Region: Northeast Asia (Seoul)
   Pricing Plan: Free
   ```
4. "Create new project" 클릭 (약 2분 소요)

### 1.2 API 키 확인

프로젝트 생성 후:

1. **Settings** (⚙️) → **API** 클릭
2. 다음 정보를 복사:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGc...`
   - **service_role key**: `eyJhbGc...` (주의: 안전하게 보관!)

---

## 2. 로컬 Supabase 개발 환경

**로컬에서 Supabase를 실행하여 개발하기**

### 2.1 Supabase CLI 설치

**macOS**:
```bash
brew install supabase/tap/supabase
```

**Windows (Scoop)**:
```bash
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

**Linux**:
```bash
brew install supabase/tap/supabase
```

**NPM (모든 플랫폼)**:
```bash
npm install -g supabase
```

### 2.2 Docker 설치 확인

Supabase CLI는 Docker를 사용합니다:

```bash
docker --version
# Docker version 20.10.0 이상 필요
```

### 2.3 로컬 Supabase 초기화

프로젝트 루트에서:

```bash
cd sns_project

# Supabase 초기화
supabase init

# 로컬 Supabase 시작
supabase start
```

**시작 완료 시 출력 예시**:
```
Started supabase local development setup.

         API URL: http://localhost:54321
          DB URL: postgresql://postgres:postgres@localhost:54322/postgres
      Studio URL: http://localhost:54323
    Inbucket URL: http://localhost:54324
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
        anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2.4 로컬 Supabase 관리

```bash
# 로컬 Supabase 중지
supabase stop

# 상태 확인
supabase status

# 데이터 리셋
supabase db reset

# Studio 열기 (브라우저)
open http://localhost:54323
```

### 2.5 환경 설정 업데이트

로컬 Supabase 정보를 `config/dev.yaml`에 추가:

```yaml
# config/dev.yaml
supabase:
  url: http://localhost:54321
  anon_key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...  # supabase start 출력에서 복사
  service_role_key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 3. Flutter 앱 설정

### 3.1 패키지 추가

`pubspec.yaml`에 이미 추가되어 있습니다:

```yaml
dependencies:
  supabase_flutter: ^2.3.4
```

패키지 설치:

```bash
cd flutter_app
flutter pub get
```

### 3.2 초기화 확인

`lib/main.dart`에서 Supabase가 초기화됩니다:

```dart
Future<void> _initializeServices() async {
  // 환경 설정 초기화
  await EnvConfig.initialize(env: environment);

  // Supabase 초기화
  if (!EnvConfig.instance.enableMockData) {
    await SupabaseService.instance.initialize();
  }

  // ...
}
```

### 3.3 앱 실행

```bash
# 로컬 Supabase 사용
flutter run --dart-define=ENV=dev

# 클라우드 Supabase 사용 (staging)
flutter run --dart-define=ENV=staging
```

---

## 4. 데이터베이스 스키마

### 4.1 스키마 파일 생성

로컬 Supabase에서 마이그레이션 생성:

```bash
# 새 마이그레이션 파일 생성
supabase migration new create_profiles_table
```

### 4.2 스키마 정의

`supabase/migrations/[timestamp]_create_profiles_table.sql`:

```sql
-- profiles 테이블 생성
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  bio TEXT,
  avatar_url TEXT,
  followers_count INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  posts_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS (Row Level Security) 활성화
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 정책: 모든 사용자가 프로필 조회 가능
CREATE POLICY "Profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (true);

-- 정책: 사용자는 자신의 프로필만 수정 가능
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- 정책: 사용자는 자신의 프로필만 삭제 가능
CREATE POLICY "Users can delete own profile"
  ON public.profiles FOR DELETE
  USING (auth.uid() = id);

-- 인덱스 생성
CREATE INDEX profiles_username_idx ON public.profiles(username);

-- 트리거: updated_at 자동 업데이트
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 트리거: auth.users 생성 시 프로필 자동 생성
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

### 4.3 마이그레이션 실행

```bash
# 로컬에 적용
supabase db reset

# 원격(클라우드)에 적용
supabase db push
```

### 4.4 추가 테이블

`supabase/migrations/[timestamp]_create_posts_table.sql`:

```sql
-- posts 테이블
CREATE TABLE IF NOT EXISTS public.posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  caption TEXT,
  image_urls TEXT[],
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS 활성화
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- 정책
CREATE POLICY "Posts are viewable by everyone"
  ON public.posts FOR SELECT
  USING (true);

CREATE POLICY "Users can create posts"
  ON public.posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
  ON public.posts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts"
  ON public.posts FOR DELETE
  USING (auth.uid() = user_id);

-- 인덱스
CREATE INDEX posts_user_id_idx ON public.posts(user_id);
CREATE INDEX posts_created_at_idx ON public.posts(created_at DESC);
```

---

## 5. 인증 구현

### 5.1 DataSource 사용

`lib/features/auth/data/datasources/auth_supabase_datasource.dart`가 이미 생성되어 있습니다.

### 5.2 로그인 예제

```dart
import 'package:sns_app/core/supabase/supabase_service.dart';

final authDataSource = AuthSupabaseDataSource(SupabaseService.instance);

// 로그인
final response = await authDataSource.login(
  email: 'test@example.com',
  password: 'Test123!@#',
);

print('로그인 성공: ${response.user.email}');
print('액세스 토큰: ${response.accessToken}');
```

### 5.3 회원가입 예제

```dart
final response = await authDataSource.register(
  email: 'newuser@example.com',
  password: 'SecurePassword123!',
  username: 'newuser',
);

print('회원가입 성공: ${response.user.username}');
```

### 5.4 Auth 상태 관리 (Riverpod)

```dart
// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.instance.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService.instance.currentUser;
});
```

---

## 6. 데이터 CRUD

### 6.1 게시물 생성

```dart
final supabase = SupabaseService.instance.client;

// 게시물 생성
final post = await supabase.from('posts').insert({
  'user_id': supabase.auth.currentUser!.id,
  'caption': 'Beautiful sunset 🌅',
  'image_urls': ['https://example.com/image1.jpg'],
}).select().single();

print('게시물 생성됨: ${post['id']}');
```

### 6.2 피드 조회 (페이지네이션)

```dart
final posts = await supabase
    .from('posts')
    .select('''
      *,
      profiles:user_id (
        id,
        username,
        display_name,
        avatar_url
      )
    ''')
    .order('created_at', ascending: false)
    .range(0, 9)  // 0~9 (10개)
    .limit(10);

print('게시물 ${posts.length}개 조회');
```

### 6.3 게시물 수정

```dart
await supabase
    .from('posts')
    .update({'caption': 'Updated caption'})
    .eq('id', postId)
    .eq('user_id', supabase.auth.currentUser!.id);  // 본인 게시물만
```

### 6.4 게시물 삭제

```dart
await supabase
    .from('posts')
    .delete()
    .eq('id', postId)
    .eq('user_id', supabase.auth.currentUser!.id);
```

---

## 7. Storage 사용

### 7.1 Storage Bucket 생성

Supabase Studio (http://localhost:54323 또는 클라우드 대시보드):

1. **Storage** 클릭
2. "New bucket" 클릭
3. 다음 Bucket 생성:
   - `avatars` (Public)
   - `posts` (Public)
   - `stories` (Public)

### 7.2 이미지 업로드

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// 이미지 선택
final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.gallery);

if (image != null) {
  final file = File(image.path);
  final userId = supabase.auth.currentUser!.id;
  final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

  // Storage에 업로드
  final path = await SupabaseService.instance.uploadFile(
    bucket: 'posts',
    path: fileName,
    file: file,
    metadata: {'contentType': 'image/jpeg'},
  );

  // Public URL 가져오기
  final url = SupabaseService.instance.getPublicUrl(
    bucket: 'posts',
    path: path,
  );

  print('업로드 완료: $url');
}
```

### 7.3 프로필 이미지 업데이트

```dart
// 아바타 업로드
final avatarPath = await SupabaseService.instance.uploadFile(
  bucket: 'avatars',
  path: '$userId/avatar.jpg',
  file: imageFile,
);

final avatarUrl = SupabaseService.instance.getPublicUrl(
  bucket: 'avatars',
  path: avatarPath,
);

// 프로필 업데이트
await supabase
    .from('profiles')
    .update({'avatar_url': avatarUrl})
    .eq('id', userId);
```

---

## 8. Realtime 기능

### 8.1 실시간 알림 구독

```dart
// 새 알림 실시간 수신
final subscription = supabase
    .from('notifications')
    .stream(primaryKey: ['id'])
    .eq('user_id', supabase.auth.currentUser!.id)
    .listen((data) {
      print('새 알림: ${data.length}개');
      // UI 업데이트
    });

// 구독 해제
subscription.cancel();
```

### 8.2 실시간 채팅

```dart
// 채팅 메시지 실시간 수신
final channel = supabase.channel('chat:$conversationId');

channel
    .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'conversation_id',
        value: conversationId,
      ),
      callback: (payload) {
        print('새 메시지: ${payload.newRecord}');
        // UI에 메시지 추가
      },
    )
    .subscribe();

// 구독 해제
channel.unsubscribe();
```

### 8.3 온라인 사용자 상태

```dart
// Presence 사용
final presenceChannel = supabase.channel('online_users');

presenceChannel
    .onPresenceSync(() {
      final state = presenceChannel.presenceState();
      print('온라인 사용자: ${state.keys.length}명');
    })
    .subscribe();

// 사용자 등록
await presenceChannel.track({
  'user_id': supabase.auth.currentUser!.id,
  'online_at': DateTime.now().toIso8601String(),
});
```

---

## 🧪 테스트 데이터 추가

### Seed 파일 생성

`supabase/seed.sql`:

```sql
-- 테스트 사용자 생성
-- 비밀번호는 모두 Test123!@#

-- Alice
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at)
VALUES (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
  'alice@example.com',
  crypt('Test123!@#', gen_salt('bf')),
  NOW()
);

INSERT INTO public.profiles (id, username, display_name, bio)
VALUES (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
  'alice',
  'Alice Johnson',
  'Travel enthusiast 🌍'
);

-- Bob
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at)
VALUES (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid,
  'bob@example.com',
  crypt('Test123!@#', gen_salt('bf')),
  NOW()
);

INSERT INTO public.profiles (id, username, display_name, bio)
VALUES (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid,
  'bob',
  'Bob Smith',
  'Photographer 📷'
);

-- 테스트 게시물
INSERT INTO public.posts (user_id, caption, image_urls)
VALUES (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
  'Beautiful sunset 🌅',
  ARRAY['https://picsum.photos/seed/1/800/600']
);
```

### Seed 실행

```bash
supabase db reset
```

---

## 📊 개발 워크플로우

### 일반적인 개발 순서

1. **로컬 Supabase 시작**:
   ```bash
   supabase start
   ```

2. **Flutter 앱 실행**:
   ```bash
   cd flutter_app
   flutter run --dart-define=ENV=dev
   ```

3. **변경사항 작업**:
   - 코드 수정
   - 마이그레이션 추가
   - 테스트

4. **마이그레이션 생성**:
   ```bash
   supabase migration new your_migration_name
   # 생성된 파일에 SQL 작성
   supabase db reset  # 로컬에 적용
   ```

5. **원격 배포**:
   ```bash
   supabase db push  # 클라우드에 마이그레이션 적용
   ```

6. **작업 종료**:
   ```bash
   supabase stop
   ```

---

## 🎯 모범 사례

### 1. RLS (Row Level Security) 활용

항상 RLS를 활성화하고 정책을 설정하세요:

```sql
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their feed"
  ON public.posts FOR SELECT
  USING (
    auth.uid() IN (
      SELECT follower_id FROM follows WHERE following_id = user_id
    )
    OR auth.uid() = user_id
  );
```

### 2. 인덱스 최적화

자주 쿼리하는 컬럼에 인덱스 생성:

```sql
CREATE INDEX posts_user_id_created_at_idx
  ON public.posts(user_id, created_at DESC);
```

### 3. Storage 정책 설정

```sql
-- 인증된 사용자만 업로드 가능
CREATE POLICY "Users can upload own files"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'posts'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
```

### 4. 에러 처리

```dart
try {
  final data = await supabase.from('posts').select();
  // 성공
} on PostgrestException catch (e) {
  // Supabase DB 에러
  print('Database error: ${e.message}');
} on StorageException catch (e) {
  // Storage 에러
  print('Storage error: ${e.message}');
} catch (e) {
  // 기타 에러
  print('Error: $e');
}
```

---

## 🔗 유용한 링크

- [Supabase 공식 문서](https://supabase.com/docs)
- [Supabase Flutter 패키지](https://pub.dev/packages/supabase_flutter)
- [Supabase CLI 문서](https://supabase.com/docs/guides/cli)
- [RLS 가이드](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage 가이드](https://supabase.com/docs/guides/storage)

---

**Happy Coding with Supabase! 🚀**
