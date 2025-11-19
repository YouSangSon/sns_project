import { useInfiniteQuery, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { postsService } from '../../../shared/api';
import type { CreatePostDto, PaginationParams } from '../../../shared/types';

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
    queryFn: ({ pageParam = 1 }) =>
      postsService.getFeed({ ...params, page: pageParam }),
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
    queryFn: () => postsService.getPostById(postId),
    enabled: !!postId,
  });
};

// Create post
export const useCreatePost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreatePostDto) => postsService.createPost(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: POST_KEYS.lists() });
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
  });
};
