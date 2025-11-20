// Re-export all investment-related hooks
export * from './usePortfolios';

import { useInfiniteQuery, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { tradesService, watchlistService, investmentPostsService } from '@shared/api';
import type {
  CreateTradeDto,
  CreateWatchlistItemDto,
  UpdateWatchlistItemDto,
  CreateInvestmentPostDto,
  UpdateInvestmentPostDto,
  PaginationParams,
} from '@shared/types';

// Trades Query Keys
export const TRADE_KEYS = {
  all: ['trades'] as const,
  lists: () => [...TRADE_KEYS.all, 'list'] as const,
  list: (params?: PaginationParams) => [...TRADE_KEYS.lists(), params] as const,
  portfolio: (portfolioId: string) => [...TRADE_KEYS.all, 'portfolio', portfolioId] as const,
  portfolioList: (portfolioId: string, params?: PaginationParams) =>
    [...TRADE_KEYS.portfolio(portfolioId), params] as const,
};

// Watchlist Query Keys
export const WATCHLIST_KEYS = {
  all: ['watchlist'] as const,
  list: () => [...WATCHLIST_KEYS.all, 'list'] as const,
};

// Investment Posts Query Keys
export const INVESTMENT_POST_KEYS = {
  all: ['investmentPosts'] as const,
  lists: () => [...INVESTMENT_POST_KEYS.all, 'list'] as const,
  list: (params?: PaginationParams) => [...INVESTMENT_POST_KEYS.lists(), params] as const,
  feed: () => [...INVESTMENT_POST_KEYS.all, 'feed'] as const,
  feedList: (params?: PaginationParams) => [...INVESTMENT_POST_KEYS.feed(), params] as const,
  detail: (postId: string) => [...INVESTMENT_POST_KEYS.all, 'detail', postId] as const,
};

// ====================
// TRADES HOOKS
// ====================

export const usePortfolioTrades = (portfolioId: string, params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: TRADE_KEYS.portfolioList(portfolioId, params),
    queryFn: ({ pageParam = 1 }) =>
      tradesService.getPortfolioTrades(portfolioId, { ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
    enabled: !!portfolioId,
  });
};

export const useCreateTrade = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateTradeDto) => tradesService.createTrade(data),
    onSuccess: (newTrade) => {
      queryClient.invalidateQueries({
        queryKey: TRADE_KEYS.portfolio(newTrade.portfolioId),
      });
    },
  });
};

// ====================
// WATCHLIST HOOKS
// ====================

export const useWatchlist = () => {
  return useQuery({
    queryKey: WATCHLIST_KEYS.list(),
    queryFn: () => watchlistService.getWatchlist(),
  });
};

export const useCreateWatchlistItem = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateWatchlistItemDto) => watchlistService.createWatchlistItem(data),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: WATCHLIST_KEYS.list(),
      });
    },
  });
};

export const useDeleteWatchlistItem = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (watchlistId: string) => watchlistService.deleteWatchlistItem(watchlistId),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: WATCHLIST_KEYS.list(),
      });
    },
  });
};

export const useSearchAssets = (query: string) => {
  return useQuery({
    queryKey: ['assets', 'search', query],
    queryFn: () => watchlistService.searchAssets(query),
    enabled: query.length > 0,
  });
};

// ====================
// INVESTMENT POSTS HOOKS
// ====================

export const useInvestmentPostsFeed = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: INVESTMENT_POST_KEYS.feedList(params),
    queryFn: ({ pageParam = 1 }) =>
      investmentPostsService.getInvestmentPostsFeed({ ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

export const useInvestmentPost = (postId: string) => {
  return useQuery({
    queryKey: INVESTMENT_POST_KEYS.detail(postId),
    queryFn: () => investmentPostsService.getInvestmentPost(postId),
    enabled: !!postId,
  });
};

export const useCreateInvestmentPost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateInvestmentPostDto) =>
      investmentPostsService.createInvestmentPost(data),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: INVESTMENT_POST_KEYS.feed(),
      });
    },
  });
};

export const useLikeInvestmentPost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (postId: string) => investmentPostsService.likeInvestmentPost(postId),
    onSuccess: (_, postId) => {
      queryClient.invalidateQueries({
        queryKey: INVESTMENT_POST_KEYS.detail(postId),
      });
    },
  });
};

export const useVoteInvestmentPost = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ postId, vote }: { postId: string; vote: 'bullish' | 'bearish' }) =>
      investmentPostsService.voteInvestmentPost(postId, vote),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: INVESTMENT_POST_KEYS.detail(variables.postId),
      });
    },
  });
};
