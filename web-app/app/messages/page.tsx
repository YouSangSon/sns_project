'use client';

import React from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useAuthStore } from '../../lib/stores/authStore';
import { useConversations } from '../../lib/hooks/useMessages';
import { Loading } from '../../components/ui';
import type { Conversation } from '@shared/types';

export default function MessagesPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
  } = useConversations({ limit: 20 });

  const conversations = data?.pages.flatMap((page) => page.data) || [];

  React.useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  const handleConversationClick = (conversation: Conversation) => {
    router.push(`/messages/${conversation.conversationId}`);
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
      return `${days}d`;
    } else if (hours > 0) {
      return `${hours}h`;
    } else if (minutes > 0) {
      return `${minutes}m`;
    } else {
      return 'now';
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
          <h1 className="text-xl font-bold">Messages</h1>
          <button className="p-2 hover:bg-gray-100 rounded-full">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 4v16m8-8H4"
              />
            </svg>
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main
        className="max-w-2xl mx-auto overflow-y-auto"
        onScroll={handleScroll}
        style={{ maxHeight: 'calc(100vh - 64px)' }}
      >
        <div className="bg-white rounded-lg border border-gray-300 overflow-hidden">
          {conversations.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20">
              <svg className="w-16 h-16 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                />
              </svg>
              <p className="text-lg font-semibold text-gray-700 mb-2">No messages yet</p>
              <p className="text-sm text-gray-500 text-center max-w-sm">
                Start a conversation by searching for users
              </p>
            </div>
          ) : (
            <>
              {conversations.map((conversation) => {
                const otherParticipant = conversation.participantDetails[0];

                return (
                  <button
                    key={conversation.conversationId}
                    onClick={() => handleConversationClick(conversation)}
                    className="w-full flex items-center gap-3 p-4 hover:bg-gray-50 transition-colors border-b border-gray-200 last:border-b-0"
                  >
                    <div className="relative flex-shrink-0">
                      {otherParticipant.photoUrl ? (
                        <div className="relative w-14 h-14">
                          <Image
                            src={otherParticipant.photoUrl}
                            alt={otherParticipant.username}
                            fill
                            className="rounded-full object-cover"
                          />
                        </div>
                      ) : (
                        <div className="w-14 h-14 rounded-full bg-gray-200 flex items-center justify-center">
                          <svg className="w-8 h-8 text-gray-500" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                          </svg>
                        </div>
                      )}
                      {conversation.unreadCount > 0 && (
                        <div className="absolute bottom-0 right-0 w-4 h-4 bg-blue-500 rounded-full border-2 border-white" />
                      )}
                    </div>

                    <div className="flex-1 text-left min-w-0">
                      <div className="flex items-center justify-between mb-1">
                        <span className="text-sm font-semibold text-gray-900 truncate">
                          {otherParticipant.username}
                        </span>
                        <span className="text-xs text-gray-500 ml-2 flex-shrink-0">
                          {formatTimestamp(conversation.lastMessageAt)}
                        </span>
                      </div>
                      {conversation.lastMessage && (
                        <p
                          className={`text-sm truncate ${
                            conversation.unreadCount > 0
                              ? 'font-semibold text-gray-900'
                              : 'text-gray-500'
                          }`}
                        >
                          {conversation.lastMessage.text || '📷 Photo'}
                        </p>
                      )}
                    </div>

                    {conversation.unreadCount > 0 && (
                      <div className="flex-shrink-0 bg-blue-500 text-white text-xs font-bold rounded-full min-w-[24px] h-6 flex items-center justify-center px-2">
                        {conversation.unreadCount > 99 ? '99+' : conversation.unreadCount}
                      </div>
                    )}
                  </button>
                );
              })}

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
