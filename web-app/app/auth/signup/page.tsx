'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useAuth } from '../../../lib/hooks/useAuth';
import { Button, Input } from '../../../components/ui';
import { APP_CONFIG } from '../../../lib/constants';

export default function SignupPage() {
  const { register, isRegistering, registerError } = useAuth();

  const [formData, setFormData] = useState({
    email: '',
    username: '',
    displayName: '',
    password: '',
    confirmPassword: '',
  });

  const [errors, setErrors] = useState({
    email: '',
    username: '',
    displayName: '',
    password: '',
    confirmPassword: '',
  });

  const updateField = (field: keyof typeof formData, value: string) => {
    setFormData({ ...formData, [field]: value });
    setErrors({ ...errors, [field]: '' });
  };

  const validateForm = () => {
    let valid = true;
    const newErrors = {
      email: '',
      username: '',
      displayName: '',
      password: '',
      confirmPassword: '',
    };

    // Email validation
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
      valid = false;
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Email is invalid';
      valid = false;
    }

    // Username validation
    if (!formData.username.trim()) {
      newErrors.username = 'Username is required';
      valid = false;
    } else if (formData.username.length < 3) {
      newErrors.username = 'Username must be at least 3 characters';
      valid = false;
    } else if (!/^[a-zA-Z0-9_]+$/.test(formData.username)) {
      newErrors.username = 'Username can only contain letters, numbers, and underscores';
      valid = false;
    }

    // Display name validation
    if (!formData.displayName.trim()) {
      newErrors.displayName = 'Display name is required';
      valid = false;
    }

    // Password validation
    if (!formData.password) {
      newErrors.password = 'Password is required';
      valid = false;
    } else if (formData.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
      valid = false;
    }

    // Confirm password validation
    if (!formData.confirmPassword) {
      newErrors.confirmPassword = 'Please confirm your password';
      valid = false;
    } else if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
      valid = false;
    }

    setErrors(newErrors);
    return valid;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateForm()) {
      register({
        email: formData.email.trim(),
        username: formData.username.trim(),
        displayName: formData.displayName.trim(),
        password: formData.password,
      });
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Logo */}
        <div className="text-center">
          <h1 className="text-5xl font-bold text-gray-900 mb-2">
            {APP_CONFIG.APP_NAME}
          </h1>
          <p className="text-gray-600">
            Sign up to see photos and videos from your friends
          </p>
        </div>

        {/* Form */}
        <div className="bg-white p-8 border border-gray-300 rounded-lg">
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              type="email"
              label="Email"
              placeholder="Enter your email"
              value={formData.email}
              onChange={(e) => updateField('email', e.target.value)}
              error={errors.email}
            />

            <Input
              type="text"
              label="Username"
              placeholder="Choose a username"
              value={formData.username}
              onChange={(e) => updateField('username', e.target.value)}
              error={errors.username}
            />

            <Input
              type="text"
              label="Display Name"
              placeholder="Enter your display name"
              value={formData.displayName}
              onChange={(e) => updateField('displayName', e.target.value)}
              error={errors.displayName}
            />

            <Input
              type="password"
              label="Password"
              placeholder="Create a password"
              value={formData.password}
              onChange={(e) => updateField('password', e.target.value)}
              error={errors.password}
            />

            <Input
              type="password"
              label="Confirm Password"
              placeholder="Confirm your password"
              value={formData.confirmPassword}
              onChange={(e) => updateField('confirmPassword', e.target.value)}
              error={errors.confirmPassword}
            />

            {registerError && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
                <p className="text-sm">
                  {(registerError as any)?.response?.data?.message || 'Registration failed. Please try again.'}
                </p>
              </div>
            )}

            <Button
              type="submit"
              fullWidth
              loading={isRegistering}
              disabled={isRegistering}
            >
              Sign Up
            </Button>

            <p className="text-xs text-gray-500 text-center mt-4">
              By signing up, you agree to our Terms, Data Policy and Cookies Policy.
            </p>
          </form>
        </div>

        {/* Login Link */}
        <div className="bg-white p-4 border border-gray-300 rounded-lg text-center">
          <p className="text-sm text-gray-600">
            Have an account?{' '}
            <Link href="/auth/login" className="text-blue-500 font-semibold hover:underline">
              Log in
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
