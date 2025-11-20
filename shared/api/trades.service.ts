import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  Trade,
  CreateTradeDto,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class TradesService {
  async getTrades(params?: PaginationParams): Promise<PaginatedResponse<Trade>> {
    return apiClient.get<PaginatedResponse<Trade>>(
      API_ENDPOINTS.TRADES.BASE,
      { params }
    );
  }

  async getPortfolioTrades(
    portfolioId: string,
    params?: PaginationParams
  ): Promise<PaginatedResponse<Trade>> {
    return apiClient.get<PaginatedResponse<Trade>>(
      API_ENDPOINTS.TRADES.BY_PORTFOLIO(portfolioId),
      { params }
    );
  }

  async getTrade(tradeId: string): Promise<Trade> {
    return apiClient.get<Trade>(API_ENDPOINTS.TRADES.BY_ID(tradeId));
  }

  async createTrade(data: CreateTradeDto): Promise<Trade> {
    return apiClient.post<Trade>(API_ENDPOINTS.TRADES.BASE, data);
  }

  async deleteTrade(tradeId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.TRADES.BY_ID(tradeId));
  }
}

export const tradesService = new TradesService();
