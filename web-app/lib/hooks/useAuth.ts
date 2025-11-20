import { useMutation } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import { authService } from '../../../shared/api';
import { useAuthStore } from '../stores/authStore';
import type { LoginDto, CreateUserDto } from '../../../shared/types';

export const useAuth = () => {
  const router = useRouter();
  const { user, isAuthenticated, login: storeLogin, logout: storeLogout } = useAuthStore();

  // Login mutation
  const loginMutation = useMutation({
    mutationFn: (credentials: LoginDto) => authService.login(credentials),
    onSuccess: (data) => {
      storeLogin(data.user, data.token, data.refreshToken);
      router.push('/feed');
    },
    onError: (error: any) => {
      console.error('Login failed:', error);
    },
  });

  // Register mutation
  const registerMutation = useMutation({
    mutationFn: (userData: CreateUserDto) => authService.register(userData),
    onSuccess: (data) => {
      storeLogin(data.user, data.token, data.refreshToken);
      router.push('/feed');
    },
    onError: (error: any) => {
      console.error('Registration failed:', error);
    },
  });

  // Logout mutation
  const logoutMutation = useMutation({
    mutationFn: () => authService.logout(),
    onSuccess: () => {
      storeLogout();
      router.push('/auth/login');
    },
    onError: (error: any) => {
      console.error('Logout error:', error);
      // Force logout even if API call fails
      storeLogout();
      router.push('/auth/login');
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
    loginError: loginMutation.error,
    registerError: registerMutation.error,
  };
};
