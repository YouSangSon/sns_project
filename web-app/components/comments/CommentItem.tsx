'use client';

import React, { useState } from 'react';
import Image from 'next/image';
import type { Comment } from '@shared/types';
import { useLikeComment, useUnlikeComment, useDeleteComment } from '../../lib/hooks/useComments';
import { useAuthStore } from '../../lib/stores/authStore';

interface CommentItemProps {
  comment: Comment;
  postId: string;
  onReply?: (comment: Comment) => void;
  onViewReplies?: (comment: Comment) => void;
}

export const CommentItem: React.FC<CommentItemProps> = ({
  comment,
  postId,
  onReply,
  onViewReplies,
}) => {
  const { user } = useAuthStore();
  const [isLiked, setIsLiked] = useState(false);
  const [likesCount, setLikesCount] = useState(comment.likes);

  const likeMutation = useLikeComment();
  const unlikeMutation = useUnlikeComment();
  const deleteMutation = useDeleteComment();

  const isOwnComment = user?.uid === comment.userId;

  const handleLike = async () => {
    const wasLiked = isLiked;
    const previousCount = likesCount;

    // Optimistic update
    setIsLiked(!wasLiked);
    setLikesCount(wasLiked ? likesCount - 1 : likesCount + 1);

    try {
      if (wasLiked) {
        await unlikeMutation.mutateAsync(comment.commentId);
      } else {
        await likeMutation.mutateAsync(comment.commentId);
      }
    } catch (error) {
      // Revert on error
      setIsLiked(wasLiked);
      setLikesCount(previousCount);
      console.error('Error toggling like:', error);
    }
  };

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this comment?')) return;

    try {
      await deleteMutation.mutateAsync({
        commentId: comment.commentId,
        postId,
      });
    } catch (error) {
      console.error('Error deleting comment:', error);
      alert('Failed to delete comment');
    }
  };

  const formatTimestamp = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - new Date(date).getTime();
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);
    const weeks = Math.floor(days / 7);

    if (weeks > 0) return `${weeks}w`;
    if (days > 0) return `${days}d`;
    if (hours > 0) return `${hours}h`;
    if (minutes > 0) return `${minutes}m`;
    return 'now';
  };

  return (
    <div className="flex gap-3 py-3 px-4">
      <Image
        src={comment.userPhotoUrl || 'https://via.placeholder.com/32'}
        alt={comment.username}
        width={32}
        height={32}
        className="rounded-full"
      />

      <div className="flex-1">
        <div className="bg-gray-100 rounded-2xl px-3 py-2">
          <p className="font-semibold text-sm mb-0.5">{comment.username}</p>
          <p className="text-sm leading-snug">{comment.text}</p>
        </div>

        <div className="flex items-center gap-3 mt-1 ml-3 text-xs text-gray-500">
          <span>{formatTimestamp(comment.createdAt)}</span>

          {likesCount > 0 && (
            <span className="font-semibold text-gray-900">
              {likesCount} {likesCount === 1 ? 'like' : 'likes'}
            </span>
          )}

          <button
            onClick={() => onReply?.(comment)}
            className="font-semibold hover:text-gray-700"
          >
            Reply
          </button>

          {isOwnComment && (
            <button
              onClick={handleDelete}
              className="font-semibold text-red-500 hover:text-red-600"
            >
              Delete
            </button>
          )}
        </div>

        {comment.repliesCount > 0 && (
          <button
            onClick={() => onViewReplies?.(comment)}
            className="flex items-center gap-2 mt-2 ml-3"
          >
            <div className="w-6 h-px bg-gray-300" />
            <span className="text-xs font-semibold text-gray-500 hover:text-gray-700">
              View {comment.repliesCount} {comment.repliesCount === 1 ? 'reply' : 'replies'}
            </span>
          </button>
        )}
      </div>

      <button onClick={handleLike} className="p-1 -mt-1">
        {isLiked ? (
          <svg className="w-3 h-3 text-red-500" fill="currentColor" viewBox="0 0 20 20">
            <path
              fillRule="evenodd"
              d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z"
              clipRule="evenodd"
            />
          </svg>
        ) : (
          <svg className="w-3 h-3 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
            />
          </svg>
        )}
      </button>
    </div>
  );
};
