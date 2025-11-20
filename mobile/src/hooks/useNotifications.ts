import { useInfiniteQuery, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { notificationsService } from '@shared/api';
import type { PaginationParams } from '@shared/types';

// Query Keys
export const NOTIFICATION_KEYS = {
  all: ['notifications'] as const,
  lists: () => [...NOTIFICATION_KEYS.all, 'list'] as const,
  list: (params?: PaginationParams) => [...NOTIFICATION_KEYS.lists(), params] as const,
  unread: () => [...NOTIFICATION_KEYS.all, 'unread'] as const,
  unreadCount: () => [...NOTIFICATION_KEYS.all, 'unreadCount'] as const,
};

// Get notifications
export const useNotifications = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: NOTIFICATION_KEYS.list(params),
    queryFn: ({ pageParam = 1 }) =>
      notificationsService.getNotifications({ ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

// Get unread notifications
export const useUnreadNotifications = () => {
  return useQuery({
    queryKey: NOTIFICATION_KEYS.unread(),
    queryFn: () => notificationsService.getUnreadNotifications(),
    refetchInterval: 30000, // Refetch every 30 seconds
  });
};

// Get unread count
export const useUnreadCount = () => {
  return useQuery({
    queryKey: NOTIFICATION_KEYS.unreadCount(),
    queryFn: () => notificationsService.getUnreadCount(),
    refetchInterval: 30000, // Refetch every 30 seconds
  });
};

// Mark notification as read
export const useMarkAsRead = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (notificationId: string) => notificationsService.markAsRead(notificationId),
    onSuccess: () => {
      // Invalidate all notification queries
      queryClient.invalidateQueries({ queryKey: NOTIFICATION_KEYS.all });
    },
  });
};

// Mark all as read
export const useMarkAllAsRead = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => notificationsService.markAllAsRead(),
    onSuccess: () => {
      // Invalidate all notification queries
      queryClient.invalidateQueries({ queryKey: NOTIFICATION_KEYS.all });
    },
  });
};
