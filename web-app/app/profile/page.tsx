'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useAuthStore } from '../../lib/stores/authStore';
import { useUserProfile, useUserPosts, useFollowUser, useUnfollowUser } from '../../lib/hooks/useProfile';
import { Loading } from '../../components/ui';
import { AppLayout } from '../../components/layout';
import type { Post } from '@shared/types';

export default function ProfilePage() {
  const router = useRouter();
  const { user: currentUser, isAuthenticated } = useAuthStore();
  const [isFollowing, setIsFollowing] = useState(false);

  // For now, show the current user's profile
  // Later, we can add query params to show other users' profiles
  const userId = currentUser?.uid || '';

  const {
    data: profileData,
    isLoading: isProfileLoading,
  } = useUserProfile(userId);

  const {
    data: postsData,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading: isPostsLoading,
  } = useUserPosts(userId, { limit: 12 });

  const followMutation = useFollowUser();
  const unfollowMutation = useUnfollowUser();

  // Redirect if not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  const posts = postsData?.pages.flatMap((page) => page.data) || [];
  const isOwnProfile = currentUser?.uid === userId;

  const handleFollowToggle = async () => {
    if (!userId) return;

    try {
      if (isFollowing) {
        await unfollowMutation.mutateAsync(userId);
        setIsFollowing(false);
      } else {
        await followMutation.mutateAsync(userId);
        setIsFollowing(true);
      }
    } catch (error) {
      console.error('Error toggling follow:', error);
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

  if (!isAuthenticated || isProfileLoading || isPostsLoading) {
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
        {/* Main Content */}
        <main
          className="max-w-4xl mx-auto px-4 py-8 pb-20 lg:pb-8"
          onScroll={handleScroll}
        >
          {/* Profile Header */}
          <div className="mb-11">
            <div className="flex flex-col md:flex-row gap-8 items-start md:items-center">
              {/* Avatar */}
              <div className="flex justify-center md:justify-start w-full md:w-auto">
                <div className="relative w-24 h-24 md:w-36 md:h-36 rounded-full overflow-hidden flex-shrink-0 ring-1 ring-gray-200 bg-gray-200 flex items-center justify-center">
                  {profileData?.photoUrl ? (
                    <Image
                      src={profileData.photoUrl}
                      alt={profileData?.displayName || 'Profile'}
                      fill
                      className="object-cover"
                      onError={(e) => {
                        // Hide image on error and show default avatar
                        e.currentTarget.style.display = 'none';
                      }}
                    />
                  ) : null}
                  {/* Default Avatar Icon */}
                  <svg className="w-16 h-16 md:w-24 md:h-24 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                  </svg>
                </div>
              </div>

              {/* Stats and Info */}
              <div className="flex-1 w-full">
                {/* Username and Actions */}
                <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4 mb-5">
                  <h1 className="text-xl font-light">{profileData?.username || 'username'}</h1>

                  <div className="flex gap-2 w-full sm:w-auto">
                    {isOwnProfile ? (
                      <>
                        <button
                          onClick={() => router.push('/profile/edit')}
                          className="flex-1 sm:flex-none px-6 py-1.5 bg-gray-200 hover:bg-gray-300 rounded-lg font-semibold text-sm transition-colors"
                        >
                          Edit profile
                        </button>
                        <button className="px-3 py-1.5 bg-gray-200 hover:bg-gray-300 rounded-lg transition-colors">
                          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
                          </svg>
                        </button>
                      </>
                    ) : (
                      <>
                        <button
                          onClick={handleFollowToggle}
                          disabled={followMutation.isPending || unfollowMutation.isPending}
                          className={`flex-1 sm:flex-none px-6 py-1.5 rounded-lg font-semibold text-sm transition-colors ${
                            isFollowing
                              ? 'bg-gray-200 hover:bg-gray-300 text-black'
                              : 'bg-blue-500 hover:bg-blue-600 text-white'
                          }`}
                        >
                          {followMutation.isPending || unfollowMutation.isPending
                            ? 'Loading...'
                            : isFollowing
                            ? 'Following'
                            : 'Follow'}
                        </button>
                        <button className="px-6 py-1.5 bg-gray-200 hover:bg-gray-300 rounded-lg font-semibold text-sm transition-colors">
                          Message
                        </button>
                      </>
                    )}
                  </div>
                </div>

                {/* Stats */}
                <div className="flex gap-8 mb-5">
                  <div>
                    <span className="font-semibold">{profileData?.posts || 0}</span>{' '}
                    <span className="text-gray-600">posts</span>
                  </div>
                  <button className="hover:text-gray-600">
                    <span className="font-semibold">{profileData?.followers || 0}</span>{' '}
                    <span className="text-gray-600">followers</span>
                  </button>
                  <button className="hover:text-gray-600">
                    <span className="font-semibold">{profileData?.following || 0}</span>{' '}
                    <span className="text-gray-600">following</span>
                  </button>
                </div>

                {/* Name and Bio */}
                <div>
                  <h2 className="font-semibold">{profileData?.displayName}</h2>
                  {profileData?.bio && (
                    <p className="text-sm mt-1 whitespace-pre-wrap">{profileData.bio}</p>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Tabs */}
          <div className="border-t border-gray-200">
            <div className="flex justify-center gap-16 -mb-px">
              <button className="flex items-center gap-1 py-4 border-t border-black text-xs font-semibold tracking-wide">
                <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clipRule="evenodd" />
                </svg>
                POSTS
              </button>
              <button className="flex items-center gap-1 py-4 text-gray-400 text-xs font-semibold tracking-wide hover:text-gray-600">
                <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M2 6a2 2 0 012-2h6a2 2 0 012 2v8a2 2 0 01-2 2H4a2 2 0 01-2-2V6zM14.553 7.106A1 1 0 0014 8v4a1 1 0 00.553.894l2 1A1 1 0 0018 13V7a1 1 0 00-1.447-.894l-2 1z" />
                </svg>
                REELS
              </button>
              <button className="flex items-center gap-1 py-4 text-gray-400 text-xs font-semibold tracking-wide hover:text-gray-600">
                <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                </svg>
                TAGGED
              </button>
            </div>
          </div>

          {/* Posts Grid */}
          {posts.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20">
              <div className="w-16 h-16 mb-4 rounded-full border-4 border-black flex items-center justify-center">
                <svg className="w-8 h-8" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </div>
              <p className="text-3xl font-light mb-1">Share Photos</p>
              <p className="text-sm text-gray-500">When you share photos, they will appear on your profile.</p>
              {isOwnProfile && (
                <button
                  onClick={() => router.push('/create-post')}
                  className="mt-4 text-blue-500 font-semibold text-sm hover:text-blue-600"
                >
                  Share your first photo
                </button>
              )}
            </div>
          ) : (
            <>
              <div className="grid grid-cols-3 gap-1 mt-4">
                {posts.map((post) => (
                  <button
                    key={post.postId}
                    onClick={() => router.push(`/posts/${post.postId}`)}
                    className="relative aspect-square group overflow-hidden bg-gray-200 flex items-center justify-center"
                  >
                    {post.imageUrls[0] ? (
                      <Image
                        src={post.imageUrls[0]}
                        alt="Post"
                        fill
                        className="object-cover"
                        onError={(e) => {
                          e.currentTarget.style.display = 'none';
                        }}
                      />
                    ) : null}
                    {/* Fallback icon for failed images */}
                    <svg className="w-12 h-12 text-gray-400 absolute" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    {post.imageUrls.length > 1 && (
                      <div className="absolute top-2 right-2">
                        <svg className="w-5 h-5 text-white drop-shadow-lg" fill="currentColor" viewBox="0 0 20 20">
                          <path d="M7 9a2 2 0 012-2h6a2 2 0 012 2v6a2 2 0 01-2 2H9a2 2 0 01-2-2V9z" />
                          <path d="M5 3a2 2 0 00-2 2v6a2 2 0 002 2V5h8a2 2 0 00-2-2H5z" />
                        </svg>
                      </div>
                    )}
                    {/* Hover Overlay */}
                    <div className="absolute inset-0 bg-black opacity-0 group-hover:opacity-30 transition-opacity flex items-center justify-center">
                      <div className="text-white flex gap-6">
                        <div className="flex items-center gap-1">
                          <svg className="w-6 h-6 fill-current" viewBox="0 0 48 48">
                            <path d="M34.6 6.1c5.7 0 10.4 5.2 10.4 11.5 0 6.8-5.9 11-11.5 16S25 41.3 24 41.9c-1.1-.7-4.7-4-9.5-8.3-5.7-5-11.5-9.2-11.5-16C3 11.3 7.7 6.1 13.4 6.1c4.2 0 6.5 2 8.1 4.3 1.9 2.6 2.2 3.9 2.5 3.9.3 0 .6-1.3 2.5-3.9 1.6-2.3 3.9-4.3 8.1-4.3m0-3c-4.5 0-7.9 1.8-10.6 5.6-2.7-3.7-6.1-5.5-10.6-5.5C6 3.1 0 9.6 0 17.6c0 7.3 5.4 12 10.6 16.5.6.5 1.3 1.1 1.9 1.7l2.3 2c4.4 3.9 6.6 5.9 7.6 6.5.5.3 1.1.5 1.6.5.6 0 1.1-.2 1.6-.5 1-.6 2.8-2.2 7.8-6.8l2-1.8c.7-.6 1.3-1.2 2-1.7C42.7 29.6 48 25 48 17.6c0-8-6-14.5-13.4-14.5z" />
                          </svg>
                          <span className="font-semibold">{post.likes}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <svg className="w-6 h-6 fill-current" viewBox="0 0 48 48">
                            <path fillRule="evenodd" clipRule="evenodd" d="M47.5 46.1l-2.8-11c1.8-3.3 2.8-7.1 2.8-11.1C47.5 11 37 .5 24 .5S.5 11 .5 24 11 47.5 24 47.5c4 0 7.8-1 11.1-2.8l11 2.8c.8.2 1.6-.6 1.4-1.4zm-3-22.1c0 4-1 7-2.6 10-.2.4-.3.9-.2 1.4l2.1 8.4-8.3-2.1c-.5-.1-1-.1-1.4.2-1.8 1-5.2 2.6-10 2.6-11.4 0-20.6-9.2-20.6-20.5S12.7 3.5 24 3.5 44.5 12.7 44.5 24z" />
                          </svg>
                          <span className="font-semibold">{post.comments}</span>
                        </div>
                      </div>
                    </div>
                  </button>
                ))}
              </div>

              {isFetchingNextPage && (
                <div className="flex justify-center py-8">
                  <Loading />
                </div>
              )}

              {!hasNextPage && posts.length > 0 && (
                <div className="text-center py-8 text-gray-500 text-sm">
                  You've seen all posts
                </div>
              )}
            </>
          )}
        </main>
      </div>
    </AppLayout>
  );
}
