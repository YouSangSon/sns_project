'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useRouter, useParams } from 'next/navigation';
import Image from 'next/image';
import { useAuthStore } from '../../../lib/stores/authStore';
import { useUserStories, useViewStory } from '../../../lib/hooks/useStories';
import { Loading } from '../../../components/ui';

const STORY_DURATION = 5000; // 5 seconds

export default function StoriesPage() {
  const router = useRouter();
  const params = useParams();
  const userId = params.userId as string;
  const { isAuthenticated } = useAuthStore();

  const { data: stories, isLoading } = useUserStories(userId);
  const viewStoryMutation = useViewStory();

  const [currentIndex, setCurrentIndex] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [progress, setProgress] = useState<number[]>([]);
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const progressIntervalRef = useRef<NodeJS.Timeout | null>(null);

  const currentStory = stories?.[currentIndex];

  // Redirect if not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  // Initialize progress
  useEffect(() => {
    if (stories) {
      setProgress(stories.map(() => 0));
    }
  }, [stories]);

  // Mark story as viewed when displayed
  useEffect(() => {
    if (currentStory) {
      viewStoryMutation.mutate(currentStory.storyId);
    }
  }, [currentStory?.storyId]);

  // Auto-advance timer
  useEffect(() => {
    if (!currentStory || isPaused || !stories) return;

    const duration = currentStory.duration || STORY_DURATION;
    const startTime = Date.now();

    // Update progress bar
    progressIntervalRef.current = setInterval(() => {
      const elapsed = Date.now() - startTime;
      const percentage = Math.min((elapsed / duration) * 100, 100);

      setProgress((prev) => {
        const newProgress = [...prev];
        newProgress[currentIndex] = percentage;
        return newProgress;
      });
    }, 50);

    // Set timer to advance
    timerRef.current = setTimeout(() => {
      handleNext();
    }, duration);

    return () => {
      if (timerRef.current) {
        clearTimeout(timerRef.current);
      }
      if (progressIntervalRef.current) {
        clearInterval(progressIntervalRef.current);
      }
    };
  }, [currentIndex, isPaused, currentStory]);

  const handleNext = () => {
    if (!stories) return;

    if (currentIndex < stories.length - 1) {
      setProgress((prev) => {
        const newProgress = [...prev];
        newProgress[currentIndex] = 100;
        return newProgress;
      });
      setCurrentIndex(currentIndex + 1);
    } else {
      router.back();
    }
  };

  const handlePrevious = () => {
    if (currentIndex > 0) {
      setProgress((prev) => {
        const newProgress = [...prev];
        newProgress[currentIndex] = 0;
        return newProgress;
      });
      setCurrentIndex(currentIndex - 1);
    } else {
      router.back();
    }
  };

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'ArrowRight') {
      handleNext();
    } else if (e.key === 'ArrowLeft') {
      handlePrevious();
    } else if (e.key === 'Escape') {
      router.back();
    }
  };

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [currentIndex, stories]);

  if (!isAuthenticated || isLoading || !stories || stories.length === 0) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-black">
        <Loading size="lg" />
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black z-50 flex items-center justify-center">
      {/* Story Image */}
      {currentStory && (
        <div className="relative w-full h-full flex items-center justify-center">
          <Image
            src={currentStory.mediaUrl}
            alt="Story"
            fill
            className="object-contain"
          />
        </div>
      )}

      {/* Dark overlay */}
      <div className="absolute inset-0 bg-black bg-opacity-30" />

      {/* Progress bars */}
      <div className="absolute top-4 left-4 right-4 flex gap-1 z-10">
        {stories.map((_, index) => (
          <div key={index} className="flex-1 h-0.5 bg-white bg-opacity-30 rounded-full overflow-hidden">
            <div
              className="h-full bg-white transition-all duration-100"
              style={{
                width: index < currentIndex ? '100%' : index === currentIndex ? `${progress[index]}%` : '0%',
              }}
            />
          </div>
        ))}
      </div>

      {/* Header */}
      <div className="absolute top-8 left-4 right-4 flex items-center justify-between z-10">
        <div className="flex items-center gap-3">
          {currentStory?.userPhotoUrl ? (
            <div className="relative w-9 h-9">
              <Image
                src={currentStory.userPhotoUrl}
                alt={currentStory.username}
                fill
                className="rounded-full object-cover"
              />
            </div>
          ) : (
            <div className="w-9 h-9 rounded-full bg-white bg-opacity-20 flex items-center justify-center">
              <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
              </svg>
            </div>
          )}
          <div>
            <p className="text-white font-semibold text-sm">{currentStory?.username}</p>
            <p className="text-white text-opacity-70 text-xs">
              {currentStory && new Date(currentStory.createdAt).toLocaleTimeString()}
            </p>
          </div>
        </div>

        <button
          onClick={() => router.back()}
          className="text-white hover:text-opacity-70 transition-opacity"
        >
          <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      {/* Touch areas for navigation */}
      <div className="absolute inset-0 flex z-5">
        <div
          className="flex-1 cursor-pointer"
          onClick={handlePrevious}
          onMouseDown={() => setIsPaused(true)}
          onMouseUp={() => setIsPaused(false)}
          onMouseLeave={() => setIsPaused(false)}
        />
        <div
          className="flex-1 cursor-pointer"
          onClick={handleNext}
          onMouseDown={() => setIsPaused(true)}
          onMouseUp={() => setIsPaused(false)}
          onMouseLeave={() => setIsPaused(false)}
        />
      </div>

      {/* Footer */}
      {currentStory && (
        <div className="absolute bottom-8 left-4 right-4 z-10">
          <div className="flex items-center gap-2 text-white">
            <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
              <path fillRule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clipRule="evenodd" />
            </svg>
            <span className="text-sm">{currentStory.views} views</span>
          </div>
        </div>
      )}
    </div>
  );
}
