import { useInfiniteQuery, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { messagesService } from '../../../shared/api';
import type { CreateMessageDto, PaginationParams } from '../../../shared/types';

// Query Keys
export const MESSAGE_KEYS = {
  all: ['messages'] as const,
  conversations: () => [...MESSAGE_KEYS.all, 'conversations'] as const,
  conversationsList: (params?: PaginationParams) =>
    [...MESSAGE_KEYS.conversations(), params] as const,
  messages: (conversationId: string) => [...MESSAGE_KEYS.all, conversationId] as const,
  messagesList: (conversationId: string, params?: PaginationParams) =>
    [...MESSAGE_KEYS.messages(conversationId), params] as const,
  unreadCount: () => [...MESSAGE_KEYS.all, 'unread-count'] as const,
};

// Get all conversations
export const useConversations = (params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: MESSAGE_KEYS.conversationsList(params),
    queryFn: ({ pageParam = 1 }) =>
      messagesService.getConversations({ ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });
};

// Get messages in a conversation
export const useMessages = (conversationId: string, params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: MESSAGE_KEYS.messagesList(conversationId, params),
    queryFn: ({ pageParam = 1 }) =>
      messagesService.getMessages(conversationId, { ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
    enabled: !!conversationId,
  });
};

// Get unread message count
export const useUnreadCount = () => {
  return useQuery({
    queryKey: MESSAGE_KEYS.unreadCount(),
    queryFn: () => messagesService.getUnreadCount(),
    refetchInterval: 30000, // Refetch every 30 seconds
  });
};

// Send message
export const useSendMessage = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateMessageDto) => messagesService.sendMessage(data),
    onSuccess: (newMessage) => {
      // Invalidate conversations list
      queryClient.invalidateQueries({
        queryKey: MESSAGE_KEYS.conversations(),
      });

      // Invalidate messages list for this conversation
      queryClient.invalidateQueries({
        queryKey: MESSAGE_KEYS.messages(newMessage.conversationId),
      });
    },
  });
};

// Mark message as read
export const useMarkAsRead = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (messageId: string) => messagesService.markAsRead(messageId),
    onSuccess: () => {
      // Invalidate all message-related queries
      queryClient.invalidateQueries({
        queryKey: MESSAGE_KEYS.all,
      });
    },
  });
};

// Mark conversation as read
export const useMarkConversationAsRead = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (conversationId: string) =>
      messagesService.markConversationAsRead(conversationId),
    onSuccess: () => {
      // Invalidate conversations and unread count
      queryClient.invalidateQueries({
        queryKey: MESSAGE_KEYS.conversations(),
      });
      queryClient.invalidateQueries({
        queryKey: MESSAGE_KEYS.unreadCount(),
      });
    },
  });
};
