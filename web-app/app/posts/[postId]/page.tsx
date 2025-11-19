'use client';

import React, { useState, useRef, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { PostCard } from '../../../components/posts';
import { CommentItem } from '../../../components/comments';
import { Loading } from '../../../components/ui';
import { useAuthStore } from '../../../lib/stores/authStore';
import { usePost } from '../../../lib/hooks/usePosts';
import { usePostComments, useCreateComment } from '../../../lib/hooks/useComments';
import type { Comment } from '../../../../shared/types';

export default function PostDetailPage() {
  const router = useRouter();
  const params = useParams();
  const postId = params.postId as string;
  const { isAuthenticated } = useAuthStore();

  const [commentText, setCommentText] = useState('');
  const [replyingTo, setReplyingTo] = useState<Comment | null>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);

  const { data: post, isLoading: isPostLoading } = usePost(postId);
  const {
    data: commentsData,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading: isCommentsLoading,
  } = usePostComments(postId, { limit: 20 });

  const createCommentMutation = useCreateComment();

  const comments = commentsData?.pages.flatMap((page) => page.data) || [];

  // Redirect if not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  const handleSendComment = async () => {
    if (!commentText.trim()) return;

    const text = commentText.trim();
    setCommentText('');
    setReplyingTo(null);

    try {
      await createCommentMutation.mutateAsync({
        postId,
        text,
        parentCommentId: replyingTo?.commentId,
      });
    } catch (error) {
      console.error('Error creating comment:', error);
      setCommentText(text); // Restore text on error
    }
  };

  const handleReply = (comment: Comment) => {
    setReplyingTo(comment);
    setCommentText(`@${comment.username} `);
    inputRef.current?.focus();
  };

  const handleCancelReply = () => {
    setReplyingTo(null);
    setCommentText('');
  };

  const handleViewReplies = (comment: Comment) => {
    // Navigate to replies or expand inline
    console.log('View replies for:', comment.commentId);
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

  if (!isAuthenticated || isPostLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <Loading size="lg" />
      </div>
    );
  }

  if (!post) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <p className="text-lg text-red-500">Post not found</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-300 sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-3 flex items-center">
          <button
            onClick={() => router.back()}
            className="p-2 hover:bg-gray-100 rounded-full mr-3"
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
          <h1 className="text-xl font-bold">Post</h1>
        </div>
      </header>

      {/* Main Content */}
      <main
        className="max-w-2xl mx-auto overflow-y-auto"
        onScroll={handleScroll}
        style={{ maxHeight: 'calc(100vh - 64px - 80px)' }}
      >
        {/* Post */}
        <div className="mb-0">
          <PostCard
            post={post}
            onComment={() => inputRef.current?.focus()}
            onShare={() => console.log('Share')}
            onUserClick={() => console.log('User')}
          />
        </div>

        {/* Comments Section */}
        <div className="bg-white border-t border-gray-300">
          <div className="px-4 py-3 border-b border-gray-200">
            <h2 className="font-semibold text-base">Comments</h2>
          </div>

          {/* Comments List */}
          {isCommentsLoading ? (
            <div className="flex justify-center py-12">
              <Loading />
            </div>
          ) : comments.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12">
              <svg className="w-12 h-12 text-gray-400 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                />
              </svg>
              <p className="text-base font-semibold text-gray-700">No comments yet</p>
              <p className="text-sm text-gray-500 mt-1">Be the first to comment!</p>
            </div>
          ) : (
            <>
              {comments.map((comment) => (
                <CommentItem
                  key={comment.commentId}
                  comment={comment}
                  postId={postId}
                  onReply={handleReply}
                  onViewReplies={handleViewReplies}
                />
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

      {/* Comment Input (Fixed at bottom) */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-300">
        <div className="max-w-2xl mx-auto">
          {replyingTo && (
            <div className="flex items-center justify-between px-4 py-2 bg-gray-100">
              <span className="text-sm text-gray-600">
                Replying to @{replyingTo.username}
              </span>
              <button onClick={handleCancelReply} className="p-1 hover:bg-gray-200 rounded">
                <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          )}

          <div className="flex items-end gap-2 px-4 py-3">
            <textarea
              ref={inputRef}
              value={commentText}
              onChange={(e) => setCommentText(e.target.value)}
              placeholder="Add a comment..."
              maxLength={500}
              rows={1}
              className="flex-1 max-h-24 px-4 py-2 bg-gray-100 rounded-full resize-none focus:outline-none focus:ring-2 focus:ring-blue-500"
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault();
                  handleSendComment();
                }
              }}
            />

            <button
              onClick={handleSendComment}
              disabled={!commentText.trim() || createCommentMutation.isPending}
              className={`p-2 rounded-full transition-colors ${
                commentText.trim()
                  ? 'text-blue-500 hover:bg-blue-50'
                  : 'text-gray-400 cursor-not-allowed'
              }`}
            >
              {createCommentMutation.isPending ? (
                <Loading size="sm" />
              ) : (
                <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z" />
                </svg>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
