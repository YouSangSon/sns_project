'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useFeedPosts } from '../../lib/hooks/usePosts';
import { useAuthStore } from '../../lib/stores/authStore';
import { PostCard } from '../../components/posts';
import { Loading } from '../../components/ui';
import { AppLayout } from '../../components/layout';

export default function FeedPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
  } = useFeedPosts({ limit: 10 });

  // Redirect to login if not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  const posts = data?.pages.flatMap((page) => page.data) || [];

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

  if (isLoading) {
    return (
      <AppLayout>
        <div className="min-h-screen flex items-center justify-center">
          <Loading size="lg" />
        </div>
      </AppLayout>
    );
  }

  return (
    <AppLayout>
      <div className="min-h-screen bg-gray-50">
        {/* Main Feed */}
        <div
          className="max-w-2xl mx-auto px-4 py-8 pb-20 lg:pb-8"
          onScroll={handleScroll}
        >
          {posts.length === 0 ? (
            <div className="text-center py-20">
              <div className="mb-4">
                <svg className="w-20 h-20 mx-auto text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              <p className="text-2xl font-semibold text-gray-700 mb-2">
                Welcome to Instagram
              </p>
              <p className="text-gray-500 mb-6">
                Follow users to see their posts in your feed
              </p>
              <button
                onClick={() => router.push('/search')}
                className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
              >
                Find people to follow
              </button>
            </div>
          ) : (
            <>
              {posts.map((post) => (
                <PostCard
                  key={post.postId}
                  post={post}
                  onComment={() => router.push(`/posts/${post.postId}`)}
                  onShare={() => console.log('Share:', post.postId)}
                  onUserClick={() => router.push(`/profile/${post.userId}`)}
                />
              ))}

              {isFetchingNextPage && (
                <div className="flex justify-center py-8">
                  <Loading />
                </div>
              )}

              {!hasNextPage && posts.length > 0 && (
                <div className="text-center py-8 text-gray-500">
                  <p>You're all caught up!</p>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </AppLayout>
  );
}
