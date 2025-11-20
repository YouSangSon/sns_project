import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  Post,
  CreatePostDto,
  UpdatePostDto,
  Comment,
  CreateCommentDto,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class PostsService {
  async createPost(data: CreatePostDto): Promise<Post> {
    return apiClient.post<Post>(API_ENDPOINTS.POSTS.BASE, data);
  }

  async getPostById(postId: string): Promise<Post> {
    return apiClient.get<Post>(API_ENDPOINTS.POSTS.BY_ID(postId));
  }

  async updatePost(postId: string, data: UpdatePostDto): Promise<Post> {
    return apiClient.put<Post>(API_ENDPOINTS.POSTS.BY_ID(postId), data);
  }

  async deletePost(postId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.POSTS.BY_ID(postId));
  }

  async getFeed(params?: PaginationParams): Promise<PaginatedResponse<Post>> {
    return apiClient.get<PaginatedResponse<Post>>(
      API_ENDPOINTS.POSTS.FEED,
      { params }
    );
  }

  async likePost(postId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.POSTS.LIKE(postId));
  }

  async unlikePost(postId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.POSTS.UNLIKE(postId));
  }

  async getPostComments(
    postId: string,
    params?: PaginationParams
  ): Promise<PaginatedResponse<Comment>> {
    return apiClient.get<PaginatedResponse<Comment>>(
      API_ENDPOINTS.POSTS.COMMENTS(postId),
      { params }
    );
  }

  async createComment(data: CreateCommentDto): Promise<Comment> {
    return apiClient.post<Comment>(API_ENDPOINTS.COMMENTS.BASE, data);
  }

  async deleteComment(commentId: string): Promise<void> {
    await apiClient.delete(API_ENDPOINTS.COMMENTS.BY_ID(commentId));
  }

  async likeComment(commentId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.COMMENTS.LIKE(commentId));
  }

  async unlikeComment(commentId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.COMMENTS.UNLIKE(commentId));
  }

  async uploadImages(files: (File | Blob)[]): Promise<string[]> {
    return apiClient.uploadFiles(API_ENDPOINTS.UPLOAD.IMAGES, files, 'images');
  }

  async uploadImage(file: File | Blob): Promise<string> {
    return apiClient.uploadFile(API_ENDPOINTS.UPLOAD.IMAGE, file, 'image');
  }
}

export const postsService = new PostsService();
