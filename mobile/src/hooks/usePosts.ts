import { useInfiniteQuery, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert } from 'react-native';
import { postsService } from '../services/api';
import { MOCK_POSTS } from '@shared/api/mockData';
import type { Post, CreatePostDto, PaginationParams } from '@shared/types';

// Query Keys
export const POST_KEYS = {
  all: ['posts'] as const,
  lists: () => [...POST_KEYS.all, 'list'] as const,
  list: (params?: PaginationParams) => [...POST_KEYS.lists(), params] as const,
  details: () => [...POST_KEYS.all, 'detail'] as const,
  detail: (id: string) => [...POST_KEYS.details(), id] as const,
};

// Get feed posts
export const useFeedPosts = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: POST_KEYS.list(params),
    queryFn: async ({ pageParam = 1 }) => {
      try {
        return await postsService.getFeed({ ...params, page: pageParam });
      } catch (error) {
        console.log('📦 백엔드 없이 Mock 게시물 사용 중');
        return {
          data: MOCK_POSTS,
          total: MOCK_POSTS.length,
          page: pageParam,
          limit: 10,
          hasMore: false,
        };
      }
    },
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

// Get post by ID
export const usePost = (postId: string) => {
  return useQuery({
    queryKey: POST_KEYS.detail(postId),
    queryFn: async () => {
      try {
        return await postsService.getPostById(postId);
      } catch (error) {
        console.log('📦 백엔드 없이 Mock 게시물 사용 중');
        return MOCK_POSTS.find(p => p.postId === postId) || MOCK_POSTS[0];
      }
    },
    enabled: !!postId,
  });
};

// Create post
export const useCreatePost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreatePostDto) => postsService.createPost(data),
    onSuccess: () => {
      // Invalidate posts list
      queryClient.invalidateQueries({ queryKey: POST_KEYS.lists() });
      Alert.alert('Success', 'Post created successfully!');
    },
    onError: (error: any) => {
      Alert.alert(
        'Error',
        error.response?.data?.message || 'Failed to create post'
      );
    },
  });
};

// Delete post
export const useDeletePost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (postId: string) => postsService.deletePost(postId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: POST_KEYS.lists() });
      Alert.alert('Success', 'Post deleted successfully!');
    },
    onError: (error: any) => {
      Alert.alert(
        'Error',
        error.response?.data?.message || 'Failed to delete post'
      );
    },
  });
};

// Like post
export const useLikePost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (postId: string) => postsService.likePost(postId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: POST_KEYS.lists() });
    },
    onError: (error: any) => {
      console.error('Like post error:', error);
    },
  });
};

// Unlike post
export const useUnlikePost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (postId: string) => postsService.unlikePost(postId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: POST_KEYS.lists() });
    },
    onError: (error: any) => {
      console.error('Unlike post error:', error);
    },
  });
};
