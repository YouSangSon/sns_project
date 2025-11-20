import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  Message,
  Conversation,
  CreateMessageDto,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class MessagesService {
  // Get all conversations
  async getConversations(params?: PaginationParams): Promise<PaginatedResponse<Conversation>> {
    return apiClient.get<PaginatedResponse<Conversation>>(
      API_ENDPOINTS.MESSAGES.CONVERSATIONS,
      { params }
    );
  }

  // Get messages in a conversation
  async getMessages(
    conversationId: string,
    params?: PaginationParams
  ): Promise<PaginatedResponse<Message>> {
    return apiClient.get<PaginatedResponse<Message>>(
      API_ENDPOINTS.MESSAGES.BY_CONVERSATION(conversationId),
      { params }
    );
  }

  // Send a message
  async sendMessage(data: CreateMessageDto): Promise<Message> {
    return apiClient.post<Message>(API_ENDPOINTS.MESSAGES.SEND, data);
  }

  // Mark message as read
  async markAsRead(messageId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.MESSAGES.MARK_READ(messageId));
  }

  // Mark all messages in a conversation as read
  async markConversationAsRead(conversationId: string): Promise<void> {
    // Get all unread messages in the conversation and mark them as read
    const messages = await this.getMessages(conversationId, { limit: 100 });
    const unreadMessages = messages.data.filter((msg) => !msg.isRead);

    await Promise.all(
      unreadMessages.map((msg) => this.markAsRead(msg.messageId))
    );
  }

  // Get unread message count
  async getUnreadCount(): Promise<number> {
    try {
      const response = await apiClient.get<{ count: number }>(
        '/api/v1/messages/unread/count'
      );
      return response.count;
    } catch (error) {
      return 0;
    }
  }
}

export const messagesService = new MessagesService();
