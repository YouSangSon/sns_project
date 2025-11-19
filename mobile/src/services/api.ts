// Re-export shared API services for mobile app
export {
  apiClient,
  authService,
  usersService,
  postsService,
} from '../../../shared/api';

export { API_ENDPOINTS } from '../../../shared/constants/api';

// Mobile-specific API initialization
import { apiClient } from '../../../shared/api';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { API_CONFIG, STORAGE_KEYS } from '../constants';

// Initialize API client for mobile
export const initializeApiClient = async () => {
  // Set base URL for mobile
  const baseURL = API_CONFIG.BASE_URL;

  // Load auth token from AsyncStorage
  const token = await AsyncStorage.getItem(STORAGE_KEYS.AUTH_TOKEN);

  if (token) {
    apiClient.setAuthToken(token);
  }

  return apiClient;
};

// Override localStorage methods for React Native
if (typeof window !== 'undefined' && !window.localStorage) {
  (window as any).localStorage = {
    getItem: async (key: string) => {
      return await AsyncStorage.getItem(key);
    },
    setItem: async (key: string, value: string) => {
      await AsyncStorage.setItem(key, value);
    },
    removeItem: async (key: string) => {
      await AsyncStorage.removeItem(key);
    },
  };
}
