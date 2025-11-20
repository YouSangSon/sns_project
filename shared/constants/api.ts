// API Base URL - 환경에 따라 변경
export const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:8080';

// API Endpoints
export const API_ENDPOINTS = {
  // Auth
  AUTH: {
    LOGIN: '/api/v1/auth/login',
    REGISTER: '/api/v1/users/register',
    LOGOUT: '/api/v1/auth/logout',
    REFRESH: '/api/v1/auth/refresh',
    ME: '/api/v1/auth/me',
  },

  // Users
  USERS: {
    BASE: '/api/v1/users',
    BY_ID: (id: string) => `/api/v1/users/${id}`,
    PROFILE: (id: string) => `/api/v1/users/${id}/profile`,
    POSTS: (id: string) => `/api/v1/users/${id}/posts`,
    FOLLOWERS: (id: string) => `/api/v1/users/${id}/followers`,
    FOLLOWING: (id: string) => `/api/v1/users/${id}/following`,
    FOLLOW: (id: string) => `/api/v1/users/${id}/follow`,
    UNFOLLOW: (id: string) => `/api/v1/users/${id}/unfollow`,
    SEARCH: '/api/v1/users/search',
  },

  // Posts
  POSTS: {
    BASE: '/api/v1/posts',
    BY_ID: (id: string) => `/api/v1/posts/${id}`,
    FEED: '/api/v1/posts/feed',
    LIKE: (id: string) => `/api/v1/posts/${id}/like`,
    UNLIKE: (id: string) => `/api/v1/posts/${id}/unlike`,
    COMMENTS: (id: string) => `/api/v1/posts/${id}/comments`,
  },

  // Comments
  COMMENTS: {
    BASE: '/api/v1/comments',
    BY_ID: (id: string) => `/api/v1/comments/${id}`,
    LIKE: (id: string) => `/api/v1/comments/${id}/like`,
    UNLIKE: (id: string) => `/api/v1/comments/${id}/unlike`,
  },

  // Stories
  STORIES: {
    BASE: '/api/v1/stories',
    BY_ID: (id: string) => `/api/v1/stories/${id}`,
    BY_USER: (userId: string) => `/api/v1/stories/user/${userId}`,
    FOLLOWING: '/api/v1/stories/following',
    VIEW: (id: string) => `/api/v1/stories/${id}/view`,
    VIEWERS: (id: string) => `/api/v1/stories/${id}/viewers`,
  },

  // Messages
  MESSAGES: {
    CONVERSATIONS: '/api/v1/messages/conversations',
    BY_CONVERSATION: (id: string) => `/api/v1/messages/conversations/${id}`,
    SEND: '/api/v1/messages',
    MARK_READ: (id: string) => `/api/v1/messages/${id}/read`,
  },

  // Notifications
  NOTIFICATIONS: {
    BASE: '/api/v1/notifications',
    UNREAD: '/api/v1/notifications/unread',
    MARK_READ: (id: string) => `/api/v1/notifications/${id}/read`,
    MARK_ALL_READ: '/api/v1/notifications/read-all',
  },

  // Reels
  REELS: {
    BASE: '/api/v1/reels',
    BY_ID: (id: string) => `/api/v1/reels/${id}`,
    FEED: '/api/v1/reels/feed',
    LIKE: (id: string) => `/api/v1/reels/${id}/like`,
    UNLIKE: (id: string) => `/api/v1/reels/${id}/unlike`,
    VIEW: (id: string) => `/api/v1/reels/${id}/view`,
  },

  // Bookmarks
  BOOKMARKS: {
    BASE: '/api/v1/bookmarks',
    BY_TYPE: (type: string) => `/api/v1/bookmarks?type=${type}`,
    CREATE: '/api/v1/bookmarks',
    DELETE: (id: string) => `/api/v1/bookmarks/${id}`,
  },

  // Investment - Portfolios
  PORTFOLIOS: {
    BASE: '/api/v1/investment/portfolios',
    BY_ID: (id: string) => `/api/v1/investment/portfolios/${id}`,
    BY_USER: (userId: string) => `/api/v1/investment/portfolios/user/${userId}`,
    PUBLIC: '/api/v1/investment/portfolios/public',
    ANALYTICS: (id: string) => `/api/v1/investment/portfolios/${id}/analytics`,
    FOLLOW: (id: string) => `/api/v1/investment/portfolios/${id}/follow`,
    UNFOLLOW: (id: string) => `/api/v1/investment/portfolios/${id}/unfollow`,
    COPY: (id: string) => `/api/v1/investment/portfolios/${id}/copy`,
  },

  // Investment - Assets
  ASSETS: {
    HOLDINGS: (portfolioId: string) => `/api/v1/investment/portfolios/${portfolioId}/holdings`,
    HOLDING_BY_ID: (portfolioId: string, holdingId: string) =>
      `/api/v1/investment/portfolios/${portfolioId}/holdings/${holdingId}`,
    PRICE: (symbol: string) => `/api/v1/investment/assets/${symbol}/price`,
    SEARCH: '/api/v1/investment/assets/search',
  },

  // Investment - Trades
  TRADES: {
    BASE: '/api/v1/investment/trades',
    BY_PORTFOLIO: (portfolioId: string) => `/api/v1/investment/portfolios/${portfolioId}/trades`,
    BY_ID: (id: string) => `/api/v1/investment/trades/${id}`,
  },

  // Investment - Watchlist
  WATCHLIST: {
    BASE: '/api/v1/investment/watchlist',
    BY_ID: (id: string) => `/api/v1/investment/watchlist/${id}`,
  },

  // Investment - Posts
  INVESTMENT_POSTS: {
    BASE: '/api/v1/investment/posts',
    BY_ID: (id: string) => `/api/v1/investment/posts/${id}`,
    FEED: '/api/v1/investment/posts/feed',
    LIKE: (id: string) => `/api/v1/investment/posts/${id}/like`,
    UNLIKE: (id: string) => `/api/v1/investment/posts/${id}/unlike`,
    VOTE: (id: string) => `/api/v1/investment/posts/${id}/vote`,
  },

  // Upload
  UPLOAD: {
    IMAGE: '/api/v1/upload/image',
    VIDEO: '/api/v1/upload/video',
    IMAGES: '/api/v1/upload/images',
  },
} as const;
