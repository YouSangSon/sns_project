import { useMutation } from '@tanstack/react-query';
import { Alert } from 'react-native';
import { authService } from '../services/api';
import { useAuthStore } from '../stores/authStore';
import type { LoginDto, CreateUserDto } from '@shared/types';

export const useAuth = () => {
  const { user, isAuthenticated, login: storeLogin, logout: storeLogout } = useAuthStore();

  // Login mutation
  const loginMutation = useMutation({
    mutationFn: (credentials: LoginDto) => authService.login(credentials),
    onSuccess: async (data) => {
      await storeLogin(data.user, data.token, data.refreshToken);
    },
    onError: (error: any) => {
      Alert.alert(
        'Login Failed',
        error.response?.data?.message || error.message || 'An error occurred'
      );
    },
  });

  // Register mutation
  const registerMutation = useMutation({
    mutationFn: (userData: CreateUserDto) => authService.register(userData),
    onSuccess: async (data) => {
      await storeLogin(data.user, data.token, data.refreshToken);
    },
    onError: (error: any) => {
      Alert.alert(
        'Registration Failed',
        error.response?.data?.message || error.message || 'An error occurred'
      );
    },
  });

  // Logout mutation
  const logoutMutation = useMutation({
    mutationFn: () => authService.logout(),
    onSuccess: async () => {
      await storeLogout();
    },
    onError: (error: any) => {
      console.error('Logout error:', error);
      // Force logout even if API call fails
      storeLogout();
    },
  });

  return {
    user,
    isAuthenticated,
    login: loginMutation.mutate,
    register: registerMutation.mutate,
    logout: logoutMutation.mutate,
    isLoggingIn: loginMutation.isPending,
    isRegistering: registerMutation.isPending,
    isLoggingOut: logoutMutation.isPending,
  };
};
