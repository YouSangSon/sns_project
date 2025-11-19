// API Configuration
export const API_CONFIG = {
  BASE_URL: __DEV__
    ? 'http://localhost:8080'
    : 'https://api.yoursns.com',
  TIMEOUT: 30000,
};

// App Configuration
export const APP_CONFIG = {
  APP_NAME: 'SNS App',
  VERSION: '1.0.0',
};

// Storage Keys
export const STORAGE_KEYS = {
  AUTH_TOKEN: '@auth_token',
  REFRESH_TOKEN: '@refresh_token',
  USER_DATA: '@user_data',
};

// Pagination
export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 20,
  POSTS_PAGE_SIZE: 10,
  COMMENTS_PAGE_SIZE: 20,
};
