-- ========================================
-- SNS 프로젝트 - 테스트 데이터 (Seed Data)
-- ========================================

-- 주의: 이 스크립트는 schema.sql 실행 후에 실행하세요!

-- ========================================
-- 1. 테스트 계정 생성
-- ========================================

-- 비밀번호 해싱을 위한 확장 (이미 활성화되어 있어야 함)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 테스트 계정 1: test@example.com / Test123!@#
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  aud,
  role
)
VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  '00000000-0000-0000-0000-000000000000'::uuid,
  'test@example.com',
  crypt('Test123!@#', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"username":"testuser","full_name":"Test User"}'::jsonb,
  now(),
  now(),
  'authenticated',
  'authenticated'
)
ON CONFLICT (id) DO NOTHING;

-- 프로필 생성
INSERT INTO public.profiles (id, username, full_name, bio, profile_image_url)
VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  'testuser',
  'Test User',
  '테스트 계정입니다 🧪',
  'https://i.pravatar.cc/300?u=testuser'
)
ON CONFLICT (id) DO NOTHING;

-- 테스트 계정 2: john@example.com / John123!@#
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  aud,
  role
)
VALUES (
  '22222222-2222-2222-2222-222222222222'::uuid,
  '00000000-0000-0000-0000-000000000000'::uuid,
  'john@example.com',
  crypt('John123!@#', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"username":"johndoe","full_name":"John Doe"}'::jsonb,
  now(),
  now(),
  'authenticated',
  'authenticated'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, username, full_name, bio, profile_image_url, is_verified)
VALUES (
  '22222222-2222-2222-2222-222222222222'::uuid,
  'johndoe',
  'John Doe',
  '사진 찍는 것을 좋아합니다 📸',
  'https://i.pravatar.cc/300?u=johndoe',
  true
)
ON CONFLICT (id) DO NOTHING;

-- 테스트 계정 3: jane@example.com / Jane123!@#
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  aud,
  role
)
VALUES (
  '33333333-3333-3333-3333-333333333333'::uuid,
  '00000000-0000-0000-0000-000000000000'::uuid,
  'jane@example.com',
  crypt('Jane123!@#', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"username":"janedoe","full_name":"Jane Doe"}'::jsonb,
  now(),
  now(),
  'authenticated',
  'authenticated'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, username, full_name, bio, profile_image_url, is_verified)
VALUES (
  '33333333-3333-3333-3333-333333333333'::uuid,
  'janedoe',
  'Jane Doe',
  '여행과 음식을 사랑하는 크리에이터 ✈️🍜',
  'https://i.pravatar.cc/300?u=janedoe',
  true
)
ON CONFLICT (id) DO NOTHING;

-- 테스트 계정 4: admin@example.com / Admin123!@#
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  aud,
  role
)
VALUES (
  '44444444-4444-4444-4444-444444444444'::uuid,
  '00000000-0000-0000-0000-000000000000'::uuid,
  'admin@example.com',
  crypt('Admin123!@#', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"username":"admin","full_name":"Admin User"}'::jsonb,
  now(),
  now(),
  'authenticated',
  'authenticated'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, username, full_name, bio, profile_image_url, is_verified)
VALUES (
  '44444444-4444-4444-4444-444444444444'::uuid,
  'admin',
  'Admin User',
  '관리자 계정',
  'https://i.pravatar.cc/300?u=admin',
  true
)
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- 2. 팔로우 관계 생성
-- ========================================

-- testuser가 johndoe를 팔로우
INSERT INTO public.follows (follower_id, following_id)
VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  '22222222-2222-2222-2222-222222222222'::uuid
)
ON CONFLICT DO NOTHING;

-- testuser가 janedoe를 팔로우
INSERT INTO public.follows (follower_id, following_id)
VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  '33333333-3333-3333-3333-333333333333'::uuid
)
ON CONFLICT DO NOTHING;

-- johndoe가 testuser를 팔로우
INSERT INTO public.follows (follower_id, following_id)
VALUES (
  '22222222-2222-2222-2222-222222222222'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid
)
ON CONFLICT DO NOTHING;

-- janedoe가 testuser를 팔로우
INSERT INTO public.follows (follower_id, following_id)
VALUES (
  '33333333-3333-3333-3333-333333333333'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid
)
ON CONFLICT DO NOTHING;

-- janedoe가 johndoe를 팔로우
INSERT INTO public.follows (follower_id, following_id)
VALUES (
  '33333333-3333-3333-3333-333333333333'::uuid,
  '22222222-2222-2222-2222-222222222222'::uuid
)
ON CONFLICT DO NOTHING;

-- ========================================
-- 3. 샘플 게시물 생성
-- ========================================

-- johndoe의 게시물
INSERT INTO public.posts (id, user_id, caption, image_urls, location)
VALUES (
  'post-1111-1111-1111-111111111111'::uuid,
  '22222222-2222-2222-2222-222222222222'::uuid,
  '아름다운 석양 🌅 #sunset #photography',
  ARRAY['https://images.unsplash.com/photo-1495616811223-4d98c6e9c869'],
  '서울, 한국'
)
ON CONFLICT DO NOTHING;

-- janedoe의 게시물
INSERT INTO public.posts (id, user_id, caption, image_urls, location)
VALUES (
  'post-2222-2222-2222-222222222222'::uuid,
  '33333333-3333-3333-3333-333333333333'::uuid,
  '맛있는 커피 한 잔 ☕️ #coffee #morning',
  ARRAY['https://images.unsplash.com/photo-1509042239860-f550ce710b93'],
  '부산, 한국'
)
ON CONFLICT DO NOTHING;

-- johndoe의 두 번째 게시물
INSERT INTO public.posts (id, user_id, caption, image_urls, location)
VALUES (
  'post-3333-3333-3333-333333333333'::uuid,
  '22222222-2222-2222-2222-222222222222'::uuid,
  '멋진 풍경 🏞️ #nature #travel',
  ARRAY[
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05'
  ],
  '제주도, 한국'
)
ON CONFLICT DO NOTHING;

-- ========================================
-- 4. 샘플 좋아요 생성
-- ========================================

-- testuser가 johndoe의 첫 번째 게시물에 좋아요
INSERT INTO public.likes (user_id, post_id)
VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  'post-1111-1111-1111-111111111111'::uuid
)
ON CONFLICT DO NOTHING;

-- testuser가 janedoe의 게시물에 좋아요
INSERT INTO public.likes (user_id, post_id)
VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  'post-2222-2222-2222-222222222222'::uuid
)
ON CONFLICT DO NOTHING;

-- janedoe가 johndoe의 게시물에 좋아요
INSERT INTO public.likes (user_id, post_id)
VALUES (
  '33333333-3333-3333-3333-333333333333'::uuid,
  'post-1111-1111-1111-111111111111'::uuid
)
ON CONFLICT DO NOTHING;

-- ========================================
-- 5. 샘플 댓글 생성
-- ========================================

-- testuser가 johndoe의 게시물에 댓글
INSERT INTO public.comments (user_id, post_id, content)
VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  'post-1111-1111-1111-111111111111'::uuid,
  '정말 멋진 사진이네요! 👍'
)
ON CONFLICT DO NOTHING;

-- janedoe가 johndoe의 게시물에 댓글
INSERT INTO public.comments (user_id, post_id, content)
VALUES (
  '33333333-3333-3333-3333-333333333333'::uuid,
  'post-1111-1111-1111-111111111111'::uuid,
  '와 이거 어디서 찍으셨어요? 🤩'
)
ON CONFLICT DO NOTHING;

-- johndoe가 janedoe의 댓글에 답글
INSERT INTO public.comments (user_id, post_id, content, parent_comment_id)
SELECT
  '22222222-2222-2222-2222-222222222222'::uuid,
  'post-1111-1111-1111-111111111111'::uuid,
  '남산타워에서 찍었어요! 😊',
  id
FROM public.comments
WHERE user_id = '33333333-3333-3333-3333-333333333333'::uuid
  AND post_id = 'post-1111-1111-1111-111111111111'::uuid
LIMIT 1
ON CONFLICT DO NOTHING;

-- ========================================
-- 6. 샘플 알림 생성
-- ========================================

-- testuser에게 좋아요 알림
INSERT INTO public.notifications (user_id, type, title, message, data)
VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  'follow',
  '새 팔로워',
  'johndoe님이 회원님을 팔로우하기 시작했습니다',
  jsonb_build_object('fromUserId', '22222222-2222-2222-2222-222222222222')
)
ON CONFLICT DO NOTHING;

-- ========================================
-- 완료!
-- ========================================

-- 테스트 계정 확인
SELECT
  u.email,
  p.username,
  p.full_name,
  p.follower_count,
  p.following_count,
  p.post_count
FROM auth.users u
JOIN public.profiles p ON u.id = p.id
WHERE u.email LIKE '%example.com'
ORDER BY u.created_at;

-- 생성된 게시물 확인
SELECT
  p.caption,
  prof.username,
  p.like_count,
  p.comment_count,
  p.created_at
FROM public.posts p
JOIN public.profiles prof ON p.user_id = prof.id
ORDER BY p.created_at DESC;

-- 트리거가 제대로 작동하는지 확인 (카운트가 자동으로 업데이트되었는지)
SELECT
  username,
  follower_count,
  following_count,
  post_count
FROM public.profiles
ORDER BY username;
