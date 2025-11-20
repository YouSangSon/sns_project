import { useInfiniteQuery, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { reelsService } from '@shared/api';
import type { CreateReelDto, UpdateReelDto, PaginationParams } from '@shared/types';

// Query Keys
export const REEL_KEYS = {
  all: ['reels'] as const,
  feed: () => [...REEL_KEYS.all, 'feed'] as const,
  feedList: (params?: PaginationParams) =>
    [...REEL_KEYS.feed(), params] as const,
  detail: (reelId: string) => [...REEL_KEYS.all, 'detail', reelId] as const,
};

// Get reels feed
export const useReelsFeed = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: REEL_KEYS.feedList(params),
    queryFn: ({ pageParam = 1 }) =>
      reelsService.getReelsFeed({ ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

// Get reel detail
export const useReel = (reelId: string) => {
  return useQuery({
    queryKey: REEL_KEYS.detail(reelId),
    queryFn: () => reelsService.getReel(reelId),
    enabled: !!reelId,
  });
};

// Create reel
export const useCreateReel = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateReelDto) => reelsService.createReel(data),
    onSuccess: () => {
      // Invalidate reels feed
      queryClient.invalidateQueries({
        queryKey: REEL_KEYS.feed(),
      });
    },
  });
};

// Update reel
export const useUpdateReel = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ reelId, data }: { reelId: string; data: UpdateReelDto }) =>
      reelsService.updateReel(reelId, data),
    onSuccess: (_, variables) => {
      // Invalidate reel detail
      queryClient.invalidateQueries({
        queryKey: REEL_KEYS.detail(variables.reelId),
      });
      // Invalidate reels feed
      queryClient.invalidateQueries({
        queryKey: REEL_KEYS.feed(),
      });
    },
  });
};

// Delete reel
export const useDeleteReel = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (reelId: string) => reelsService.deleteReel(reelId),
    onSuccess: () => {
      // Invalidate all reel queries
      queryClient.invalidateQueries({
        queryKey: REEL_KEYS.all,
      });
    },
  });
};

// Like reel
export const useLikeReel = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (reelId: string) => reelsService.likeReel(reelId),
    onSuccess: (_, reelId) => {
      // Invalidate reel detail
      queryClient.invalidateQueries({
        queryKey: REEL_KEYS.detail(reelId),
      });
      // Invalidate reels feed
      queryClient.invalidateQueries({
        queryKey: REEL_KEYS.feed(),
      });
    },
  });
};

// Unlike reel
export const useUnlikeReel = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (reelId: string) => reelsService.unlikeReel(reelId),
    onSuccess: (_, reelId) => {
      // Invalidate reel detail
      queryClient.invalidateQueries({
        queryKey: REEL_KEYS.detail(reelId),
      });
      // Invalidate reels feed
      queryClient.invalidateQueries({
        queryKey: REEL_KEYS.feed(),
      });
    },
  });
};

// View reel
export const useViewReel = () => {
  return useMutation({
    mutationFn: (reelId: string) => reelsService.viewReel(reelId),
  });
};

// Toggle like
export const useToggleLikeReel = () => {
  const likeMutation = useLikeReel();
  const unlikeMutation = useUnlikeReel();

  return {
    toggleLike: async (reelId: string, isLiked: boolean) => {
      if (isLiked) {
        await unlikeMutation.mutateAsync(reelId);
      } else {
        await likeMutation.mutateAsync(reelId);
      }
    },
    isPending: likeMutation.isPending || unlikeMutation.isPending,
  };
};
