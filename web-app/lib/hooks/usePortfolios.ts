import { useInfiniteQuery, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { portfoliosService } from '@shared/api';
import {
  MOCK_PORTFOLIOS,
  MOCK_HOLDINGS,
  MOCK_PORTFOLIO_ANALYTICS,
} from '@shared/api/investmentMockData';
import type {
  CreatePortfolioDto,
  UpdatePortfolioDto,
  CreateHoldingDto,
  UpdateHoldingDto,
  PaginationParams,
} from '@shared/types';

// Query Keys
export const PORTFOLIO_KEYS = {
  all: ['portfolios'] as const,
  lists: () => [...PORTFOLIO_KEYS.all, 'list'] as const,
  list: (params?: PaginationParams) => [...PORTFOLIO_KEYS.lists(), params] as const,
  public: () => [...PORTFOLIO_KEYS.all, 'public'] as const,
  publicList: (params?: PaginationParams) => [...PORTFOLIO_KEYS.public(), params] as const,
  user: (userId: string) => [...PORTFOLIO_KEYS.all, 'user', userId] as const,
  detail: (portfolioId: string) => [...PORTFOLIO_KEYS.all, 'detail', portfolioId] as const,
  analytics: (portfolioId: string) => [...PORTFOLIO_KEYS.all, 'analytics', portfolioId] as const,
  holdings: (portfolioId: string) => [...PORTFOLIO_KEYS.all, 'holdings', portfolioId] as const,
};

// Get portfolios
export const usePortfolios = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: PORTFOLIO_KEYS.list(params),
    queryFn: async ({ pageParam = 1 }) => {
      try {
        return await portfoliosService.getPortfolios({ ...params, page: pageParam });
      } catch (error) {
        console.log('📦 백엔드 없이 Mock 데이터 사용 중');
        return {
          data: MOCK_PORTFOLIOS,
          total: MOCK_PORTFOLIOS.length,
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

// Get public portfolios
export const usePublicPortfolios = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: PORTFOLIO_KEYS.publicList(params),
    queryFn: ({ pageParam = 1 }) =>
      portfoliosService.getPublicPortfolios({ ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

// Get user portfolios
export const useUserPortfolios = (userId: string) => {
  return useQuery({
    queryKey: PORTFOLIO_KEYS.user(userId),
    queryFn: () => portfoliosService.getUserPortfolios(userId),
    enabled: !!userId,
  });
};

// Get portfolio detail
export const usePortfolio = (portfolioId: string) => {
  return useQuery({
    queryKey: PORTFOLIO_KEYS.detail(portfolioId),
    queryFn: async () => {
      try {
        return await portfoliosService.getPortfolio(portfolioId);
      } catch (error) {
        console.log('📦 백엔드 없이 Mock 포트폴리오 사용 중');
        return MOCK_PORTFOLIOS.find(p => p.portfolioId === portfolioId) || MOCK_PORTFOLIOS[0];
      }
    },
    enabled: !!portfolioId,
  });
};

// Get portfolio analytics
export const usePortfolioAnalytics = (portfolioId: string) => {
  return useQuery({
    queryKey: PORTFOLIO_KEYS.analytics(portfolioId),
    queryFn: async () => {
      try {
        return await portfoliosService.getPortfolioAnalytics(portfolioId);
      } catch (error) {
        console.log('📦 백엔드 없이 Mock 분석 데이터 사용 중');
        return MOCK_PORTFOLIO_ANALYTICS[portfolioId] || MOCK_PORTFOLIO_ANALYTICS['mock-portfolio-1'];
      }
    },
    enabled: !!portfolioId,
  });
};

// Get holdings (usePortfolioHoldings alias)
export const usePortfolioHoldings = (portfolioId: string) => {
  return useQuery({
    queryKey: PORTFOLIO_KEYS.holdings(portfolioId),
    queryFn: async () => {
      try {
        return await portfoliosService.getHoldings(portfolioId);
      } catch (error) {
        console.log('📦 백엔드 없이 Mock 보유종목 사용 중');
        return MOCK_HOLDINGS[portfolioId] || MOCK_HOLDINGS['mock-portfolio-1'];
      }
    },
    enabled: !!portfolioId,
  });
};

// Backward compatibility
export const useHoldings = usePortfolioHoldings;

// Create portfolio
export const useCreatePortfolio = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreatePortfolioDto) => portfoliosService.createPortfolio(data),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.lists(),
      });
    },
  });
};

// Update portfolio
export const useUpdatePortfolio = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ portfolioId, data }: { portfolioId: string; data: UpdatePortfolioDto }) =>
      portfoliosService.updatePortfolio(portfolioId, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.detail(variables.portfolioId),
      });
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.lists(),
      });
    },
  });
};

// Delete portfolio
export const useDeletePortfolio = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (portfolioId: string) => portfoliosService.deletePortfolio(portfolioId),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.all,
      });
    },
  });
};

// Follow portfolio
export const useFollowPortfolio = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (portfolioId: string) => portfoliosService.followPortfolio(portfolioId),
    onSuccess: (_, portfolioId) => {
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.detail(portfolioId),
      });
    },
  });
};

// Unfollow portfolio
export const useUnfollowPortfolio = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (portfolioId: string) => portfoliosService.unfollowPortfolio(portfolioId),
    onSuccess: (_, portfolioId) => {
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.detail(portfolioId),
      });
    },
  });
};

// Copy portfolio
export const useCopyPortfolio = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (portfolioId: string) => portfoliosService.copyPortfolio(portfolioId),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.lists(),
      });
    },
  });
};

// Create holding
export const useCreateHolding = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ portfolioId, data }: { portfolioId: string; data: CreateHoldingDto }) =>
      portfoliosService.createHolding(portfolioId, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.holdings(variables.portfolioId),
      });
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.analytics(variables.portfolioId),
      });
    },
  });
};

// Update holding
export const useUpdateHolding = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      portfolioId,
      holdingId,
      data,
    }: {
      portfolioId: string;
      holdingId: string;
      data: UpdateHoldingDto;
    }) => portfoliosService.updateHolding(portfolioId, holdingId, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.holdings(variables.portfolioId),
      });
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.analytics(variables.portfolioId),
      });
    },
  });
};

// Delete holding
export const useDeleteHolding = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ portfolioId, holdingId }: { portfolioId: string; holdingId: string }) =>
      portfoliosService.deleteHolding(portfolioId, holdingId),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.holdings(variables.portfolioId),
      });
      queryClient.invalidateQueries({
        queryKey: PORTFOLIO_KEYS.analytics(variables.portfolioId),
      });
    },
  });
};
