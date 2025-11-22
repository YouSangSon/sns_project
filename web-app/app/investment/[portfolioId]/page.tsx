'use client';

import React, { useState } from 'react';
import { use } from 'react';
import {
  usePortfolio,
  usePortfolioHoldings,
  usePortfolioAnalytics,
} from '@/lib/hooks/usePortfolios';
import type { Holding } from '@shared/types';

export default function PortfolioDetailPage({
  params,
}: {
  params: Promise<{ portfolioId: string }>;
}) {
  const resolvedParams = use(params);
  const { portfolioId } = resolvedParams;

  const { data: portfolio } = usePortfolio(portfolioId);
  const { data: holdings } = usePortfolioHoldings(portfolioId);
  const { data: analytics } = usePortfolioAnalytics(portfolioId);

  const [selectedTab, setSelectedTab] = useState<'holdings' | 'analytics'>('holdings');

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

  if (!portfolio) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-gray-500">로딩 중...</div>
      </div>
    );
  }

  const profitColor = portfolio.totalProfitRate >= 0 ? 'text-green-600' : 'text-red-600';

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 py-8">
        {/* Portfolio Header */}
        <div className="bg-white rounded-xl shadow-md p-8 mb-6">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">{portfolio.name}</h1>
          {portfolio.description && (
            <p className="text-gray-600 mb-6">{portfolio.description}</p>
          )}

          <div className="mb-6">
            <p className="text-sm text-gray-500 mb-2">총 자산 가치</p>
            <p className="text-5xl font-bold text-gray-900">
              {formatCurrency(portfolio.totalValue, portfolio.currency)}
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <p className="text-sm text-gray-500 mb-1">총 수익/손실</p>
              <p className={`text-2xl font-bold ${profitColor}`}>
                {formatCurrency(portfolio.totalProfit, portfolio.currency)}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-500 mb-1">수익률</p>
              <p className={`text-2xl font-bold ${profitColor}`}>
                {formatPercent(portfolio.totalProfitRate)}
              </p>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-xl shadow-md mb-6">
          <div className="flex border-b border-gray-200">
            <button
              className={`flex-1 py-4 px-6 font-semibold transition ${
                selectedTab === 'holdings'
                  ? 'text-blue-600 border-b-2 border-blue-600'
                  : 'text-gray-500 hover:text-gray-700'
              }`}
              onClick={() => setSelectedTab('holdings')}
            >
              보유 종목
            </button>
            <button
              className={`flex-1 py-4 px-6 font-semibold transition ${
                selectedTab === 'analytics'
                  ? 'text-blue-600 border-b-2 border-blue-600'
                  : 'text-gray-500 hover:text-gray-700'
              }`}
              onClick={() => setSelectedTab('analytics')}
            >
              분석
            </button>
          </div>

          {/* Tab Content */}
          <div className="p-6">
            {selectedTab === 'holdings' ? (
              <div className="space-y-4">
                {holdings && holdings.length > 0 ? (
                  holdings.map((holding: Holding) => {
                    const holdingProfitColor =
                      holding.profitRate >= 0 ? 'text-green-600' : 'text-red-600';

                    return (
                      <div
                        key={holding.holdingId}
                        className="border border-gray-200 rounded-lg p-6 hover:shadow-md transition"
                      >
                        <div className="flex justify-between items-start mb-4">
                          <div>
                            <h3 className="text-xl font-bold text-gray-900">
                              {holding.symbol}
                            </h3>
                            <p className="text-sm text-gray-600">{holding.assetName}</p>
                          </div>
                          <span className="px-3 py-1 bg-blue-500 text-white text-xs font-bold rounded">
                            {holding.assetType.toUpperCase()}
                          </span>
                        </div>

                        <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
                          <div>
                            <p className="text-xs text-gray-500 mb-1">보유 수량</p>
                            <p className="text-sm font-semibold text-gray-900">
                              {holding.quantity.toLocaleString()}
                            </p>
                          </div>

                          <div>
                            <p className="text-xs text-gray-500 mb-1">평균 단가</p>
                            <p className="text-sm font-semibold text-gray-900">
                              {formatCurrency(holding.averagePrice, holding.currency)}
                            </p>
                          </div>

                          <div>
                            <p className="text-xs text-gray-500 mb-1">현재가</p>
                            <p className="text-sm font-semibold text-gray-900">
                              {formatCurrency(holding.currentPrice, holding.currency)}
                            </p>
                          </div>

                          <div>
                            <p className="text-xs text-gray-500 mb-1">평가금액</p>
                            <p className="text-sm font-bold text-gray-900">
                              {formatCurrency(holding.totalValue, holding.currency)}
                            </p>
                          </div>

                          <div>
                            <p className="text-xs text-gray-500 mb-1">수익률</p>
                            <p className={`text-sm font-bold ${holdingProfitColor}`}>
                              {formatPercent(holding.profitRate)}
                            </p>
                          </div>
                        </div>
                      </div>
                    );
                  })
                ) : (
                  <div className="text-center py-12">
                    <p className="text-gray-500">보유 종목이 없습니다</p>
                  </div>
                )}
              </div>
            ) : (
              <div className="space-y-6">
                {analytics ? (
                  <>
                    {/* Asset Allocation */}
                    <div className="border border-gray-200 rounded-lg p-6">
                      <h3 className="text-lg font-bold text-gray-900 mb-4">자산 배분</h3>
                      <div className="space-y-4">
                        {analytics.assetAllocation.map((allocation, index) => (
                          <div key={index}>
                            <div className="flex justify-between items-center mb-2">
                              <span className="text-sm font-medium text-gray-900 capitalize">
                                {allocation.assetType}
                              </span>
                              <span className="text-sm font-bold text-blue-600">
                                {allocation.percentage.toFixed(1)}%
                              </span>
                            </div>
                            <div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
                              <div
                                className="bg-blue-600 h-2 rounded-full transition-all"
                                style={{ width: `${allocation.percentage}%` }}
                              />
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* Daily Change */}
                    <div className="border border-gray-200 rounded-lg p-6">
                      <h3 className="text-lg font-bold text-gray-900 mb-4">일일 변동</h3>
                      <div className="text-center">
                        <p
                          className={`text-4xl font-bold ${
                            analytics.dailyChange >= 0 ? 'text-green-600' : 'text-red-600'
                          }`}
                        >
                          {formatCurrency(analytics.dailyChange, portfolio.currency)}
                        </p>
                        <p
                          className={`text-2xl font-semibold mt-2 ${
                            analytics.dailyChangeRate >= 0
                              ? 'text-green-600'
                              : 'text-red-600'
                          }`}
                        >
                          {formatPercent(analytics.dailyChangeRate)}
                        </p>
                      </div>
                    </div>
                  </>
                ) : (
                  <div className="text-center py-12">
                    <p className="text-gray-500">분석 데이터를 로드하는 중...</p>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
