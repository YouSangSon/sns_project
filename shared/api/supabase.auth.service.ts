import { supabase } from '../lib/supabase';
import type { User, AuthResponse, LoginDto, CreateUserDto } from '../types';

/**
 * Supabase 인증 서비스
 *
 * Supabase Auth를 사용하여 인증 기능을 구현합니다.
 * 기존 REST API 방식 대신 Supabase의 built-in 인증을 사용합니다.
 */
export class SupabaseAuthService {
  /**
   * 로그인
   */
  async login(credentials: LoginDto): Promise<AuthResponse> {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: credentials.email,
      password: credentials.password,
    });

    if (error) {
      throw new Error(error.message);
    }

    if (!data.session || !data.user) {
      throw new Error('로그인에 실패했습니다');
    }

    // 프로필 정보 조회
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', data.user.id)
      .single();

    if (profileError || !profile) {
      throw new Error('프로필 정보를 가져올 수 없습니다');
    }

    // AuthResponse 형식으로 변환
    return {
      token: data.session.access_token,
      refreshToken: data.session.refresh_token,
      expiresIn: data.session.expires_in || 3600,
      user: this.mapProfileToUser(profile),
    };
  }

  /**
   * 회원가입
   */
  async register(userData: CreateUserDto): Promise<AuthResponse> {
    // Supabase Auth로 회원가입
    const { data, error } = await supabase.auth.signUp({
      email: userData.email,
      password: userData.password,
      options: {
        data: {
          username: userData.username,
          full_name: userData.fullName || userData.username,
        },
      },
    });

    if (error) {
      throw new Error(error.message);
    }

    if (!data.session || !data.user) {
      throw new Error('회원가입에 실패했습니다');
    }

    // 프로필 정보 조회 (트리거에 의해 자동 생성됨)
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', data.user.id)
      .single();

    if (profileError || !profile) {
      throw new Error('프로필 정보를 가져올 수 없습니다');
    }

    return {
      token: data.session.access_token,
      refreshToken: data.session.refresh_token,
      expiresIn: data.session.expires_in || 3600,
      user: this.mapProfileToUser(profile),
    };
  }

  /**
   * 로그아웃
   */
  async logout(): Promise<void> {
    const { error } = await supabase.auth.signOut();
    if (error) {
      throw new Error(error.message);
    }
  }

  /**
   * 현재 사용자 정보 조회
   */
  async getCurrentUser(): Promise<User> {
    const { data: { user }, error: authError } = await supabase.auth.getUser();

    if (authError || !user) {
      throw new Error('인증되지 않은 사용자입니다');
    }

    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single();

    if (profileError || !profile) {
      throw new Error('프로필 정보를 가져올 수 없습니다');
    }

    return this.mapProfileToUser(profile);
  }

  /**
   * 토큰 갱신
   */
  async refreshToken(): Promise<AuthResponse> {
    const { data, error } = await supabase.auth.refreshSession();

    if (error || !data.session) {
      throw new Error('토큰 갱신에 실패했습니다');
    }

    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', data.session.user.id)
      .single();

    if (profileError || !profile) {
      throw new Error('프로필 정보를 가져올 수 없습니다');
    }

    return {
      token: data.session.access_token,
      refreshToken: data.session.refresh_token,
      expiresIn: data.session.expires_in || 3600,
      user: this.mapProfileToUser(profile),
    };
  }

  /**
   * 인증 여부 확인
   */
  async isAuthenticated(): Promise<boolean> {
    const { data: { session } } = await supabase.auth.getSession();
    return !!session;
  }

  /**
   * 현재 세션 가져오기
   */
  async getSession() {
    const { data: { session } } = await supabase.auth.getSession();
    return session;
  }

  /**
   * Supabase Profile을 User 타입으로 변환
   */
  private mapProfileToUser(profile: any): User {
    return {
      userId: profile.id,
      email: profile.email || '',
      username: profile.username,
      fullName: profile.full_name || '',
      bio: profile.bio || '',
      profileImageUrl: profile.profile_image_url || '',
      followerCount: profile.follower_count || 0,
      followingCount: profile.following_count || 0,
      postCount: profile.post_count || 0,
      isVerified: profile.is_verified || false,
      createdAt: profile.created_at,
    };
  }
}

export const supabaseAuthService = new SupabaseAuthService();
