'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { useAuthStore } from '../../../lib/stores/authStore';
import { useMessages, useSendMessage, useMarkConversationAsRead } from '../../../lib/hooks/useMessages';
import { Loading } from '../../../components/ui';
import type { Message } from '../../../../shared/types';

export default function ChatPage() {
  const router = useRouter();
  const params = useParams();
  const conversationId = params.conversationId as string;
  const { isAuthenticated, user } = useAuthStore();

  const [messageText, setMessageText] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const messagesContainerRef = useRef<HTMLDivElement>(null);

  const { data, fetchNextPage, hasNextPage, isFetchingNextPage, isLoading, refetch } =
    useMessages(conversationId, { limit: 50 });

  const sendMessageMutation = useSendMessage();
  const markAsReadMutation = useMarkConversationAsRead();

  const messages = data?.pages.flatMap((page) => page.data).reverse() || [];

  // Redirect if not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  // Mark conversation as read when entering
  useEffect(() => {
    if (conversationId) {
      markAsReadMutation.mutate(conversationId);
    }
  }, [conversationId]);

  // Auto-refresh messages every 5 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      refetch();
    }, 5000);

    return () => clearInterval(interval);
  }, [refetch]);

  // Scroll to bottom when messages change
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!messageText.trim() || !user) return;

    const text = messageText.trim();
    setMessageText('');

    try {
      // Find the receiver ID from the conversation
      const receiverId = messages.length > 0
        ? messages[0].senderId === user.userId
          ? messages[0].receiverId
          : messages[0].senderId
        : '';

      if (!receiverId) {
        console.error('Receiver ID not found');
        return;
      }

      await sendMessageMutation.mutateAsync({
        receiverId,
        text,
      });
    } catch (error) {
      console.error('Error sending message:', error);
      setMessageText(text); // Restore the message on error
    }
  };

  const formatTimestamp = (date: Date) => {
    const messageDate = new Date(date);
    const now = new Date();
    const diff = now.getTime() - messageDate.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));

    if (hours < 24) {
      return messageDate.toLocaleTimeString('en-US', {
        hour: 'numeric',
        minute: '2-digit',
        hour12: true,
      });
    } else {
      return messageDate.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
      });
    }
  };

  const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
    const { scrollTop } = e.currentTarget;
    if (scrollTop === 0 && hasNextPage && !isFetchingNextPage) {
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
    <div className="min-h-screen bg-gray-50 flex flex-col">
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
          <h1 className="text-xl font-bold">Chat</h1>
          <div className="w-10" />
        </div>
      </header>

      {/* Messages Container */}
      <div
        ref={messagesContainerRef}
        className="flex-1 overflow-y-auto px-4 py-4 max-w-4xl mx-auto w-full"
        onScroll={handleScroll}
      >
        {isFetchingNextPage && (
          <div className="flex justify-center py-4">
            <Loading />
          </div>
        )}

        {messages.map((message: Message) => {
          const isMyMessage = message.senderId === user?.userId;

          return (
            <div
              key={message.messageId}
              className={`flex mb-4 ${isMyMessage ? 'justify-end' : 'justify-start'}`}
            >
              <div className={`max-w-[75%] ${isMyMessage ? 'items-end' : 'items-start'} flex flex-col`}>
                <div
                  className={`px-4 py-2 rounded-2xl ${
                    isMyMessage
                      ? 'bg-blue-500 text-white rounded-br-sm'
                      : 'bg-gray-200 text-gray-900 rounded-bl-sm'
                  }`}
                >
                  {message.imageUrl ? (
                    <img
                      src={message.imageUrl}
                      alt="Message"
                      className="max-w-sm rounded-lg"
                    />
                  ) : (
                    <p className="text-sm break-words">{message.text}</p>
                  )}
                </div>
                <span className="text-xs text-gray-500 mt-1 px-1">
                  {formatTimestamp(message.createdAt)}
                </span>
              </div>
            </div>
          );
        })}
        <div ref={messagesEndRef} />
      </div>

      {/* Input Container */}
      <div className="bg-white border-t border-gray-300 sticky bottom-0">
        <div className="max-w-4xl mx-auto px-4 py-3">
          <form onSubmit={handleSend} className="flex items-end gap-2">
            <button
              type="button"
              className="p-2 hover:bg-gray-100 rounded-full flex-shrink-0"
            >
              <svg className="w-6 h-6 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                />
              </svg>
            </button>

            <textarea
              value={messageText}
              onChange={(e) => setMessageText(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault();
                  handleSend(e);
                }
              }}
              placeholder="Message..."
              className="flex-1 resize-none bg-gray-100 rounded-full px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 max-h-32"
              rows={1}
              style={{
                minHeight: '40px',
                maxHeight: '128px',
              }}
            />

            <button
              type="submit"
              disabled={!messageText.trim() || sendMessageMutation.isPending}
              className={`px-4 py-2 rounded-full flex-shrink-0 ${
                messageText.trim()
                  ? 'text-blue-500 hover:text-blue-600 font-semibold'
                  : 'text-gray-400'
              }`}
            >
              {sendMessageMutation.isPending ? (
                <Loading size="sm" />
              ) : (
                'Send'
              )}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
