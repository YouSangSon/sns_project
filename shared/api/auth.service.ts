import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import {
  validateMockLogin,
  findMockUserByToken,
  createMockAuthResponse,
} from './mockData';
import type {
  User,
  CreateUserDto,
  LoginDto,
  AuthResponse,
} from '../types';

export class AuthService {
  async login(credentials: LoginDto): Promise<AuthResponse> {
    // 테스트 계정인지 확인 (백엔드 없이도 로그인 가능)
    const mockResponse = validateMockLogin(
      credentials.email,
      credentials.password
    );

    if (mockResponse) {
      console.log('🔧 테스트 계정으로 로그인 (백엔드 호출 없음)');

      // 약간의 지연 추가 (실제 API 호출처럼 느껴지게)
      await new Promise((resolve) => setTimeout(resolve, 500));

      // 토큰 저장
      apiClient.setAuthToken(mockResponse.token);
      if (mockResponse.refreshToken) {
        apiClient.setRefreshToken(mockResponse.refreshToken);
      }

      return mockResponse;
    }

    // 테스트 계정이 아니면 실제 API 호출
    const response = await apiClient.post<AuthResponse>(
      API_ENDPOINTS.AUTH.LOGIN,
      credentials
    );

    if (response.token) {
      apiClient.setAuthToken(response.token);
      if (response.refreshToken) {
        apiClient.setRefreshToken(response.refreshToken);
      }
    }

    return response;
  }

  async register(userData: CreateUserDto): Promise<AuthResponse> {
    // 실제 API 호출 (회원가입은 항상 백엔드 필요)
    const response = await apiClient.post<AuthResponse>(
      API_ENDPOINTS.AUTH.REGISTER,
      userData
    );

    if (response.token) {
      apiClient.setAuthToken(response.token);
      if (response.refreshToken) {
        apiClient.setRefreshToken(response.refreshToken);
      }
    }

    return response;
  }

  async logout(): Promise<void> {
    // 테스트 계정인지 확인
    const token = apiClient.getAuthToken();
    if (token) {
      const user = findMockUserByToken(token);
      if (user) {
        console.log('🔧 테스트 계정 로그아웃');
        await new Promise((resolve) => setTimeout(resolve, 300));
        apiClient.clearAuth();
        return;
      }
    }

    // 실제 API 호출
    try {
      await apiClient.post(API_ENDPOINTS.AUTH.LOGOUT);
    } finally {
      apiClient.clearAuth();
    }
  }

  async getCurrentUser(): Promise<User> {
    const token = apiClient.getAuthToken();
    if (!token) {
      throw new Error('인증되지 않은 사용자입니다');
    }

    // 테스트 계정 토큰인지 확인
    const mockUser = findMockUserByToken(token);
    if (mockUser) {
      console.log('🔧 테스트 계정 정보 조회');
      await new Promise((resolve) => setTimeout(resolve, 300));
      return mockUser;
    }

    // 실제 API 호출
    return apiClient.get<User>(API_ENDPOINTS.AUTH.ME);
  }

  async refreshToken(): Promise<AuthResponse> {
    const token = apiClient.getAuthToken();
    if (token) {
      // 테스트 계정 토큰인지 확인
      const user = findMockUserByToken(token);
      if (user) {
        console.log('🔧 테스트 계정 토큰 갱신');
        await new Promise((resolve) => setTimeout(resolve, 300));

        const newResponse = createMockAuthResponse(user);

        apiClient.setAuthToken(newResponse.token);
        if (newResponse.refreshToken) {
          apiClient.setRefreshToken(newResponse.refreshToken);
        }

        return newResponse;
      }
    }

    // 실제 API 호출
    const refreshToken = apiClient.getRefreshToken();
    if (!refreshToken) {
      throw new Error('No refresh token available');
    }

    const response = await apiClient.post<AuthResponse>(
      API_ENDPOINTS.AUTH.REFRESH,
      { refreshToken }
    );

    if (response.token) {
      apiClient.setAuthToken(response.token);
      if (response.refreshToken) {
        apiClient.setRefreshToken(response.refreshToken);
      }
    }

    return response;
  }

  isAuthenticated(): boolean {
    return !!apiClient.getAuthToken();
  }
}

export const authService = new AuthService();
