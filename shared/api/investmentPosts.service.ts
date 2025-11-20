import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  InvestmentPost,
  CreateInvestmentPostDto,
  UpdateInvestmentPostDto,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class InvestmentPostsService {
  async getInvestmentPosts(params?: PaginationParams): Promise<PaginatedResponse<InvestmentPost>> {
    return apiClient.get<PaginatedResponse<InvestmentPost>>(
      API_ENDPOINTS.INVESTMENT_POSTS.BASE,
      { params }
    );
  }

  async getInvestmentPostsFeed(params?: PaginationParams): Promise<PaginatedResponse<InvestmentPost>> {
    return apiClient.get<PaginatedResponse<InvestmentPost>>(
      API_ENDPOINTS.INVESTMENT_POSTS.FEED,
      { params }
    );
  }

  async getInvestmentPost(postId: string): Promise<InvestmentPost> {
    return apiClient.get<InvestmentPost>(API_ENDPOINTS.INVESTMENT_POSTS.BY_ID(postId));
  }

  async createInvestmentPost(data: CreateInvestmentPostDto): Promise<InvestmentPost> {
    return apiClient.post<InvestmentPost>(API_ENDPOINTS.INVESTMENT_POSTS.BASE, data);
  }

  async updateInvestmentPost(
    postId: string,
    data: UpdateInvestmentPostDto
  ): Promise<InvestmentPost> {
    return apiClient.put<InvestmentPost>(
      API_ENDPOINTS.INVESTMENT_POSTS.BY_ID(postId),
      data
    );
  }

  async deleteInvestmentPost(postId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.INVESTMENT_POSTS.BY_ID(postId));
  }

  async likeInvestmentPost(postId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.INVESTMENT_POSTS.LIKE(postId));
  }

  async unlikeInvestmentPost(postId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.INVESTMENT_POSTS.UNLIKE(postId));
  }

  async voteInvestmentPost(postId: string, vote: 'bullish' | 'bearish'): Promise<void> {
    await apiClient.post(API_ENDPOINTS.INVESTMENT_POSTS.VOTE(postId), { vote });
  }
}

export const investmentPostsService = new InvestmentPostsService();
