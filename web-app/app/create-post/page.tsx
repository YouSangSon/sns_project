'use client';

import React, { useState, useRef, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useAuthStore } from '../../lib/stores/authStore';
import { useCreatePost } from '../../lib/hooks/usePosts';
import { Loading } from '../../components/ui';
import { AppLayout } from '../../components/layout';
import type { CreatePostDto } from '@shared/types';

export default function CreatePostPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();
  const createPostMutation = useCreatePost();

  const [selectedImages, setSelectedImages] = useState<string[]>([]);
  const [caption, setCaption] = useState('');
  const [location, setLocation] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Redirect if not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files) return;

    const maxImages = 10;
    const remainingSlots = maxImages - selectedImages.length;

    if (remainingSlots <= 0) {
      alert(`You can only select up to ${maxImages} images.`);
      return;
    }

    const fileArray = Array.from(files).slice(0, remainingSlots);
    const imageUrls = fileArray.map((file) => URL.createObjectURL(file));

    setSelectedImages((prev) => [...prev, ...imageUrls]);
  };

  const removeImage = (index: number) => {
    setSelectedImages((prev) => {
      const newImages = prev.filter((_, i) => i !== index);
      // Revoke URL to free memory
      URL.revokeObjectURL(prev[index]);
      return newImages;
    });
  };

  const handlePost = async () => {
    if (selectedImages.length === 0) {
      alert('Please select at least one image.');
      return;
    }

    try {
      // In production, you would upload images to S3/CDN first
      const postData: CreatePostDto = {
        caption: caption.trim(),
        imageUrls: selectedImages, // These would be uploaded URLs
        location: location.trim() || undefined,
      };

      await createPostMutation.mutateAsync(postData);

      alert('Post created successfully!');

      // Clean up object URLs
      selectedImages.forEach((url) => URL.revokeObjectURL(url));

      router.push('/feed');
    } catch (error) {
      console.error('Error creating post:', error);
      alert('Failed to create post. Please try again.');
    }
  };

  const handleCancel = () => {
    if (
      selectedImages.length > 0 ||
      caption.trim() ||
      location.trim()
    ) {
      if (confirm('Are you sure you want to discard this post?')) {
        selectedImages.forEach((url) => URL.revokeObjectURL(url));
        router.push('/feed');
      }
    } else {
      router.push('/feed');
    }
  };

  if (!isAuthenticated) {
    return (
      <AppLayout>
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <Loading size="lg" />
        </div>
      </AppLayout>
    );
  }

  return (
    <AppLayout>
      <div className="min-h-screen bg-gray-50">
        {/* Main Content */}
        <main className="max-w-2xl mx-auto px-4 py-8 pb-20 lg:pb-8">
          {/* Header */}
          <div className="flex items-center justify-between mb-6">
            <button
              onClick={handleCancel}
              className="text-gray-700 hover:text-gray-900 font-semibold"
            >
              Cancel
            </button>
            <h1 className="text-2xl font-bold">Create Post</h1>
            <button
              onClick={handlePost}
              disabled={createPostMutation.isPending || selectedImages.length === 0}
              className={`font-semibold px-4 py-2 rounded-lg ${
                createPostMutation.isPending || selectedImages.length === 0
                  ? 'bg-blue-300 text-white cursor-not-allowed'
                  : 'bg-blue-500 text-white hover:bg-blue-600'
              }`}
            >
              {createPostMutation.isPending ? 'Posting...' : 'Post'}
            </button>
          </div>

        <div className="bg-white rounded-lg border border-gray-300 p-6">
          {/* Image Selection */}
          <div className="mb-6">
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              multiple
              onChange={handleImageSelect}
              className="hidden"
            />
            <button
              onClick={() => fileInputRef.current?.click()}
              className="w-full border-2 border-dashed border-blue-500 rounded-lg p-8 flex flex-col items-center justify-center hover:bg-blue-50 transition-colors"
            >
              <svg
                className="w-12 h-12 text-blue-500 mb-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                />
              </svg>
              <span className="text-blue-500 font-medium">
                {selectedImages.length === 0
                  ? 'Select Images'
                  : `${selectedImages.length} image${
                      selectedImages.length > 1 ? 's' : ''
                    } selected`}
              </span>
            </button>
          </div>

          {/* Selected Images Preview */}
          {selectedImages.length > 0 && (
            <div className="mb-6">
              <div className="grid grid-cols-5 gap-3">
                {selectedImages.map((url, index) => (
                  <div key={index} className="relative aspect-square">
                    <Image
                      src={url}
                      alt={`Selected ${index + 1}`}
                      fill
                      className="object-cover rounded-lg"
                    />
                    <button
                      onClick={() => removeImage(index)}
                      className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600"
                    >
                      <svg
                        className="w-4 h-4"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M6 18L18 6M6 6l12 12"
                        />
                      </svg>
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Caption Input */}
          <div className="mb-6">
            <label className="block text-sm font-semibold mb-2">Caption</label>
            <textarea
              value={caption}
              onChange={(e) => setCaption(e.target.value)}
              placeholder="Write a caption..."
              maxLength={2200}
              rows={4}
              className="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
            />
            <div className="text-right text-sm text-gray-500 mt-1">
              {caption.length}/2200
            </div>
          </div>

          {/* Location Input */}
          <div>
            <label className="block text-sm font-semibold mb-2">Location</label>
            <input
              type="text"
              value={location}
              onChange={(e) => setLocation(e.target.value)}
              placeholder="Add location"
              maxLength={100}
              className="w-full border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>
        </main>
      </div>
    </AppLayout>
  );
}
