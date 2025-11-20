import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { User } from '@shared/types';
import { STORAGE_KEYS } from '../constants';

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;

  // Actions
  setUser: (user: User | null) => void;
  setToken: (token: string | null) => void;
  login: (user: User, token: string, refreshToken?: string) => Promise<void>;
  logout: () => Promise<void>;
  loadAuth: () => Promise<void>;
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

export const useAuthStore = create<AuthState>((set) => ({
  user: __DEV__ ? DEV_USER : null,
  token: __DEV__ ? 'dev-token-mock' : null,
  isAuthenticated: __DEV__ ? true : false,
  isLoading: __DEV__ ? false : true,

  setUser: (user) => set({ user, isAuthenticated: !!user }),

  setToken: (token) => set({ token, isAuthenticated: !!token }),

  login: async (user, token, refreshToken) => {
    try {
      // Save to AsyncStorage
      await AsyncStorage.setItem(STORAGE_KEYS.AUTH_TOKEN, token);
      await AsyncStorage.setItem(STORAGE_KEYS.USER_DATA, JSON.stringify(user));

      if (refreshToken) {
        await AsyncStorage.setItem(STORAGE_KEYS.REFRESH_TOKEN, refreshToken);
      }

      set({
        user,
        token,
        isAuthenticated: true,
        isLoading: false,
      });
    } catch (error) {
      console.error('Failed to save auth data:', error);
      throw error;
    }
  },

  logout: async () => {
    try {
      // Clear AsyncStorage
      await AsyncStorage.multiRemove([
        STORAGE_KEYS.AUTH_TOKEN,
        STORAGE_KEYS.REFRESH_TOKEN,
        STORAGE_KEYS.USER_DATA,
      ]);

      set({
        user: null,
        token: null,
        isAuthenticated: false,
        isLoading: false,
      });
    } catch (error) {
      console.error('Failed to clear auth data:', error);
      throw error;
    }
  },

  loadAuth: async () => {
    try {
      // Dev 환경에서는 더미 유저 자동 로그인
      if (__DEV__) {
        set({
          user: DEV_USER,
          token: 'dev-token-mock',
          isAuthenticated: true,
          isLoading: false,
        });
        return;
      }

      const [token, userData] = await AsyncStorage.multiGet([
        STORAGE_KEYS.AUTH_TOKEN,
        STORAGE_KEYS.USER_DATA,
      ]);

      const authToken = token[1];
      const user = userData[1] ? JSON.parse(userData[1]) : null;

      set({
        token: authToken,
        user,
        isAuthenticated: !!(authToken && user),
        isLoading: false,
      });
    } catch (error) {
      console.error('Failed to load auth data:', error);
      set({ isLoading: false });
    }
  },
}));
