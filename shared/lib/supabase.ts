import { createClient } from '@supabase/supabase-js';

// Supabase 설정
const supabaseUrl = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn(
    '⚠️ Supabase URL 또는 ANON KEY가 설정되지 않았습니다. ' +
    '환경 변수를 확인하세요. (SUPABASE_URL, SUPABASE_ANON_KEY)'
  );
}

// Supabase 클라이언트 생성
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
});

// 타입 정의
export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          username: string;
          full_name: string | null;
          bio: string | null;
          profile_image_url: string | null;
          follower_count: number;
          following_count: number;
          post_count: number;
          is_verified: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['profiles']['Row'], 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['profiles']['Insert']>;
      };
      posts: {
        Row: {
          id: string;
          user_id: string;
          caption: string | null;
          image_urls: string[];
          location: string | null;
          like_count: number;
          comment_count: number;
          bookmark_count: number;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['posts']['Row'], 'id' | 'created_at' | 'updated_at' | 'like_count' | 'comment_count' | 'bookmark_count'>;
        Update: Partial<Database['public']['Tables']['posts']['Insert']>;
      };
      comments: {
        Row: {
          id: string;
          post_id: string;
          user_id: string;
          parent_comment_id: string | null;
          content: string;
          like_count: number;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['comments']['Row'], 'id' | 'created_at' | 'updated_at' | 'like_count'>;
        Update: Partial<Database['public']['Tables']['comments']['Insert']>;
      };
      likes: {
        Row: {
          id: string;
          post_id: string;
          user_id: string;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['likes']['Row'], 'id' | 'created_at'>;
        Update: never;
      };
      follows: {
        Row: {
          id: string;
          follower_id: string;
          following_id: string;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['follows']['Row'], 'id' | 'created_at'>;
        Update: never;
      };
      stories: {
        Row: {
          id: string;
          user_id: string;
          media_url: string;
          media_type: 'image' | 'video';
          caption: string | null;
          background_color: string;
          duration: number;
          view_count: number;
          created_at: string;
          expires_at: string;
        };
        Insert: Omit<Database['public']['Tables']['stories']['Row'], 'id' | 'view_count' | 'created_at' | 'expires_at'>;
        Update: never;
      };
      reels: {
        Row: {
          id: string;
          user_id: string;
          video_url: string;
          thumbnail_url: string | null;
          caption: string | null;
          audio_name: string | null;
          duration: number;
          like_count: number;
          comment_count: number;
          share_count: number;
          view_count: number;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['reels']['Row'], 'id' | 'like_count' | 'comment_count' | 'share_count' | 'view_count' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['reels']['Insert']>;
      };
      messages: {
        Row: {
          id: string;
          conversation_id: string;
          sender_id: string;
          content: string;
          is_read: boolean;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['messages']['Row'], 'id' | 'is_read' | 'created_at'>;
        Update: { is_read?: boolean };
      };
      notifications: {
        Row: {
          id: string;
          user_id: string;
          type: 'like' | 'comment' | 'follow' | 'mention';
          title: string;
          message: string;
          data: Record<string, any> | null;
          is_read: boolean;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['notifications']['Row'], 'id' | 'is_read' | 'created_at'>;
        Update: { is_read?: boolean };
      };
      bookmarks: {
        Row: {
          id: string;
          user_id: string;
          content_id: string;
          type: 'post' | 'reel';
          content_preview: string | null;
          content_image_url: string | null;
          author_username: string | null;
          author_photo_url: string | null;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['bookmarks']['Row'], 'id' | 'created_at'>;
        Update: never;
      };
    };
  };
};
