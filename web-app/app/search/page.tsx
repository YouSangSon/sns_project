'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useQuery } from '@tanstack/react-query';
import { useAuthStore } from '../../lib/stores/authStore';
import { usersService } from '@shared/api';
import { Loading } from '../../components/ui';
import { AppLayout } from '../../components/layout';
import { useDebounce } from '../../lib/hooks/useDebounce';
import type { User } from '@shared/types';

export default function SearchPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();
  const [searchQuery, setSearchQuery] = useState('');
  const debouncedQuery = useDebounce(searchQuery, 300);

  const {
    data: searchResults,
    isLoading,
    isFetching,
  } = useQuery({
    queryKey: ['search', 'users', debouncedQuery],
    queryFn: () => usersService.searchUsers(debouncedQuery, { limit: 20 }),
    enabled: debouncedQuery.length > 0,
  });

  const users = searchResults?.data || [];

  // Redirect if not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  const handleUserClick = (user: User) => {
    // Navigate to user profile
    console.log('User clicked:', user.uid);
    // router.push(`/users/${user.uid}`);
  };

  if (!isAuthenticated) {
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
          <h1 className="text-xl font-bold">Search</h1>
          <div className="w-10" />
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-2xl mx-auto px-4 py-6">
        {/* Search Input */}
        <div className="relative mb-6">
          <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
            <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
          </div>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search users..."
            className="w-full pl-12 pr-12 py-3 bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            autoFocus
          />
          {searchQuery.length > 0 && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute inset-y-0 right-0 pr-4 flex items-center"
            >
              <svg className="w-5 h-5 text-gray-400 hover:text-gray-600" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fillRule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                  clipRule="evenodd"
                />
              </svg>
            </button>
          )}
        </div>

        {/* Results */}
        <div className="bg-white rounded-lg border border-gray-300 overflow-hidden">
          {isLoading || isFetching ? (
            <div className="flex justify-center py-12">
              <Loading />
            </div>
          ) : debouncedQuery.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20">
              <svg className="w-16 h-16 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                />
              </svg>
              <p className="text-lg font-semibold text-gray-700 mb-2">Search for users</p>
              <p className="text-sm text-gray-500">Find friends and discover new accounts</p>
            </div>
          ) : users.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20">
              <svg className="w-16 h-16 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                />
              </svg>
              <p className="text-lg font-semibold text-gray-700 mb-2">No results found</p>
              <p className="text-sm text-gray-500">Try searching for a different username</p>
            </div>
          ) : (
            <div>
              {users.map((user) => (
                <button
                  key={user.uid}
                  onClick={() => handleUserClick(user)}
                  className="w-full flex items-center gap-3 p-4 hover:bg-gray-50 transition-colors border-b border-gray-200 last:border-b-0"
                >
                  <div className="relative w-12 h-12 flex-shrink-0">
                    <Image
                      src={user.photoUrl || 'https://via.placeholder.com/48'}
                      alt={user.username}
                      fill
                      className="rounded-full object-cover"
                    />
                  </div>
                  <div className="flex-1 text-left">
                    <p className="font-semibold text-sm">{user.username}</p>
                    <p className="text-sm text-gray-500">{user.displayName}</p>
                    {user.bio && (
                      <p className="text-xs text-gray-500 mt-1 line-clamp-1">{user.bio}</p>
                    )}
                  </div>
                  <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                  </svg>
                </button>
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
