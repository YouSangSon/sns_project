'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useAuth } from '../../../lib/hooks/useAuth';
import { Button, Input } from '../../../components/ui';
import { APP_CONFIG } from '../../../lib/constants';

export default function LoginPage() {
  const { login, isLoggingIn, loginError } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState({ email: '', password: '' });

  const validateForm = () => {
    let valid = true;
    const newErrors = { email: '', password: '' };

    // Email validation
    if (!email.trim()) {
      newErrors.email = 'Email is required';
      valid = false;
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      newErrors.email = 'Email is invalid';
      valid = false;
    }

    // Password validation
    if (!password) {
      newErrors.password = 'Password is required';
      valid = false;
    } else if (password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
      valid = false;
    }

    setErrors(newErrors);
    return valid;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateForm()) {
      login({ email: email.trim(), password });
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
            Sign in to see photos and videos from your friends
          </p>
        </div>

        {/* Form */}
        <div className="bg-white p-8 border border-gray-300 rounded-lg">
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              type="email"
              label="Email"
              placeholder="Enter your email"
              value={email}
              onChange={(e) => {
                setEmail(e.target.value);
                setErrors({ ...errors, email: '' });
              }}
              error={errors.email}
            />

            <Input
              type="password"
              label="Password"
              placeholder="Enter your password"
              value={password}
              onChange={(e) => {
                setPassword(e.target.value);
                setErrors({ ...errors, password: '' });
              }}
              error={errors.password}
            />

            {loginError && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
                <p className="text-sm">
                  {(loginError as any)?.response?.data?.message || 'Login failed. Please try again.'}
                </p>
              </div>
            )}

            <Button
              type="submit"
              fullWidth
              loading={isLoggingIn}
              disabled={isLoggingIn}
            >
              Log In
            </Button>

            <div className="text-center">
              <Link href="/auth/forgot-password" className="text-sm text-blue-500 hover:underline">
                Forgot password?
              </Link>
            </div>
          </form>
        </div>

        {/* Divider */}
        <div className="flex items-center">
          <div className="flex-1 border-t border-gray-300"></div>
          <span className="px-4 text-sm text-gray-500 font-semibold">OR</span>
          <div className="flex-1 border-t border-gray-300"></div>
        </div>

        {/* Social Login (Placeholder) */}
        <Button variant="outline" fullWidth className="bg-white">
          Continue with Google
        </Button>

        {/* Sign Up Link */}
        <div className="bg-white p-4 border border-gray-300 rounded-lg text-center">
          <p className="text-sm text-gray-600">
            Don't have an account?{' '}
            <Link href="/auth/signup" className="text-blue-500 font-semibold hover:underline">
              Sign up
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
