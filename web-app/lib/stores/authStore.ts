import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import type { User } from '@shared/types';

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;

  // Actions
  setUser: (user: User | null) => void;
  setToken: (token: string | null) => void;
  login: (user: User, token: string, refreshToken?: string) => void;
  logout: () => void;
}

// Dev 환경용 더미 유저
const DEV_USER: User = {
  userId: 'dev-user-001',
  username: 'devuser',
  email: 'dev@example.com',
  displayName: 'Dev User',
  photoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=dev',
  bio: '개발 환경 테스트 유저입니다',
  followerCount: 150,
  followingCount: 200,
  postCount: 42,
  createdAt: new Date('2024-01-01'),
  updatedAt: new Date(),
};

const isDevelopment = process.env.NODE_ENV === 'development';

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: isDevelopment ? DEV_USER : null,
      token: isDevelopment ? 'dev-token-mock' : null,
      isAuthenticated: isDevelopment ? true : false,

      setUser: (user) => set({ user, isAuthenticated: !!user }),

      setToken: (token) => set({ token, isAuthenticated: !!token }),

      login: (user, token, refreshToken) => {
        // Save to localStorage (handled by persist middleware)
        if (refreshToken && typeof window !== 'undefined') {
          localStorage.setItem('refreshToken', refreshToken);
        }

        set({
          user,
          token,
          isAuthenticated: true,
        });
      },

      logout: () => {
        // Clear localStorage
        if (typeof window !== 'undefined') {
          localStorage.removeItem('refreshToken');
        }

        set({
          user: null,
          token: null,
          isAuthenticated: false,
        });
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
);
