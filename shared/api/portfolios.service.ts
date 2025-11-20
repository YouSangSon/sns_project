import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  Portfolio,
  CreatePortfolioDto,
  UpdatePortfolioDto,
  Holding,
  CreateHoldingDto,
  UpdateHoldingDto,
  PortfolioAnalytics,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class PortfoliosService {
  // Portfolios
  async getPortfolios(params?: PaginationParams): Promise<PaginatedResponse<Portfolio>> {
    return apiClient.get<PaginatedResponse<Portfolio>>(
      API_ENDPOINTS.PORTFOLIOS.BASE,
      { params }
    );
  }

  async getPortfolio(portfolioId: string): Promise<Portfolio> {
    return apiClient.get<Portfolio>(API_ENDPOINTS.PORTFOLIOS.BY_ID(portfolioId));
  }

  async getUserPortfolios(userId: string): Promise<Portfolio[]> {
    return apiClient.get<Portfolio[]>(API_ENDPOINTS.PORTFOLIOS.BY_USER(userId));
  }

  async getPublicPortfolios(params?: PaginationParams): Promise<PaginatedResponse<Portfolio>> {
    return apiClient.get<PaginatedResponse<Portfolio>>(
      API_ENDPOINTS.PORTFOLIOS.PUBLIC,
      { params }
    );
  }

  async createPortfolio(data: CreatePortfolioDto): Promise<Portfolio> {
    return apiClient.post<Portfolio>(API_ENDPOINTS.PORTFOLIOS.BASE, data);
  }

  async updatePortfolio(portfolioId: string, data: UpdatePortfolioDto): Promise<Portfolio> {
    return apiClient.put<Portfolio>(API_ENDPOINTS.PORTFOLIOS.BY_ID(portfolioId), data);
  }

  async deletePortfolio(portfolioId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.PORTFOLIOS.BY_ID(portfolioId));
  }

  async getPortfolioAnalytics(portfolioId: string): Promise<PortfolioAnalytics> {
    return apiClient.get<PortfolioAnalytics>(
      API_ENDPOINTS.PORTFOLIOS.ANALYTICS(portfolioId)
    );
  }

  async followPortfolio(portfolioId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.PORTFOLIOS.FOLLOW(portfolioId));
  }

  async unfollowPortfolio(portfolioId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.PORTFOLIOS.UNFOLLOW(portfolioId));
  }

  async copyPortfolio(portfolioId: string): Promise<Portfolio> {
    return apiClient.post<Portfolio>(API_ENDPOINTS.PORTFOLIOS.COPY(portfolioId));
  }

  // Holdings
  async getHoldings(portfolioId: string): Promise<Holding[]> {
    return apiClient.get<Holding[]>(API_ENDPOINTS.ASSETS.HOLDINGS(portfolioId));
  }

  async createHolding(portfolioId: string, data: CreateHoldingDto): Promise<Holding> {
    return apiClient.post<Holding>(API_ENDPOINTS.ASSETS.HOLDINGS(portfolioId), data);
  }

  async updateHolding(
    portfolioId: string,
    holdingId: string,
    data: UpdateHoldingDto
  ): Promise<Holding> {
    return apiClient.put<Holding>(
      API_ENDPOINTS.ASSETS.HOLDING_BY_ID(portfolioId, holdingId),
      data
    );
  }

  async deleteHolding(portfolioId: string, holdingId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.ASSETS.HOLDING_BY_ID(portfolioId, holdingId));
  }
}

export const portfoliosService = new PortfoliosService();
