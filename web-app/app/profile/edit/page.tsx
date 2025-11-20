'use client';

import React, { useState, useRef, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useAuthStore } from '../../../lib/stores/authStore';
import { useUpdateProfile } from '../../../lib/hooks/useProfile';
import { Loading } from '../../../components/ui';

export default function EditProfilePage() {
  const router = useRouter();
  const { user, isAuthenticated } = useAuthStore();
  const updateProfileMutation = useUpdateProfile();

  const [displayName, setDisplayName] = useState(user?.displayName || '');
  const [bio, setBio] = useState(user?.bio || '');
  const [photoUrl, setPhotoUrl] = useState(user?.photoUrl || '');
  const [photoFile, setPhotoFile] = useState<File | null>(null);
  const [hasChanges, setHasChanges] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Redirect if not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  // Update state when user changes
  useEffect(() => {
    if (user) {
      setDisplayName(user.displayName);
      setBio(user.bio || '');
      setPhotoUrl(user.photoUrl || '');
    }
  }, [user]);

  const handlePhotoChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      alert('Please select an image file');
      return;
    }

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      alert('Image size should be less than 5MB');
      return;
    }

    setPhotoFile(file);
    setPhotoUrl(URL.createObjectURL(file));
    setHasChanges(true);
  };

  const handleSave = async () => {
    if (!user?.uid) return;

    const updates: any = {};
    if (displayName !== user.displayName) updates.displayName = displayName;
    if (bio !== (user.bio || '')) updates.bio = bio;
    if (photoUrl !== user.photoUrl) updates.photoUrl = photoUrl;

    if (Object.keys(updates).length === 0) {
      router.back();
      return;
    }

    try {
      await updateProfileMutation.mutateAsync({
        userId: user.uid,
        data: updates,
      });

      alert('Profile updated successfully!');
      router.back();
    } catch (error) {
      console.error('Error updating profile:', error);
      alert('Failed to update profile');
    }
  };

  const handleCancel = () => {
    if (hasChanges) {
      if (confirm('You have unsaved changes. Are you sure you want to discard them?')) {
        router.back();
      }
    } else {
      router.back();
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
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-300 sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-3 flex items-center justify-between">
          <button
            onClick={handleCancel}
            className="p-2 hover:bg-gray-100 rounded-full"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
          <h1 className="text-xl font-bold">Edit Profile</h1>
          <button
            onClick={handleSave}
            disabled={updateProfileMutation.isPending}
            className={`px-4 py-2 rounded-lg font-semibold ${
              updateProfileMutation.isPending
                ? 'text-blue-300 cursor-not-allowed'
                : 'text-blue-500 hover:text-blue-600'
            }`}
          >
            {updateProfileMutation.isPending ? 'Saving...' : 'Save'}
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-2xl mx-auto px-4 py-8">
        <div className="bg-white rounded-lg border border-gray-300 overflow-hidden">
          {/* Profile Photo */}
          <div className="flex flex-col items-center py-8 border-b border-gray-200">
            <div className="relative w-32 h-32 mb-4">
              <Image
                src={photoUrl || 'https://via.placeholder.com/128'}
                alt="Profile"
                fill
                className="rounded-full object-cover"
              />
            </div>
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              onChange={handlePhotoChange}
              className="hidden"
            />
            <button
              onClick={() => fileInputRef.current?.click()}
              className="text-blue-500 hover:text-blue-600 font-semibold"
            >
              Change Profile Photo
            </button>
          </div>

          {/* Display Name */}
          <div className="p-6 border-b border-gray-200">
            <label className="block text-xs font-semibold text-gray-500 uppercase mb-2">
              Name
            </label>
            <input
              type="text"
              value={displayName}
              onChange={(e) => {
                setDisplayName(e.target.value);
                setHasChanges(true);
              }}
              placeholder="Your name"
              maxLength={50}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <p className="text-xs text-gray-500 mt-2">
              Help people discover your account by using the name you're known by.
            </p>
          </div>

          {/* Username (read-only) */}
          <div className="p-6 border-b border-gray-200">
            <label className="block text-xs font-semibold text-gray-500 uppercase mb-2">
              Username
            </label>
            <div className="px-3 py-2 bg-gray-100 rounded-lg">
              <span className="text-gray-500">@{user?.username}</span>
            </div>
            <p className="text-xs text-gray-500 mt-2">
              Username cannot be changed.
            </p>
          </div>

          {/* Bio */}
          <div className="p-6">
            <label className="block text-xs font-semibold text-gray-500 uppercase mb-2">
              Bio
            </label>
            <textarea
              value={bio}
              onChange={(e) => {
                setBio(e.target.value);
                setHasChanges(true);
              }}
              placeholder="Tell us about yourself"
              maxLength={150}
              rows={4}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
            />
            <div className="text-xs text-gray-500 mt-1 text-right">
              {bio.length}/150
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
