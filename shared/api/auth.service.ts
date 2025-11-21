import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import {
  USE_MOCK_API,
  validateMockLogin,
  createMockUser,
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
    // Mock 모드
    if (USE_MOCK_API) {
      console.log('🔧 Mock API 사용 중 - 하드코딩된 테스트 계정으로 로그인');

      // 약간의 지연 추가 (실제 API 호출처럼 느껴지게)
      await new Promise((resolve) => setTimeout(resolve, 500));

      const mockResponse = validateMockLogin(
        credentials.email,
        credentials.password
      );

      if (!mockResponse) {
        throw new Error('이메일 또는 비밀번호가 올바르지 않습니다');
      }

      // 토큰 저장
      apiClient.setAuthToken(mockResponse.token);
      if (mockResponse.refreshToken) {
        apiClient.setRefreshToken(mockResponse.refreshToken);
      }

      return mockResponse;
    }

    // 실제 API 호출
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
    // Mock 모드
    if (USE_MOCK_API) {
      console.log('🔧 Mock API 사용 중 - 새 테스트 계정 생성');

      await new Promise((resolve) => setTimeout(resolve, 500));

      const mockResponse = createMockUser(
        userData.email,
        userData.password,
        userData.username,
        userData.fullName || userData.username
      );

      apiClient.setAuthToken(mockResponse.token);
      if (mockResponse.refreshToken) {
        apiClient.setRefreshToken(mockResponse.refreshToken);
      }

      return mockResponse;
    }

    // 실제 API 호출
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
    // Mock 모드
    if (USE_MOCK_API) {
      console.log('🔧 Mock API 사용 중 - 로그아웃');
      await new Promise((resolve) => setTimeout(resolve, 300));
      apiClient.clearAuth();
      return;
    }

    // 실제 API 호출
    try {
      await apiClient.post(API_ENDPOINTS.AUTH.LOGOUT);
    } finally {
      apiClient.clearAuth();
    }
  }

  async getCurrentUser(): Promise<User> {
    // Mock 모드
    if (USE_MOCK_API) {
      console.log('🔧 Mock API 사용 중 - 현재 사용자 정보 조회');

      await new Promise((resolve) => setTimeout(resolve, 300));

      const token = apiClient.getAuthToken();
      if (!token) {
        throw new Error('인증되지 않은 사용자입니다');
      }

      const user = findMockUserByToken(token);
      if (!user) {
        throw new Error('사용자를 찾을 수 없습니다');
      }

      return user;
    }

    // 실제 API 호출
    return apiClient.get<User>(API_ENDPOINTS.AUTH.ME);
  }

  async refreshToken(): Promise<AuthResponse> {
    // Mock 모드
    if (USE_MOCK_API) {
      console.log('🔧 Mock API 사용 중 - 토큰 갱신');

      const token = apiClient.getAuthToken();
      if (!token) {
        throw new Error('인증되지 않은 사용자입니다');
      }

      const user = findMockUserByToken(token);
      if (!user) {
        throw new Error('사용자를 찾을 수 없습니다');
      }

      await new Promise((resolve) => setTimeout(resolve, 300));

      const newResponse = createMockAuthResponse(user);

      apiClient.setAuthToken(newResponse.token);
      if (newResponse.refreshToken) {
        apiClient.setRefreshToken(newResponse.refreshToken);
      }

      return newResponse;
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
