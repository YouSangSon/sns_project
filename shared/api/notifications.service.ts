import { apiClient } from './client';
import { API_ENDPOINTS } from '../constants/api';
import type {
  Notification,
  PaginationParams,
  PaginatedResponse,
} from '../types';

export class NotificationsService {
  // Get notifications
  async getNotifications(params?: PaginationParams): Promise<PaginatedResponse<Notification>> {
    return apiClient.get<PaginatedResponse<Notification>>(
      API_ENDPOINTS.NOTIFICATIONS.BASE,
      { params }
    );
  }

  // Get unread notifications
  async getUnreadNotifications(): Promise<Notification[]> {
    return apiClient.get<Notification[]>(API_ENDPOINTS.NOTIFICATIONS.UNREAD);
  }

  // Mark notification as read
  async markAsRead(notificationId: string): Promise<void> {
    await apiClient.post(API_ENDPOINTS.NOTIFICATIONS.MARK_READ(notificationId));
  }

  // Mark all notifications as read
  async markAllAsRead(): Promise<void> {
    await apiClient.post(API_ENDPOINTS.NOTIFICATIONS.MARK_ALL_READ);
  }

  // Get unread count
  async getUnreadCount(): Promise<number> {
    try {
      const response = await apiClient.get<{ count: number }>('/api/v1/notifications/unread/count');
      return response.count;
    } catch (error) {
      return 0;
    }
  }
}

export const notificationsService = new NotificationsService();
