import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  Comment,
  CreateCommentDto,
  UpdateCommentDto,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class CommentsService {
  // Get comments for a post
  async getPostComments(
    postId: string,
    params?: PaginationParams
  ): Promise<PaginatedResponse<Comment>> {
    return apiClient.get<PaginatedResponse<Comment>>(
      API_ENDPOINTS.POSTS.COMMENTS(postId),
      { params }
    );
  }

  // Get comment by ID
  async getCommentById(commentId: string): Promise<Comment> {
    return apiClient.get<Comment>(API_ENDPOINTS.COMMENTS.BY_ID(commentId));
  }

  // Create comment
  async createComment(data: CreateCommentDto): Promise<Comment> {
    return apiClient.post<Comment>(API_ENDPOINTS.COMMENTS.BASE, data);
  }

  // Update comment
  async updateComment(commentId: string, data: UpdateCommentDto): Promise<Comment> {
    return apiClient.put<Comment>(API_ENDPOINTS.COMMENTS.BY_ID(commentId), data);
  }

  // Delete comment
  async deleteComment(commentId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.COMMENTS.BY_ID(commentId));
  }

  // Like comment
  async likeComment(commentId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.COMMENTS.LIKE(commentId));
  }

  // Unlike comment
  async unlikeComment(commentId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.COMMENTS.UNLIKE(commentId));
  }

  // Get replies to a comment
  async getReplies(
    commentId: string,
    params?: PaginationParams
  ): Promise<PaginatedResponse<Comment>> {
    return apiClient.get<PaginatedResponse<Comment>>(
      `${API_ENDPOINTS.COMMENTS.BY_ID(commentId)}/replies`,
      { params }
    );
  }
}

export const commentsService = new CommentsService();
