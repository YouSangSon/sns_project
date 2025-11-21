-- ========================================
-- SNS 프로젝트 - Supabase 데이터베이스 스키마
-- ========================================

-- 확장 기능 활성화
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================
-- 1. 프로필 테이블 (auth.users 확장)
-- ========================================

CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  bio TEXT,
  profile_image_url TEXT,
  follower_count INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  post_count INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 프로필 인덱스
CREATE INDEX idx_profiles_username ON public.profiles(username);

-- 프로필 RLS (Row Level Security)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "프로필은 모두 조회 가능" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "본인 프로필만 수정 가능" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- ========================================
-- 2. 게시물 테이블
-- ========================================

CREATE TABLE public.posts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  caption TEXT,
  image_urls TEXT[] DEFAULT '{}',
  location TEXT,
  like_count INTEGER DEFAULT 0,
  comment_count INTEGER DEFAULT 0,
  bookmark_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 게시물 인덱스
CREATE INDEX idx_posts_user_id ON public.posts(user_id);
CREATE INDEX idx_posts_created_at ON public.posts(created_at DESC);

-- 게시물 RLS
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "게시물은 모두 조회 가능" ON public.posts
  FOR SELECT USING (true);

CREATE POLICY "본인 게시물만 삽입 가능" ON public.posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "본인 게시물만 수정 가능" ON public.posts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "본인 게시물만 삭제 가능" ON public.posts
  FOR DELETE USING (auth.uid() = user_id);

-- ========================================
-- 3. 댓글 테이블
-- ========================================

CREATE TABLE public.comments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  parent_comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  like_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 댓글 인덱스
CREATE INDEX idx_comments_post_id ON public.comments(post_id);
CREATE INDEX idx_comments_user_id ON public.comments(user_id);
CREATE INDEX idx_comments_parent_id ON public.comments(parent_comment_id);

-- 댓글 RLS
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "댓글은 모두 조회 가능" ON public.comments
  FOR SELECT USING (true);

CREATE POLICY "인증된 사용자만 댓글 작성" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "본인 댓글만 수정 가능" ON public.comments
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "본인 댓글만 삭제 가능" ON public.comments
  FOR DELETE USING (auth.uid() = user_id);

-- ========================================
-- 4. 좋아요 테이블
-- ========================================

CREATE TABLE public.likes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- 좋아요 인덱스
CREATE INDEX idx_likes_post_id ON public.likes(post_id);
CREATE INDEX idx_likes_user_id ON public.likes(user_id);

-- 좋아요 RLS
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "좋아요는 모두 조회 가능" ON public.likes
  FOR SELECT USING (true);

CREATE POLICY "인증된 사용자만 좋아요" ON public.likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "본인 좋아요만 삭제 가능" ON public.likes
  FOR DELETE USING (auth.uid() = user_id);

-- ========================================
-- 5. 팔로우 테이블
-- ========================================

CREATE TABLE public.follows (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  follower_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  following_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(follower_id, following_id),
  CHECK (follower_id != following_id)
);

-- 팔로우 인덱스
CREATE INDEX idx_follows_follower_id ON public.follows(follower_id);
CREATE INDEX idx_follows_following_id ON public.follows(following_id);

-- 팔로우 RLS
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "팔로우는 모두 조회 가능" ON public.follows
  FOR SELECT USING (true);

CREATE POLICY "인증된 사용자만 팔로우" ON public.follows
  FOR INSERT WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "본인 팔로우만 삭제 가능" ON public.follows
  FOR DELETE USING (auth.uid() = follower_id);

-- ========================================
-- 6. 스토리 테이블
-- ========================================

CREATE TABLE public.stories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  media_url TEXT NOT NULL,
  media_type TEXT NOT NULL CHECK (media_type IN ('image', 'video')),
  caption TEXT,
  background_color TEXT DEFAULT '#000000',
  duration INTEGER DEFAULT 5,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() + INTERVAL '24 hours'
);

-- 스토리 인덱스
CREATE INDEX idx_stories_user_id ON public.stories(user_id);
CREATE INDEX idx_stories_created_at ON public.stories(created_at DESC);
CREATE INDEX idx_stories_expires_at ON public.stories(expires_at);

-- 스토리 RLS
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "활성 스토리는 모두 조회 가능" ON public.stories
  FOR SELECT USING (expires_at > NOW());

CREATE POLICY "본인 스토리만 삽입 가능" ON public.stories
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "본인 스토리만 삭제 가능" ON public.stories
  FOR DELETE USING (auth.uid() = user_id);

-- ========================================
-- 7. 릴스 테이블
-- ========================================

CREATE TABLE public.reels (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  caption TEXT,
  audio_name TEXT,
  duration INTEGER NOT NULL,
  like_count INTEGER DEFAULT 0,
  comment_count INTEGER DEFAULT 0,
  share_count INTEGER DEFAULT 0,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 릴스 인덱스
CREATE INDEX idx_reels_user_id ON public.reels(user_id);
CREATE INDEX idx_reels_created_at ON public.reels(created_at DESC);

-- 릴스 RLS
ALTER TABLE public.reels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "릴스는 모두 조회 가능" ON public.reels
  FOR SELECT USING (true);

CREATE POLICY "본인 릴스만 삽입 가능" ON public.reels
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "본인 릴스만 수정 가능" ON public.reels
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "본인 릴스만 삭제 가능" ON public.reels
  FOR DELETE USING (auth.uid() = user_id);

-- ========================================
-- 8. 대화 테이블
-- ========================================

CREATE TABLE public.conversations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user1_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  user2_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user1_id, user2_id),
  CHECK (user1_id < user2_id)
);

-- 대화 인덱스
CREATE INDEX idx_conversations_user1_id ON public.conversations(user1_id);
CREATE INDEX idx_conversations_user2_id ON public.conversations(user2_id);

-- 대화 RLS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "본인 대화만 조회 가능" ON public.conversations
  FOR SELECT USING (auth.uid() IN (user1_id, user2_id));

CREATE POLICY "인증된 사용자만 대화 생성" ON public.conversations
  FOR INSERT WITH CHECK (auth.uid() IN (user1_id, user2_id));

-- ========================================
-- 9. 메시지 테이블
-- ========================================

CREATE TABLE public.messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 메시지 인덱스
CREATE INDEX idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);

-- 메시지 RLS
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "대화 참여자만 메시지 조회" ON public.messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.conversations
      WHERE id = conversation_id
      AND auth.uid() IN (user1_id, user2_id)
    )
  );

CREATE POLICY "대화 참여자만 메시지 전송" ON public.messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM public.conversations
      WHERE id = conversation_id
      AND auth.uid() IN (user1_id, user2_id)
    )
  );

-- ========================================
-- 10. 알림 테이블
-- ========================================

CREATE TABLE public.notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('like', 'comment', 'follow', 'mention')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 알림 인덱스
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);

-- 알림 RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "본인 알림만 조회 가능" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "본인 알림만 수정 가능" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- ========================================
-- 11. 북마크 테이블
-- ========================================

CREATE TABLE public.bookmarks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content_id UUID NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('post', 'reel')),
  content_preview TEXT,
  content_image_url TEXT,
  author_username TEXT,
  author_photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, content_id, type)
);

-- 북마크 인덱스
CREATE INDEX idx_bookmarks_user_id ON public.bookmarks(user_id);
CREATE INDEX idx_bookmarks_type ON public.bookmarks(type);

-- 북마크 RLS
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "본인 북마크만 조회 가능" ON public.bookmarks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "인증된 사용자만 북마크 추가" ON public.bookmarks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "본인 북마크만 삭제 가능" ON public.bookmarks
  FOR DELETE USING (auth.uid() = user_id);

-- ========================================
-- 12. 트리거 함수
-- ========================================

-- 프로필 생성 트리거 (회원가입 시 자동 프로필 생성)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 게시물 수 업데이트 트리거
CREATE OR REPLACE FUNCTION public.update_post_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.profiles
    SET post_count = post_count + 1
    WHERE id = NEW.user_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.profiles
    SET post_count = post_count - 1
    WHERE id = OLD.user_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_post_created
  AFTER INSERT ON public.posts
  FOR EACH ROW EXECUTE FUNCTION public.update_post_count();

CREATE TRIGGER on_post_deleted
  AFTER DELETE ON public.posts
  FOR EACH ROW EXECUTE FUNCTION public.update_post_count();

-- 좋아요 수 업데이트 트리거
CREATE OR REPLACE FUNCTION public.update_like_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.posts
    SET like_count = like_count + 1
    WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.posts
    SET like_count = like_count - 1
    WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_like_created
  AFTER INSERT ON public.likes
  FOR EACH ROW EXECUTE FUNCTION public.update_like_count();

CREATE TRIGGER on_like_deleted
  AFTER DELETE ON public.likes
  FOR EACH ROW EXECUTE FUNCTION public.update_like_count();

-- 팔로우 수 업데이트 트리거
CREATE OR REPLACE FUNCTION public.update_follow_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.profiles SET following_count = following_count + 1 WHERE id = NEW.follower_id;
    UPDATE public.profiles SET follower_count = follower_count + 1 WHERE id = NEW.following_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.profiles SET following_count = following_count - 1 WHERE id = OLD.follower_id;
    UPDATE public.profiles SET follower_count = follower_count - 1 WHERE id = OLD.following_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_follow_created
  AFTER INSERT ON public.follows
  FOR EACH ROW EXECUTE FUNCTION public.update_follow_count();

CREATE TRIGGER on_follow_deleted
  AFTER DELETE ON public.follows
  FOR EACH ROW EXECUTE FUNCTION public.update_follow_count();

-- updated_at 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON public.posts
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_comments_updated_at
  BEFORE UPDATE ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ========================================
-- 13. 유용한 뷰 (Views)
-- ========================================

-- 피드용 게시물 뷰 (사용자 정보 포함)
CREATE OR REPLACE VIEW public.posts_with_user AS
SELECT
  p.*,
  prof.username,
  prof.full_name,
  prof.profile_image_url as user_photo_url,
  prof.is_verified,
  EXISTS (
    SELECT 1 FROM public.likes l
    WHERE l.post_id = p.id AND l.user_id = auth.uid()
  ) as is_liked,
  EXISTS (
    SELECT 1 FROM public.bookmarks b
    WHERE b.content_id = p.id AND b.type = 'post' AND b.user_id = auth.uid()
  ) as is_bookmarked
FROM public.posts p
JOIN public.profiles prof ON p.user_id = prof.id;

-- ========================================
-- 완료!
-- ========================================

-- 이 스크립트를 Supabase SQL Editor에서 실행하세요.
