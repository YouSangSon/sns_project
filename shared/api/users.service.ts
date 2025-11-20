import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  User,
  UpdateUserDto,
  Post,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class UsersService {
  async getUserById(userId: string): Promise<User> {
    return apiClient.get<User>(API_ENDPOINTS.USERS.BY_ID(userId));
  }

  async getUserProfile(userId: string): Promise<User> {
    return apiClient.get<User>(API_ENDPOINTS.USERS.PROFILE(userId));
  }

  async updateProfile(userId: string, data: UpdateUserDto): Promise<User> {
    return apiClient.put<User>(API_ENDPOINTS.USERS.BY_ID(userId), data);
  }

  async getUserPosts(
    userId: string,
    params?: PaginationParams
  ): Promise<PaginatedResponse<Post>> {
    return apiClient.get<PaginatedResponse<Post>>(
      API_ENDPOINTS.USERS.POSTS(userId),
      { params }
    );
  }

  async getFollowers(
    userId: string,
    params?: PaginationParams
  ): Promise<PaginatedResponse<User>> {
    return apiClient.get<PaginatedResponse<User>>(
      API_ENDPOINTS.USERS.FOLLOWERS(userId),
      { params }
    );
  }

  async getFollowing(
    userId: string,
    params?: PaginationParams
  ): Promise<PaginatedResponse<User>> {
    return apiClient.get<PaginatedResponse<User>>(
      API_ENDPOINTS.USERS.FOLLOWING(userId),
      { params }
    );
  }

  async followUser(userId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.USERS.FOLLOW(userId));
  }

  async unfollowUser(userId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.USERS.UNFOLLOW(userId));
  }

  async searchUsers(query: string, params?: PaginationParams): Promise<PaginatedResponse<User>> {
    return apiClient.get<PaginatedResponse<User>>(
      API_ENDPOINTS.USERS.SEARCH,
      { params: { q: query, ...params } }
    );
  }

  async uploadProfilePhoto(file: File | Blob): Promise<string> {
    return apiClient.uploadFile(API_ENDPOINTS.UPLOAD.IMAGE, file, 'photo');
  }
}

export const usersService = new UsersService();
