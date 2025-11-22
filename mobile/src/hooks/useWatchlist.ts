import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { watchlistService } from '@shared/api';
import { MOCK_WATCHLIST } from '@shared/api/investmentMockData';
import type { CreateWatchlistItemDto, UpdateWatchlistItemDto } from '@shared/types';

export const WATCHLIST_KEYS = {
  all: ['watchlist'] as const,
  list: () => [...WATCHLIST_KEYS.all, 'list'] as const,
  detail: (watchlistId: string) => [...WATCHLIST_KEYS.all, 'detail', watchlistId] as const,
};

export const useWatchlist = () => {
  return useQuery({
    queryKey: WATCHLIST_KEYS.list(),
    queryFn: async () => {
      try {
        return await watchlistService.getWatchlist();
      } catch (error) {
        console.log('📦 백엔드 없이 Mock 관심종목 사용 중');
        return {
          data: MOCK_WATCHLIST,
          total: MOCK_WATCHLIST.length,
          page: 1,
          limit: 20,
          hasMore: false,
        };
      }
    },
  });
};

export const useAddToWatchlist = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateWatchlistItemDto) => watchlistService.addToWatchlist(data),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: WATCHLIST_KEYS.list(),
      });
    },
  });
};

export const useRemoveFromWatchlist = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (watchlistId: string) => watchlistService.removeFromWatchlist(watchlistId),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: WATCHLIST_KEYS.list(),
      });
    },
  });
};

export const useUpdateWatchlistItem = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ watchlistId, data }: { watchlistId: string; data: UpdateWatchlistItemDto }) =>
      watchlistService.updateWatchlistItem(watchlistId, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: WATCHLIST_KEYS.detail(variables.watchlistId),
      });
      queryClient.invalidateQueries({
        queryKey: WATCHLIST_KEYS.list(),
      });
    },
  });
};
