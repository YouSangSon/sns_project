# Supabase 설정 가이드

이 문서는 SNS 프로젝트를 Supabase로 백엔드를 구축하는 방법을 안내합니다.

## 📋 목차

1. [Supabase 프로젝트 생성](#1-supabase-프로젝트-생성)
2. [데이터베이스 스키마 설정](#2-데이터베이스-스키마-설정)
3. [인증 설정](#3-인증-설정)
4. [Storage 설정](#4-storage-설정)
5. [환경 변수 설정](#5-환경-변수-설정)
6. [테스트 계정 생성](#6-테스트-계정-생성)

---

## 1. Supabase 프로젝트 생성

### 1.1 계정 생성

1. [Supabase](https://supabase.com) 접속
2. "Start your project" 클릭
3. GitHub 또는 이메일로 가입

### 1.2 새 프로젝트 생성

1. Dashboard에서 "New Project" 클릭
2. 프로젝트 정보 입력:
   - **Name**: `sns-app` (원하는 이름)
   - **Database Password**: 강력한 비밀번호 생성 (저장해두세요!)
   - **Region**: `Northeast Asia (Seoul)` (한국 리전)
   - **Pricing Plan**: `Free` 선택
3. "Create new project" 클릭
4. 프로젝트 생성 완료까지 약 2분 대기

### 1.3 API 키 확인

프로젝트 생성 후:

1. 좌측 메뉴에서 **Settings** (⚙️) 클릭
2. **API** 메뉴 클릭
3. 다음 정보를 복사해두세요:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public**: `eyJhbGc...` (공개 API 키)
   - **service_role**: `eyJhbGc...` (서버용 비밀 키, 보안 유지!)

---

## 2. 데이터베이스 스키마 설정

### 2.1 SQL Editor 열기

1. 좌측 메뉴에서 **SQL Editor** 클릭
2. "New query" 클릭

### 2.2 스키마 생성 SQL 실행

아래 SQL 스크립트를 복사하여 붙여넣고 "Run" 클릭:

```sql
-- 이 파일의 내용은 supabase/schema.sql 파일을 참조하세요
```

자세한 SQL 스크립트는 프로젝트의 `supabase/schema.sql` 파일을 확인하세요.

---

## 3. 인증 설정

### 3.1 이메일 인증 활성화

1. 좌측 메뉴에서 **Authentication** 클릭
2. **Providers** 탭 클릭
3. **Email** 활성화 확인
4. 설정:
   - ✅ Enable email provider
   - ✅ Confirm email (개발 중에는 비활성화 가능)

### 3.2 JWT 설정 (자동 설정됨)

Supabase가 자동으로 JWT를 관리합니다. 별도 설정 불필요!

---

## 4. Storage 설정

이미지 및 비디오 업로드를 위한 Storage 설정:

### 4.1 Storage Bucket 생성

1. 좌측 메뉴에서 **Storage** 클릭
2. "New bucket" 클릭
3. Bucket 생성:
   - **Name**: `avatars` (프로필 이미지)
   - **Public bucket**: ✅ 체크
4. "Create bucket" 클릭
5. 같은 방법으로 다음 Bucket들 추가 생성:
   - `posts` (게시물 이미지) - Public
   - `stories` (스토리 이미지) - Public
   - `reels` (릴스 비디오) - Public

### 4.2 Storage 정책 설정

각 Bucket의 **Policies** 탭에서:

1. "New Policy" 클릭
2. "Enable insert for authenticated users only" 선택
3. "Enable read access for all users" 선택 (Public bucket)

---

## 5. 환경 변수 설정

### 5.1 모바일 앱 (.env)

`mobile/.env` 파일 생성:

```env
# Supabase 설정
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...

# 기존 API는 사용하지 않음
# API_BASE_URL=http://localhost:8080
```

### 5.2 웹 앱 (.env.local)

`web-app/.env.local` 파일 생성:

```env
# Supabase 설정
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...

# 기존 API는 사용하지 않음
# NEXT_PUBLIC_API_BASE_URL=http://localhost:8080
```

⚠️ **중요**: `xxxxx`를 실제 프로젝트 URL로 변경하세요!

---

## 6. 테스트 계정 생성

### 6.1 SQL로 테스트 계정 생성

SQL Editor에서 실행:

```sql
-- 테스트 계정 생성 (비밀번호: Test123!@#)
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at
)
VALUES (
  gen_random_uuid(),
  'test@example.com',
  crypt('Test123!@#', gen_salt('bf')),
  now(),
  now(),
  now()
);

-- profiles 테이블에 프로필 정보 추가
INSERT INTO public.profiles (id, username, full_name, bio)
SELECT
  id,
  'testuser',
  'Test User',
  '테스트 계정입니다'
FROM auth.users
WHERE email = 'test@example.com';
```

### 6.2 추가 테스트 계정

같은 방식으로 추가 계정 생성:

```sql
-- john@example.com / John123!@#
-- jane@example.com / Jane123!@#
-- admin@example.com / Admin123!@#
```

자세한 SQL은 `supabase/seed.sql` 파일을 참조하세요.

---

## 7. 로컬에서 테스트

### 7.1 패키지 설치

```bash
# 모바일
cd mobile
npm install @supabase/supabase-js

# 웹
cd web-app
npm install @supabase/supabase-js
```

### 7.2 앱 실행

```bash
# 모바일
cd mobile
npm start

# 웹
cd web-app
npm run dev
```

### 7.3 로그인 테스트

로그인 화면에서:
- 이메일: `test@example.com`
- 비밀번호: `Test123!@#`

입력하고 로그인!

---

## 🎉 완료!

이제 Supabase 백엔드를 사용하여 SNS 앱이 작동합니다!

## 📊 무료 티어 제한

- 500MB 데이터베이스
- 2GB 파일 저장소
- 50,000 월간 활성 사용자
- 무제한 API 요청

## 🔗 유용한 링크

- [Supabase 문서](https://supabase.com/docs)
- [Supabase JS 클라이언트](https://supabase.com/docs/reference/javascript/introduction)
- [Supabase Storage 가이드](https://supabase.com/docs/guides/storage)
- [Supabase Auth 가이드](https://supabase.com/docs/guides/auth)

## ❓ 문제 해결

### 데이터베이스 연결 오류

1. Supabase 대시보드에서 프로젝트 상태 확인
2. API 키가 올바른지 확인
3. 환경 변수 파일 이름 확인 (`.env`, `.env.local`)

### 인증 오류

1. Authentication → Providers에서 Email 활성화 확인
2. SQL Editor에서 테스트 계정 확인:
   ```sql
   SELECT * FROM auth.users WHERE email = 'test@example.com';
   ```

### Storage 업로드 오류

1. Storage → Buckets에서 Public 설정 확인
2. Policies에서 업로드 권한 확인

---

다음 단계: 프로젝트의 `supabase/` 폴더에서 상세한 SQL 스크립트를 확인하세요!
