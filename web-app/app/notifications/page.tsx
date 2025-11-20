'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useAuthStore } from '../../lib/stores/authStore';
import {
  useNotifications,
  useMarkAsRead,
  useMarkAllAsRead,
} from '../../lib/hooks/useNotifications';
import { Loading } from '../../components/ui';
import type { Notification } from '@shared/types';

export default function NotificationsPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
  } = useNotifications({ limit: 20 });

  const markAsReadMutation = useMarkAsRead();
  const markAllAsReadMutation = useMarkAllAsRead();

  const notifications = data?.pages.flatMap((page) => page.data) || [];

  // Redirect if not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  const handleNotificationClick = async (notification: Notification) => {
    // Mark as read
    if (!notification.isRead) {
      await markAsReadMutation.mutateAsync(notification.notificationId);
    }

    // Navigate based on notification type
    if (notification.relatedPostId) {
      router.push(`/posts/${notification.relatedPostId}`);
    } else if (notification.actorId && notification.type === 'follow') {
      // router.push(`/users/${notification.actorId}`);
      console.log('Navigate to user profile:', notification.actorId);
    }
  };

  const handleMarkAllAsRead = async () => {
    try {
      await markAllAsReadMutation.mutateAsync();
    } catch (error) {
      console.error('Error marking all as read:', error);
    }
  };

  const getNotificationIcon = (type: string) => {
    switch (type) {
      case 'like':
        return (
          <div className="w-12 h-12 flex items-center justify-center bg-red-100 rounded-full">
            <svg className="w-6 h-6 text-red-500" fill="currentColor" viewBox="0 0 20 20">
              <path
                fillRule="evenodd"
                d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z"
                clipRule="evenodd"
              />
            </svg>
          </div>
        );
      case 'comment':
        return (
          <div className="w-12 h-12 flex items-center justify-center bg-blue-100 rounded-full">
            <svg className="w-6 h-6 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
              <path d="M2 5a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H4a2 2 0 01-2-2V5zm3.293 1.293a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 01-1.414-1.414L7.586 10 5.293 7.707a1 1 0 010-1.414z" />
            </svg>
          </div>
        );
      case 'follow':
        return (
          <div className="w-12 h-12 flex items-center justify-center bg-green-100 rounded-full">
            <svg className="w-6 h-6 text-green-500" fill="currentColor" viewBox="0 0 20 20">
              <path d="M8 9a3 3 0 100-6 3 3 0 000 6zM8 11a6 6 0 016 6H2a6 6 0 016-6zM16 7a1 1 0 10-2 0v1h-1a1 1 0 100 2h1v1a1 1 0 102 0v-1h1a1 1 0 100-2h-1V7z" />
            </svg>
          </div>
        );
      default:
        return (
          <div className="w-12 h-12 flex items-center justify-center bg-gray-100 rounded-full">
            <svg className="w-6 h-6 text-gray-500" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10 2a6 6 0 00-6 6v3.586l-.707.707A1 1 0 004 14h12a1 1 0 00.707-1.707L16 11.586V8a6 6 0 00-6-6z" />
            </svg>
          </div>
        );
    }
  };

  const formatTimestamp = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - new Date(date).getTime();
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 7) {
      return new Date(date).toLocaleDateString();
    } else if (days > 0) {
      return `${days}d ago`;
    } else if (hours > 0) {
      return `${hours}h ago`;
    } else if (minutes > 0) {
      return `${minutes}m ago`;
    } else {
      return 'Just now';
    }
  };

  const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
    const { scrollTop, clientHeight, scrollHeight } = e.currentTarget;
    if (
      scrollHeight - scrollTop <= clientHeight * 1.5 &&
      hasNextPage &&
      !isFetchingNextPage
    ) {
      fetchNextPage();
    }
  };

  if (!isAuthenticated || isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <Loading size="lg" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-300 sticky top-0 z-10">
        <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
          <button
            onClick={() => router.back()}
            className="p-2 hover:bg-gray-100 rounded-full"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M10 19l-7-7m0 0l7-7m-7 7h18"
              />
            </svg>
          </button>
          <h1 className="text-xl font-bold">Notifications</h1>
          {notifications.some((n) => !n.isRead) && (
            <button
              onClick={handleMarkAllAsRead}
              disabled={markAllAsReadMutation.isPending}
              className="text-sm font-semibold text-blue-500 hover:text-blue-600"
            >
              Mark all read
            </button>
          )}
          {!notifications.some((n) => !n.isRead) && <div className="w-24" />}
        </div>
      </header>

      {/* Main Content */}
      <main
        className="max-w-2xl mx-auto overflow-y-auto"
        onScroll={handleScroll}
        style={{ maxHeight: 'calc(100vh - 64px)' }}
      >
        <div className="bg-white rounded-lg border border-gray-300 overflow-hidden">
          {notifications.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20">
              <svg className="w-16 h-16 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
                />
              </svg>
              <p className="text-lg font-semibold text-gray-700 mb-2">No notifications yet</p>
              <p className="text-sm text-gray-500 text-center max-w-sm">
                When someone likes, comments, or follows you, you'll see it here
              </p>
            </div>
          ) : (
            <>
              {notifications.map((notification) => (
                <button
                  key={notification.notificationId}
                  onClick={() => handleNotificationClick(notification)}
                  className={`w-full flex items-start gap-3 p-4 hover:bg-gray-50 transition-colors border-b border-gray-200 last:border-b-0 ${
                    !notification.isRead ? 'bg-blue-50' : ''
                  }`}
                >
                  {notification.actorPhotoUrl ? (
                    <div className="relative w-12 h-12 flex-shrink-0">
                      <Image
                        src={notification.actorPhotoUrl}
                        alt={notification.actorUsername || 'User'}
                        fill
                        className="rounded-full object-cover"
                      />
                    </div>
                  ) : (
                    getNotificationIcon(notification.type)
                  )}

                  <div className="flex-1 text-left">
                    <p className="text-sm">
                      {notification.actorUsername && (
                        <span className="font-semibold">{notification.actorUsername} </span>
                      )}
                      {notification.message}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      {formatTimestamp(notification.createdAt)}
                    </p>
                  </div>

                  {!notification.isRead && (
                    <div className="w-2 h-2 bg-blue-500 rounded-full flex-shrink-0 mt-2" />
                  )}
                </button>
              ))}

              {isFetchingNextPage && (
                <div className="flex justify-center py-4">
                  <Loading />
                </div>
              )}
            </>
          )}
        </div>
      </main>
    </div>
  );
}
