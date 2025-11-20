'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useAuthStore } from '../../lib/stores/authStore';
import { useUserProfile, useUserPosts, useFollowUser, useUnfollowUser } from '../../lib/hooks/useProfile';
import { Loading } from '../../components/ui';
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
            onClick={() => router.push('/feed')}
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
          <h1 className="text-xl font-bold">@{profileData?.username}</h1>
          <button className="p-2 hover:bg-gray-100 rounded-full">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"
              />
            </svg>
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main
        className="max-w-4xl mx-auto px-4 py-8 overflow-y-auto"
        onScroll={handleScroll}
        style={{ maxHeight: 'calc(100vh - 64px)' }}
      >
        {/* Profile Info */}
        <div className="bg-white rounded-lg border border-gray-300 p-8 mb-6">
          <div className="flex items-start gap-8 mb-6">
            {/* Avatar */}
            <div className="relative w-32 h-32 rounded-full overflow-hidden flex-shrink-0">
              <Image
                src={profileData?.photoUrl || 'https://via.placeholder.com/128'}
                alt={profileData?.displayName || 'Profile'}
                fill
                className="object-cover"
              />
            </div>

            {/* Stats and Actions */}
            <div className="flex-1">
              <div className="flex items-center gap-6 mb-6">
                {/* Stats */}
                <div className="flex gap-8">
                  <div className="text-center">
                    <div className="text-xl font-semibold">{profileData?.posts || 0}</div>
                    <div className="text-sm text-gray-500">Posts</div>
                  </div>
                  <div className="text-center">
                    <div className="text-xl font-semibold">{profileData?.followers || 0}</div>
                    <div className="text-sm text-gray-500">Followers</div>
                  </div>
                  <div className="text-center">
                    <div className="text-xl font-semibold">{profileData?.following || 0}</div>
                    <div className="text-sm text-gray-500">Following</div>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3">
                {isOwnProfile ? (
                  <button
                    onClick={() => router.push('/profile/edit')}
                    className="px-6 py-2 bg-gray-200 hover:bg-gray-300 rounded-lg font-semibold transition-colors"
                  >
                    Edit Profile
                  </button>
                ) : (
                  <>
                    <button
                      onClick={handleFollowToggle}
                      disabled={followMutation.isPending || unfollowMutation.isPending}
                      className={`px-6 py-2 rounded-lg font-semibold transition-colors ${
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
                    <button
                      onClick={() => console.log('Message')}
                      className="px-6 py-2 bg-gray-200 hover:bg-gray-300 rounded-lg font-semibold transition-colors"
                    >
                      Message
                    </button>
                  </>
                )}
              </div>
            </div>
          </div>

          {/* Name and Bio */}
          <div>
            <h2 className="text-lg font-semibold mb-1">{profileData?.displayName}</h2>
            {profileData?.bio && (
              <p className="text-gray-700 whitespace-pre-wrap">{profileData.bio}</p>
            )}
          </div>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-lg border border-gray-300 overflow-hidden">
          <div className="flex border-b border-gray-300">
            <button className="flex-1 py-3 border-b-2 border-black font-semibold">
              Posts
            </button>
            <button className="flex-1 py-3 text-gray-500 hover:bg-gray-50">
              Reels
            </button>
            <button className="flex-1 py-3 text-gray-500 hover:bg-gray-50">
              Tagged
            </button>
          </div>

          {/* Posts Grid */}
          {posts.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20">
              <svg
                className="w-16 h-16 text-gray-400 mb-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"
                />
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"
                />
              </svg>
              <p className="text-xl text-gray-600">No posts yet</p>
            </div>
          ) : (
            <div className="grid grid-cols-3 gap-1 p-1">
              {posts.map((post) => (
                <button
                  key={post.postId}
                  onClick={() => console.log('Post clicked:', post.postId)}
                  className="relative aspect-square group overflow-hidden"
                >
                  <Image
                    src={post.imageUrls[0]}
                    alt="Post"
                    fill
                    className="object-cover group-hover:opacity-90 transition-opacity"
                  />
                  {post.imageUrls.length > 1 && (
                    <div className="absolute top-2 right-2">
                      <svg
                        className="w-5 h-5 text-white drop-shadow"
                        fill="currentColor"
                        viewBox="0 0 20 20"
                      >
                        <path d="M7 9a2 2 0 012-2h6a2 2 0 012 2v6a2 2 0 01-2 2H9a2 2 0 01-2-2V9z" />
                        <path d="M5 3a2 2 0 00-2 2v6a2 2 0 002 2V5h8a2 2 0 00-2-2H5z" />
                      </svg>
                    </div>
                  )}
                  <div className="absolute inset-0 bg-black opacity-0 group-hover:opacity-20 transition-opacity" />
                </button>
              ))}
            </div>
          )}

          {isFetchingNextPage && (
            <div className="flex justify-center py-8">
              <Loading />
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
