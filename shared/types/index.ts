// Core types
export * from './user';
export * from './post';
export * from './comment';
export * from './story';
export * from './message';
export * from './notification';
export * from './reel';
export * from './bookmark';

// Investment types
export * from './investment';

// Common types
export interface PaginationParams {
  page?: number;
  limit?: number;
  cursor?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  hasMore: boolean;
  nextCursor?: string;
  total?: number;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface ApiError {
  code: string;
  message: string;
  details?: any;
}
