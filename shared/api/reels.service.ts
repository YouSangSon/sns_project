import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  Reel,
  CreateReelDto,
  UpdateReelDto,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class ReelsService {
  // Get reels feed
  async getReelsFeed(params?: PaginationParams): Promise<PaginatedResponse<Reel>> {
    return apiClient.get<PaginatedResponse<Reel>>(
      API_ENDPOINTS.REELS.FEED,
      { params }
    );
  }

  // Get reel by ID
  async getReel(reelId: string): Promise<Reel> {
    return apiClient.get<Reel>(API_ENDPOINTS.REELS.BY_ID(reelId));
  }

  // Create reel
  async createReel(data: CreateReelDto): Promise<Reel> {
    return apiClient.post<Reel>(API_ENDPOINTS.REELS.BASE, data);
  }

  // Update reel
  async updateReel(reelId: string, data: UpdateReelDto): Promise<Reel> {
    return apiClient.put<Reel>(API_ENDPOINTS.REELS.BY_ID(reelId), data);
  }

  // Delete reel
  async deleteReel(reelId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.REELS.BY_ID(reelId));
  }

  // Like reel
  async likeReel(reelId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.REELS.LIKE(reelId));
  }

  // Unlike reel
  async unlikeReel(reelId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.REELS.UNLIKE(reelId));
  }

  // View reel
  async viewReel(reelId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.REELS.VIEW(reelId));
  }
}

export const reelsService = new ReelsService();
