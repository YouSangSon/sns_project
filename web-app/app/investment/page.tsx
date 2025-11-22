'use client';

import React from 'react';
import Link from 'next/link';
import { usePortfolios } from '@/lib/hooks/usePortfolios';
import type { Portfolio } from '@shared/types';

export default function InvestmentPage() {
  const { data: portfolios, isLoading } = usePortfolios();

  const formatCurrency = (value: number, currency: string) => {
    return new Intl.NumberFormat('ko-KR', {
      style: 'currency',
      currency: currency || 'USD',
    }).format(value);
  };

  const formatPercent = (value: number) => {
    const sign = value >= 0 ? '+' : '';
    return `${sign}${value.toFixed(2)}%`;
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-gray-500">로딩 중...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 py-8">
        {/* Header */}
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">내 포트폴리오</h1>
          <Link
            href="/investment/create"
            className="px-6 py-3 bg-blue-500 text-white rounded-lg font-semibold hover:bg-blue-600 transition"
          >
            + 포트폴리오 생성
          </Link>
        </div>

        {/* Portfolio Grid */}
        {portfolios?.data && portfolios.data.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {portfolios.data.map((portfolio: Portfolio) => {
              const profitColor = portfolio.totalProfitRate >= 0 ? 'text-green-600' : 'text-red-600';

              return (
                <Link
                  key={portfolio.portfolioId}
                  href={`/investment/${portfolio.portfolioId}`}
                  className="bg-white rounded-xl shadow-md hover:shadow-lg transition p-6"
                >
                  {/* Portfolio Header */}
                  <div className="flex justify-between items-start mb-4">
                    <div>
                      <h2 className="text-xl font-bold text-gray-900">
                        {portfolio.name}
                      </h2>
                      {portfolio.isPublic && (
                        <span className="inline-flex items-center text-xs text-gray-500 mt-1">
                          <svg
                            className="w-4 h-4 mr-1"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth={2}
                              d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                            />
                          </svg>
                          공개
                        </span>
                      )}
                    </div>
                    <span className="text-sm font-medium text-gray-600">
                      {portfolio.currency}
                    </span>
                  </div>

                  {/* Description */}
                  {portfolio.description && (
                    <p className="text-sm text-gray-600 mb-4 line-clamp-2">
                      {portfolio.description}
                    </p>
                  )}

                  {/* Stats */}
                  <div className="space-y-3 mb-4">
                    <div>
                      <p className="text-xs text-gray-500 mb-1">총 자산</p>
                      <p className="text-2xl font-bold text-gray-900">
                        {formatCurrency(portfolio.totalValue, portfolio.currency)}
                      </p>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-xs text-gray-500 mb-1">수익률</p>
                        <p className={`text-lg font-bold ${profitColor}`}>
                          {formatPercent(portfolio.totalProfitRate)}
                        </p>
                      </div>

                      <div>
                        <p className="text-xs text-gray-500 mb-1">수익/손실</p>
                        <p className={`text-lg font-bold ${profitColor}`}>
                          {formatCurrency(portfolio.totalProfit, portfolio.currency)}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Footer */}
                  <div className="flex justify-between items-center pt-4 border-t border-gray-200">
                    <div className="flex items-center text-xs text-gray-500">
                      <svg
                        className="w-4 h-4 mr-1"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                        />
                      </svg>
                      {portfolio.followers} 팔로워
                    </div>
                    <span className="text-xs text-gray-500">
                      {new Date(portfolio.createdAt).toLocaleDateString('ko-KR')}
                    </span>
                  </div>
                </Link>
              );
            })}
          </div>
        ) : (
          <div className="text-center py-20">
            <svg
              className="mx-auto h-16 w-16 text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
              />
            </svg>
            <h3 className="mt-4 text-lg font-semibold text-gray-900">
              포트폴리오가 없습니다
            </h3>
            <p className="mt-2 text-sm text-gray-500">
              새 포트폴리오를 만들어 투자 내역을 관리하세요
            </p>
            <Link
              href="/investment/create"
              className="mt-6 inline-block px-6 py-3 bg-blue-500 text-white rounded-lg font-semibold hover:bg-blue-600 transition"
            >
              포트폴리오 생성
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
