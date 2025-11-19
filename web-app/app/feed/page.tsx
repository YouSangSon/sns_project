'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useFeedPosts } from '../../lib/hooks/usePosts';
import { useAuthStore } from '../../lib/stores/authStore';
import { PostCard } from '../../components/posts';
import { Loading } from '../../components/ui';

export default function FeedPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
    refetch,
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
          <h1 className="text-2xl font-bold">SNS App</h1>

          <div className="flex items-center gap-4">
            <button className="p-2 hover:bg-gray-100 rounded-full">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
                />
              </svg>
            </button>

            <button className="p-2 hover:bg-gray-100 rounded-full">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                />
              </svg>
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main
        className="max-w-2xl mx-auto px-4 py-8 overflow-y-auto"
        onScroll={handleScroll}
        style={{ maxHeight: 'calc(100vh - 64px)' }}
      >
        {posts.length === 0 ? (
          <div className="text-center py-20">
            <p className="text-xl font-semibold text-gray-700 mb-2">
              No posts yet
            </p>
            <p className="text-gray-500">
              Follow users to see their posts here
            </p>
          </div>
        ) : (
          <>
            {posts.map((post) => (
              <PostCard
                key={post.postId}
                post={post}
                onLike={() => console.log('Like:', post.postId)}
                onComment={() => console.log('Comment:', post.postId)}
                onShare={() => console.log('Share:', post.postId)}
                onUserClick={() => console.log('User:', post.userId)}
              />
            ))}

            {isFetchingNextPage && (
              <div className="flex justify-center py-8">
                <Loading />
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
