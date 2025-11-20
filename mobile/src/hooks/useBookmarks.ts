import { useInfiniteQuery, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { bookmarksService } from '../../../shared/api';
import type { CreateBookmarkDto, BookmarkType, PaginationParams } from '../../../shared/types';

// Query Keys
export const BOOKMARK_KEYS = {
  all: ['bookmarks'] as const,
  lists: () => [...BOOKMARK_KEYS.all, 'list'] as const,
  list: (type?: BookmarkType, params?: PaginationParams) =>
    [...BOOKMARK_KEYS.lists(), type, params] as const,
  check: (contentId: string, type: BookmarkType) =>
    [...BOOKMARK_KEYS.all, 'check', contentId, type] as const,
};

// Get all bookmarks
export const useBookmarks = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: BOOKMARK_KEYS.list(undefined, params),
    queryFn: ({ pageParam = 1 }) =>
      bookmarksService.getBookmarks({ ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

// Get bookmarks by type
export const useBookmarksByType = (type: BookmarkType, params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: BOOKMARK_KEYS.list(type, params),
    queryFn: ({ pageParam = 1 }) =>
      bookmarksService.getBookmarksByType(type, { ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

// Check if content is bookmarked
export const useIsBookmarked = (contentId: string, type: BookmarkType) => {
  return useQuery({
    queryKey: BOOKMARK_KEYS.check(contentId, type),
    queryFn: () => bookmarksService.isBookmarked(contentId, type),
    enabled: !!contentId && !!type,
  });
};

// Create bookmark
export const useCreateBookmark = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateBookmarkDto) => bookmarksService.createBookmark(data),
    onSuccess: (newBookmark) => {
      // Invalidate bookmarks list
      queryClient.invalidateQueries({
        queryKey: BOOKMARK_KEYS.lists(),
      });

      // Update check query
      queryClient.setQueryData(
        BOOKMARK_KEYS.check(newBookmark.contentId, newBookmark.type),
        true
      );
    },
  });
};

// Delete bookmark
export const useDeleteBookmark = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ bookmarkId, contentId, type }: { bookmarkId: string; contentId: string; type: BookmarkType }) =>
      bookmarksService.deleteBookmark(bookmarkId),
    onSuccess: (_, variables) => {
      // Invalidate bookmarks list
      queryClient.invalidateQueries({
        queryKey: BOOKMARK_KEYS.lists(),
      });

      // Update check query
      queryClient.setQueryData(
        BOOKMARK_KEYS.check(variables.contentId, variables.type),
        false
      );
    },
  });
};

// Toggle bookmark
export const useToggleBookmark = () => {
  const createMutation = useCreateBookmark();
  const deleteMutation = useDeleteBookmark();

  return {
    toggleBookmark: async (
      isBookmarked: boolean,
      bookmarkId: string | null,
      contentId: string,
      type: BookmarkType
    ) => {
      if (isBookmarked && bookmarkId) {
        await deleteMutation.mutateAsync({ bookmarkId, contentId, type });
      } else {
        await createMutation.mutateAsync({ contentId, type });
      }
    },
    isPending: createMutation.isPending || deleteMutation.isPending,
  };
};
