import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  Bookmark,
  CreateBookmarkDto,
  BookmarkType,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class BookmarksService {
  // Get all bookmarks
  async getBookmarks(params?: PaginationParams): Promise<PaginatedResponse<Bookmark>> {
    return apiClient.get<PaginatedResponse<Bookmark>>(
      API_ENDPOINTS.BOOKMARKS.BASE,
      { params }
    );
  }

  // Get bookmarks by type
  async getBookmarksByType(
    type: BookmarkType,
    params?: PaginationParams
  ): Promise<PaginatedResponse<Bookmark>> {
    return apiClient.get<PaginatedResponse<Bookmark>>(
      API_ENDPOINTS.BOOKMARKS.BY_TYPE(type),
      { params }
    );
  }

  // Create bookmark
  async createBookmark(data: CreateBookmarkDto): Promise<Bookmark> {
    return apiClient.post<Bookmark>(API_ENDPOINTS.BOOKMARKS.CREATE, data);
  }

  // Delete bookmark
  async deleteBookmark(bookmarkId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.BOOKMARKS.DELETE(bookmarkId));
  }

  // Check if content is bookmarked
  async isBookmarked(contentId: string, type: BookmarkType): Promise<boolean> {
    try {
      const response = await apiClient.get<{ bookmarked: boolean }>(
        `/api/v1/bookmarks/check`,
        { params: { contentId, type } }
      );
      return response.bookmarked;
    } catch (error) {
      return false;
    }
  }
}

export const bookmarksService = new BookmarksService();
