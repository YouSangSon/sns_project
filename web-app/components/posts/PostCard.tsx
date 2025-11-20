'use client';

import React, { useState } from 'react';
import Image from 'next/image';
import type { Post } from '../../../shared/types';
import { useLikePost, useUnlikePost } from '../../lib/hooks/usePosts';

interface PostCardProps {
  post: Post;
  onComment?: () => void;
  onShare?: () => void;
  onUserClick?: () => void;
}

export const PostCard: React.FC<PostCardProps> = ({
  post,
  onComment,
  onShare,
  onUserClick,
}) => {
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [isLiked, setIsLiked] = useState(false);
  const [likesCount, setLikesCount] = useState(post.likes);

  const likeMutation = useLikePost();
  const unlikeMutation = useUnlikePost();

  const handleLike = async () => {
    const wasLiked = isLiked;
    const previousCount = likesCount;

    // Optimistic update
    setIsLiked(!wasLiked);
    setLikesCount(wasLiked ? likesCount - 1 : likesCount + 1);

    try {
      if (wasLiked) {
        await unlikeMutation.mutateAsync(post.postId);
      } else {
        await likeMutation.mutateAsync(post.postId);
      }
    } catch (error) {
      // Revert on error
      setIsLiked(wasLiked);
      setLikesCount(previousCount);
      console.error('Error toggling like:', error);
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
      return `${days} day${days > 1 ? 's' : ''} ago`;
    } else if (hours > 0) {
      return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    } else if (minutes > 0) {
      return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
    } else {
      return 'Just now';
    }
  };

  return (
    <div className="bg-white border border-gray-300 rounded-lg mb-6">
      {/* Header */}
      <div className="flex items-center p-4">
        <button
          onClick={onUserClick}
          className="flex items-center flex-1 hover:opacity-70"
        >
          <Image
            src={post.userPhotoUrl || 'https://via.placeholder.com/40'}
            alt={post.username}
            width={40}
            height={40}
            className="rounded-full"
          />
          <div className="ml-3 text-left">
            <p className="font-semibold text-sm">{post.username}</p>
            {post.location && (
              <p className="text-xs text-gray-500">{post.location}</p>
            )}
          </div>
        </button>
        <button className="p-2 hover:bg-gray-100 rounded-full">
          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
          </svg>
        </button>
      </div>

      {/* Image */}
      <div className="relative w-full aspect-square bg-gray-100">
        <Image
          src={post.imageUrls[currentImageIndex]}
          alt="Post image"
          fill
          className="object-cover"
        />

        {/* Image Indicator */}
        {post.imageUrls.length > 1 && (
          <div className="absolute bottom-4 left-0 right-0 flex justify-center gap-2">
            {post.imageUrls.map((_, index) => (
              <div
                key={index}
                className={`w-2 h-2 rounded-full ${
                  index === currentImageIndex
                    ? 'bg-white'
                    : 'bg-white/50'
                }`}
              />
            ))}
          </div>
        )}
      </div>

      {/* Actions */}
      <div className="flex items-center justify-between p-4">
        <div className="flex items-center gap-4">
          <button onClick={handleLike} className="hover:opacity-70">
            {isLiked ? (
              <svg className="w-7 h-7 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fillRule="evenodd"
                  d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z"
                  clipRule="evenodd"
                />
              </svg>
            ) : (
              <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
                />
              </svg>
            )}
          </button>
          <button onClick={onComment} className="hover:opacity-70">
            <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
              />
            </svg>
          </button>
          <button onClick={onShare} className="hover:opacity-70">
            <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
              />
            </svg>
          </button>
        </div>

        <button className="hover:opacity-70">
          <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"
            />
          </svg>
        </button>
      </div>

      {/* Likes Count */}
      <div className="px-4 pb-2">
        <p className="font-semibold text-sm">
          {likesCount.toLocaleString()} likes
        </p>
      </div>

      {/* Caption */}
      {post.caption && (
        <div className="px-4 pb-2">
          <p className="text-sm">
            <span className="font-semibold">{post.username}</span>{' '}
            {post.caption}
          </p>
        </div>
      )}

      {/* Comments Preview */}
      {post.comments > 0 && (
        <button
          onClick={onComment}
          className="px-4 pb-2 text-sm text-gray-500 hover:text-gray-700"
        >
          View all {post.comments} comments
        </button>
      )}

      {/* Timestamp */}
      <div className="px-4 pb-4">
        <p className="text-xs text-gray-500 uppercase">
          {formatTimestamp(post.createdAt)}
        </p>
      </div>
    </div>
  );
};
