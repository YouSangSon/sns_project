'use client';

import React, { useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useAuthStore } from '../../../lib/stores/authStore';
import { useCreateStory } from '../../../lib/hooks/useStories';
import { Loading } from '../../../components/ui';

export default function CreateStoryPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const createStoryMutation = useCreateStory();

  React.useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (file.size > 10 * 1024 * 1024) {
        alert('File size must be less than 10MB');
        return;
      }

      if (!file.type.startsWith('image/')) {
        alert('Please select an image file');
        return;
      }

      const reader = new FileReader();
      reader.onloadend = () => {
        setSelectedImage(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleShare = async () => {
    if (!selectedImage) {
      alert('Please select an image first');
      return;
    }

    try {
      setIsUploading(true);

      // In a real app, you would upload the image to a server first
      // and get back a URL. For now, we'll use the data URL.
      // This would need to be replaced with actual upload logic.

      await createStoryMutation.mutateAsync({
        mediaUrl: selectedImage,
        mediaType: 'image',
        duration: 5000,
      });

      alert('Story created successfully!');
      router.push('/');
    } catch (error) {
      console.error('Error creating story:', error);
      alert('Failed to create story. Please try again.');
    } finally {
      setIsUploading(false);
    }
  };

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <Loading size="lg" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-black">
      {/* Header */}
      <header className="bg-black border-b border-gray-800 sticky top-0 z-10">
        <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
          <button
            onClick={() => router.back()}
            className="p-2 hover:bg-gray-800 rounded-full text-white"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
          <h1 className="text-xl font-bold text-white">Create Story</h1>
          {selectedImage && (
            <button
              onClick={handleShare}
              disabled={isUploading}
              className="px-4 py-2 text-blue-500 hover:text-blue-400 font-semibold disabled:opacity-50"
            >
              {isUploading ? 'Sharing...' : 'Share'}
            </button>
          )}
          {!selectedImage && <div className="w-20" />}
        </div>
      </header>

      {/* Content */}
      <main className="max-w-4xl mx-auto px-4 py-8">
        {selectedImage ? (
          <div className="relative">
            <div className="relative w-full" style={{ height: '80vh' }}>
              <Image
                src={selectedImage}
                alt="Story preview"
                fill
                className="object-contain"
              />
            </div>

            <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 flex gap-4">
              <button
                onClick={() => fileInputRef.current?.click()}
                disabled={isUploading}
                className="flex items-center gap-2 bg-black bg-opacity-70 text-white px-6 py-3 rounded-full hover:bg-opacity-80 transition-all disabled:opacity-50"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                  />
                </svg>
                Change Photo
              </button>
            </div>
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center py-20">
            <svg className="w-20 h-20 text-gray-600 mb-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
              />
            </svg>
            <h2 className="text-2xl font-bold text-white mb-2">No photo selected</h2>
            <p className="text-gray-400 text-center mb-8 max-w-md">
              Choose a photo from your computer to create a story
            </p>

            <button
              onClick={() => fileInputRef.current?.click()}
              className="flex items-center gap-3 bg-blue-500 text-white px-8 py-3 rounded-lg hover:bg-blue-600 transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                />
              </svg>
              Select Photo
            </button>
          </div>
        )}

        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          onChange={handleFileSelect}
          className="hidden"
        />
      </main>
    </div>
  );
}
