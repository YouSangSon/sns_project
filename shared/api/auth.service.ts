import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  User,
  CreateUserDto,
  LoginDto,
  AuthResponse,
} from '../types';

export class AuthService {
  async login(credentials: LoginDto): Promise<AuthResponse> {
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
    try {
      await apiClient.post(API_ENDPOINTS.AUTH.LOGOUT);
    } finally {
      apiClient.clearAuth();
    }
  }

  async getCurrentUser(): Promise<User> {
    return apiClient.get<User>(API_ENDPOINTS.AUTH.ME);
  }

  async refreshToken(): Promise<AuthResponse> {
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
