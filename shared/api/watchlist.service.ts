import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  WatchlistItem,
  CreateWatchlistItemDto,
  UpdateWatchlistItemDto,
  AssetPrice,
} from '../types';

export class WatchlistService {
  async getWatchlist(): Promise<WatchlistItem[]> {
    return apiClient.get<WatchlistItem[]>(API_ENDPOINTS.WATCHLIST.BASE);
  }

  async createWatchlistItem(data: CreateWatchlistItemDto): Promise<WatchlistItem> {
    return apiClient.post<WatchlistItem>(API_ENDPOINTS.WATCHLIST.BASE, data);
  }

  async updateWatchlistItem(
    watchlistId: string,
    data: UpdateWatchlistItemDto
  ): Promise<WatchlistItem> {
    return apiClient.put<WatchlistItem>(
      API_ENDPOINTS.WATCHLIST.BY_ID(watchlistId),
      data
    );
  }

  async deleteWatchlistItem(watchlistId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.WATCHLIST.BY_ID(watchlistId));
  }

  async getAssetPrice(symbol: string): Promise<AssetPrice> {
    return apiClient.get<AssetPrice>(API_ENDPOINTS.ASSETS.PRICE(symbol));
  }

  async searchAssets(query: string): Promise<AssetPrice[]> {
    return apiClient.get<AssetPrice[]>(API_ENDPOINTS.ASSETS.SEARCH, {
      params: { q: query },
    });
  }
}

export const watchlistService = new WatchlistService();
