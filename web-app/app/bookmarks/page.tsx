'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useAuthStore } from '../../lib/stores/authStore';
import { useBookmarks, useDeleteBookmark } from '../../lib/hooks/useBookmarks';
import { Loading } from '../../components/ui';
import type { Bookmark } from '@shared/types';

export default function BookmarksPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();
  const [selectedType, setSelectedType] = useState<'post' | 'reel'>('post');

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
  } = useBookmarks({ limit: 30, type: selectedType });

  const deleteBookmarkMutation = useDeleteBookmark();

  const bookmarks = data?.pages.flatMap((page) => page.data) || [];

  React.useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  const handleBookmarkClick = (bookmark: Bookmark) => {
    if (bookmark.type === 'post' && bookmark.post) {
      router.push(`/posts/${bookmark.post.postId}`);
    } else if (bookmark.type === 'reel' && bookmark.reel) {
      router.push('/reels');
    }
  };

  const handleDeleteBookmark = async (bookmarkId: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (confirm('Remove this bookmark?')) {
      try {
        await deleteBookmarkMutation.mutateAsync(bookmarkId);
      } catch (error) {
        console.error('Error deleting bookmark:', error);
      }
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
          <h1 className="text-xl font-bold">Bookmarks</h1>
          <div className="w-10" />
        </div>
      </header>

      {/* Tabs */}
      <div className="bg-white border-b border-gray-300 sticky top-[57px] z-10">
        <div className="max-w-6xl mx-auto flex">
          <button
            onClick={() => setSelectedType('post')}
            className={`flex-1 flex items-center justify-center gap-2 py-3 border-b-2 transition-colors ${
              selectedType === 'post'
                ? 'border-gray-900 text-gray-900'
                : 'border-transparent text-gray-500 hover:text-gray-700'
            }`}
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"
              />
            </svg>
            <span className="font-semibold">Posts</span>
          </button>

          <button
            onClick={() => setSelectedType('reel')}
            className={`flex-1 flex items-center justify-center gap-2 py-3 border-b-2 transition-colors ${
              selectedType === 'reel'
                ? 'border-gray-900 text-gray-900'
                : 'border-transparent text-gray-500 hover:text-gray-700'
            }`}
          >
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" />
            </svg>
            <span className="font-semibold">Reels</span>
          </button>
        </div>
      </div>

      {/* Main Content */}
      <main
        className="max-w-6xl mx-auto overflow-y-auto"
        onScroll={handleScroll}
        style={{ maxHeight: 'calc(100vh - 114px)' }}
      >
        {bookmarks.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20">
            <svg className="w-16 h-16 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"
              />
            </svg>
            <p className="text-lg font-semibold text-gray-700 mb-2">No bookmarks yet</p>
            <p className="text-sm text-gray-500 text-center max-w-sm">
              {selectedType === 'post'
                ? 'Save posts to view them later'
                : 'Save reels to view them later'}
            </p>
          </div>
        ) : (
          <>
            <div className="grid grid-cols-3 gap-1 p-1">
              {bookmarks.map((bookmark) => {
                const content = bookmark.type === 'post' ? bookmark.post : bookmark.reel;
                if (!content) return null;

                const imageUrl = bookmark.type === 'post'
                  ? bookmark.post?.imageUrls?.[0]
                  : bookmark.reel?.thumbnailUrl || bookmark.reel?.videoUrl;

                return (
                  <div
                    key={bookmark.bookmarkId}
                    className="relative aspect-square bg-gray-200 cursor-pointer group"
                    onClick={() => handleBookmarkClick(bookmark)}
                  >
                    {imageUrl ? (
                      <Image
                        src={imageUrl}
                        alt="Bookmark"
                        fill
                        className="object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center bg-gray-200">
                        <svg
                          className="w-12 h-12 text-gray-400"
                          fill="currentColor"
                          viewBox="0 0 20 20"
                        >
                          <path
                            fillRule="evenodd"
                            d={bookmark.type === 'post'
                              ? "M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z"
                              : "M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z"
                            }
                            clipRule="evenodd"
                          />
                        </svg>
                      </div>
                    )}

                    {/* Indicators */}
                    {bookmark.type === 'reel' && (
                      <div className="absolute top-2 right-2">
                        <svg className="w-5 h-5 text-white drop-shadow" fill="currentColor" viewBox="0 0 20 20">
                          <path d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" />
                        </svg>
                      </div>
                    )}

                    {bookmark.type === 'post' && bookmark.post && bookmark.post.imageUrls && bookmark.post.imageUrls.length > 1 && (
                      <div className="absolute top-2 right-2">
                        <svg className="w-5 h-5 text-white drop-shadow" fill="currentColor" viewBox="0 0 20 20">
                          <path d="M8 2a1 1 0 000 2h2a1 1 0 100-2H8z" />
                          <path d="M3 5a2 2 0 012-2 3 3 0 003 3h2a3 3 0 003-3 2 2 0 012 2v6h-4.586l1.293-1.293a1 1 0 00-1.414-1.414l-3 3a1 1 0 000 1.414l3 3a1 1 0 001.414-1.414L10.414 13H15v3a2 2 0 01-2 2H5a2 2 0 01-2-2V5zM15 11h2a1 1 0 110 2h-2v-2z" />
                        </svg>
                      </div>
                    )}

                    {/* Delete button on hover */}
                    <button
                      onClick={(e) => handleDeleteBookmark(bookmark.bookmarkId, e)}
                      className="absolute top-2 left-2 opacity-0 group-hover:opacity-100 transition-opacity bg-red-500 text-white p-2 rounded-full hover:bg-red-600"
                    >
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                        />
                      </svg>
                    </button>

                    {/* Overlay on hover */}
                    <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 transition-all" />
                  </div>
                );
              })}
            </div>

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
