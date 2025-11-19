import { useInfiniteQuery, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { commentsService } from '../../../shared/api';
import type { CreateCommentDto, UpdateCommentDto, PaginationParams } from '../../../shared/types';

// Query Keys
export const COMMENT_KEYS = {
  all: ['comments'] as const,
  lists: () => [...COMMENT_KEYS.all, 'list'] as const,
  list: (postId: string, params?: PaginationParams) =>
    [...COMMENT_KEYS.lists(), postId, params] as const,
  details: () => [...COMMENT_KEYS.all, 'detail'] as const,
  detail: (id: string) => [...COMMENT_KEYS.details(), id] as const,
  replies: (commentId: string) => [...COMMENT_KEYS.detail(commentId), 'replies'] as const,
};

// Get comments for a post
export const usePostComments = (postId: string, params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: COMMENT_KEYS.list(postId, params),
    queryFn: ({ pageParam = 1 }) =>
      commentsService.getPostComments(postId, { ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
    enabled: !!postId,
  });
};

// Get comment by ID
export const useComment = (commentId: string) => {
  return useQuery({
    queryKey: COMMENT_KEYS.detail(commentId),
    queryFn: () => commentsService.getCommentById(commentId),
    enabled: !!commentId,
  });
};

// Get replies to a comment
export const useCommentReplies = (commentId: string, params?: PaginationParams) => {
  return useInfiniteQuery({
    queryKey: [...COMMENT_KEYS.replies(commentId), params],
    queryFn: ({ pageParam = 1 }) =>
      commentsService.getReplies(commentId, { ...params, page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
    enabled: !!commentId,
  });
};

// Create comment
export const useCreateComment = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateCommentDto) => commentsService.createComment(data),
    onSuccess: (newComment) => {
      // Invalidate comments list for the post
      queryClient.invalidateQueries({
        queryKey: COMMENT_KEYS.list(newComment.postId)
      });

      // If it's a reply, invalidate parent comment's replies
      if (newComment.parentCommentId) {
        queryClient.invalidateQueries({
          queryKey: COMMENT_KEYS.replies(newComment.parentCommentId)
        });
      }
    },
  });
};

// Update comment
export const useUpdateComment = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ commentId, data }: { commentId: string; data: UpdateCommentDto }) =>
      commentsService.updateComment(commentId, data),
    onSuccess: (updatedComment) => {
      // Invalidate the specific comment
      queryClient.invalidateQueries({
        queryKey: COMMENT_KEYS.detail(updatedComment.commentId)
      });

      // Invalidate comments list for the post
      queryClient.invalidateQueries({
        queryKey: COMMENT_KEYS.list(updatedComment.postId)
      });
    },
  });
};

// Delete comment
export const useDeleteComment = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ commentId, postId }: { commentId: string; postId: string }) =>
      commentsService.deleteComment(commentId),
    onSuccess: (_, variables) => {
      // Invalidate comments list for the post
      queryClient.invalidateQueries({
        queryKey: COMMENT_KEYS.list(variables.postId)
      });
    },
  });
};

// Like comment
export const useLikeComment = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (commentId: string) => commentsService.likeComment(commentId),
    onSuccess: (_, commentId) => {
      queryClient.invalidateQueries({
        queryKey: COMMENT_KEYS.detail(commentId)
      });
    },
  });
};

// Unlike comment
export const useUnlikeComment = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (commentId: string) => commentsService.unlikeComment(commentId),
    onSuccess: (_, commentId) => {
      queryClient.invalidateQueries({
        queryKey: COMMENT_KEYS.detail(commentId)
      });
    },
  });
};
