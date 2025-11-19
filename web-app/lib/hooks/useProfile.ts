import { useQuery, useMutation, useQueryClient, useInfiniteQuery } from '@tanstack/react-query';
import { usersService } from '../../../shared/api';
import type { UpdateUserDto, PaginationParams } from '../../../shared/types';

// Query Keys
export const PROFILE_KEYS = {
  all: ['profile'] as const,
  details: () => [...PROFILE_KEYS.all, 'detail'] as const,
  detail: (userId: string) => [...PROFILE_KEYS.details(), userId] as const,
  posts: (userId: string) => [...PROFILE_KEYS.detail(userId), 'posts'] as const,
  followers: (userId: string) => [...PROFILE_KEYS.detail(userId), 'followers'] as const,
  following: (userId: string) => [...PROFILE_KEYS.detail(userId), 'following'] as const,
};

// Get user profile
export const useUserProfile = (userId: string) => {
  return useQuery({
    queryKey: PROFILE_KEYS.detail(userId),
    queryFn: () => usersService.getUserProfile(userId),
    enabled: !!userId,
  });
};

// Get user posts
export const useUserPosts = (userId: string, params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: [...PROFILE_KEYS.posts(userId), params],
    queryFn: ({ pageParam = 1 }) =>
      usersService.getUserPosts(userId, { ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
    enabled: !!userId,
  });
};

// Get followers
export const useFollowers = (userId: string, params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: [...PROFILE_KEYS.followers(userId), params],
    queryFn: ({ pageParam = 1 }) =>
      usersService.getFollowers(userId, { ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
    enabled: !!userId,
  });
};

// Get following
export const useFollowing = (userId: string, params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: [...PROFILE_KEYS.following(userId), params],
    queryFn: ({ pageParam = 1 }) =>
      usersService.getFollowing(userId, { ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
    enabled: !!userId,
  });
};

// Update profile
export const useUpdateProfile = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ userId, data }: { userId: string; data: UpdateUserDto }) =>
      usersService.updateProfile(userId, data),
    onSuccess: (data, variables) => {
      queryClient.invalidateQueries({ queryKey: PROFILE_KEYS.detail(variables.userId) });
    },
  });
};

// Follow user
export const useFollowUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (userId: string) => usersService.followUser(userId),
    onSuccess: (_, userId) => {
      queryClient.invalidateQueries({ queryKey: PROFILE_KEYS.detail(userId) });
      queryClient.invalidateQueries({ queryKey: PROFILE_KEYS.followers(userId) });
    },
  });
};

// Unfollow user
export const useUnfollowUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (userId: string) => usersService.unfollowUser(userId),
    onSuccess: (_, userId) => {
      queryClient.invalidateQueries({ queryKey: PROFILE_KEYS.detail(userId) });
      queryClient.invalidateQueries({ queryKey: PROFILE_KEYS.followers(userId) });
    },
  });
};
