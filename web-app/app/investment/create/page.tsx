'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useCreatePortfolio } from '@/lib/hooks/usePortfolios';

export default function CreatePortfolioPage() {
  const router = useRouter();
  const createPortfolioMutation = useCreatePortfolio();

  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [currency, setCurrency] = useState('USD');
  const [isPublic, setIsPublic] = useState(false);

  const currencies = ['USD', 'KRW', 'EUR', 'JPY', 'CNY'];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!name.trim()) {
      alert('포트폴리오 이름을 입력하세요');
      return;
    }

    try {
      await createPortfolioMutation.mutateAsync({
        name: name.trim(),
        description: description.trim() || undefined,
        currency,
        isPublic,
      });

      alert('포트폴리오가 생성되었습니다');
      router.push('/investment');
    } catch (error) {
      alert('포트폴리오 생성에 실패했습니다');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-3xl mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">포트폴리오 생성</h1>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Basic Information */}
          <div className="bg-white rounded-xl shadow-md p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-6">기본 정보</h2>

            <div className="space-y-4">
              <div>
                <label
                  htmlFor="name"
                  className="block text-sm font-semibold text-gray-900 mb-2"
                >
                  포트폴리오 이름 *
                </label>
                <input
                  type="text"
                  id="name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="예: 미국 주식 포트폴리오"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  required
                />
              </div>

              <div>
                <label
                  htmlFor="description"
                  className="block text-sm font-semibold text-gray-900 mb-2"
                >
                  설명
                </label>
                <textarea
                  id="description"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="포트폴리오에 대한 설명을 입력하세요"
                  rows={4}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-900 mb-2">
                  기본 통화
                </label>
                <div className="flex flex-wrap gap-3">
                  {currencies.map((curr) => (
                    <button
                      key={curr}
                      type="button"
                      onClick={() => setCurrency(curr)}
                      className={`px-6 py-2 rounded-lg font-semibold transition ${
                        currency === curr
                          ? 'bg-blue-500 text-white'
                          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                      }`}
                    >
                      {curr}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Public Settings */}
          <div className="bg-white rounded-xl shadow-md p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-6">공개 설정</h2>

            <div className="flex items-center justify-between">
              <div>
                <p className="font-semibold text-gray-900">공개 포트폴리오</p>
                <p className="text-sm text-gray-500 mt-1">
                  다른 사용자들이 내 포트폴리오를 볼 수 있습니다
                </p>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={isPublic}
                  onChange={(e) => setIsPublic(e.target.checked)}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-green-500"></div>
              </label>
            </div>
          </div>

          {/* Actions */}
          <div className="flex gap-4">
            <button
              type="submit"
              disabled={createPortfolioMutation.isPending}
              className="flex-1 py-4 bg-blue-500 text-white rounded-lg font-semibold hover:bg-blue-600 transition disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {createPortfolioMutation.isPending ? '생성 중...' : '포트폴리오 생성'}
            </button>

            <button
              type="button"
              onClick={() => router.back()}
              className="flex-1 py-4 bg-white text-blue-500 border border-blue-500 rounded-lg font-semibold hover:bg-blue-50 transition"
            >
              취소
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
