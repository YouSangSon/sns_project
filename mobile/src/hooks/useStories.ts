import { useInfiniteQuery, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { storiesService } from '../../../shared/api';
import type { CreateStoryDto, PaginationParams } from '../../../shared/types';

// Query Keys
export const STORY_KEYS = {
  all: ['stories'] as const,
  following: () => [...STORY_KEYS.all, 'following'] as const,
  followingList: (params?: PaginationParams) =>
    [...STORY_KEYS.following(), params] as const,
  user: (userId: string) => [...STORY_KEYS.all, 'user', userId] as const,
  detail: (storyId: string) => [...STORY_KEYS.all, 'detail', storyId] as const,
  viewers: (storyId: string) => [...STORY_KEYS.all, 'viewers', storyId] as const,
};

// Get following stories
export const useFollowingStories = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: STORY_KEYS.followingList(params),
    queryFn: ({ pageParam = 1 }) =>
      storiesService.getFollowingStories({ ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

// Get user stories
export const useUserStories = (userId: string) => {
  return useQuery({
    queryKey: STORY_KEYS.user(userId),
    queryFn: () => storiesService.getUserStories(userId),
    enabled: !!userId,
  });
};

// Get story detail
export const useStory = (storyId: string) => {
  return useQuery({
    queryKey: STORY_KEYS.detail(storyId),
    queryFn: () => storiesService.getStory(storyId),
    enabled: !!storyId,
  });
};

// Get story viewers
export const useStoryViewers = (storyId: string) => {
  return useQuery({
    queryKey: STORY_KEYS.viewers(storyId),
    queryFn: () => storiesService.getStoryViewers(storyId),
    enabled: !!storyId,
  });
};

// Create story
export const useCreateStory = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateStoryDto) => storiesService.createStory(data),
    onSuccess: () => {
      // Invalidate following stories list
      queryClient.invalidateQueries({
        queryKey: STORY_KEYS.following(),
      });
    },
  });
};

// Delete story
export const useDeleteStory = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (storyId: string) => storiesService.deleteStory(storyId),
    onSuccess: () => {
      // Invalidate all story queries
      queryClient.invalidateQueries({
        queryKey: STORY_KEYS.all,
      });
    },
  });
};

// View story
export const useViewStory = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (storyId: string) => storiesService.viewStory(storyId),
    onSuccess: (_, storyId) => {
      // Invalidate story detail
      queryClient.invalidateQueries({
        queryKey: STORY_KEYS.detail(storyId),
      });
      // Invalidate story viewers
      queryClient.invalidateQueries({
        queryKey: STORY_KEYS.viewers(storyId),
      });
    },
  });
};
