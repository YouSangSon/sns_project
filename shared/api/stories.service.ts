import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  Story,
  CreateStoryDto,
  StoryViewer,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class StoriesService {
  // Get all stories from following users
  async getFollowingStories(params?: PaginationParams): Promise<PaginatedResponse<Story>> {
    return apiClient.get<PaginatedResponse<Story>>(
      API_ENDPOINTS.STORIES.FOLLOWING,
      { params }
    );
  }

  // Get stories by user
  async getUserStories(userId: string): Promise<Story[]> {
    return apiClient.get<Story[]>(API_ENDPOINTS.STORIES.BY_USER(userId));
  }

  // Get story by ID
  async getStory(storyId: string): Promise<Story> {
    return apiClient.get<Story>(API_ENDPOINTS.STORIES.BY_ID(storyId));
  }

  // Create story
  async createStory(data: CreateStoryDto): Promise<Story> {
    return apiClient.post<Story>(API_ENDPOINTS.STORIES.BASE, data);
  }

  // Delete story
  async deleteStory(storyId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.STORIES.BY_ID(storyId));
  }

  // Mark story as viewed
  async viewStory(storyId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.STORIES.VIEW(storyId));
  }

  // Get story viewers
  async getStoryViewers(storyId: string): Promise<StoryViewer[]> {
    return apiClient.get<StoryViewer[]>(API_ENDPOINTS.STORIES.VIEWERS(storyId));
  }
}

export const storiesService = new StoriesService();
