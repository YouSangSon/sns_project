// API Configuration
export const API_CONFIG = {
  BASE_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080',
  TIMEOUT: 30000,
};

// App Configuration
export const APP_CONFIG = {
  APP_NAME: 'SNS App',
  VERSION: '1.0.0',
  DESCRIPTION: 'Instagram-style Social Network Service',
};

// Pagination
export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 20,
  POSTS_PAGE_SIZE: 12,
  COMMENTS_PAGE_SIZE: 20,
};
