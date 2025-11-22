import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  FlatList,
  RefreshControl,
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { usePortfolio, usePortfolioHoldings, usePortfolioAnalytics } from '../../hooks/usePortfolios';
import type { Holding } from '@shared/types';

export default function PortfolioDetailScreen() {
  const route = useRoute();
  const navigation = useNavigation();
  const { portfolioId } = route.params as { portfolioId: string };

  const { data: portfolio, isLoading, refetch } = usePortfolio(portfolioId);
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

  const renderHolding = ({ item }: { item: Holding }) => {
    const profitColor = item.profitRate >= 0 ? '#34C759' : '#FF3B30';

    return (
      <View style={styles.holdingCard}>
        <View style={styles.holdingHeader}>
          <View>
            <Text style={styles.holdingSymbol}>{item.symbol}</Text>
            <Text style={styles.holdingName}>{item.assetName}</Text>
          </View>
          <View style={styles.assetTypeTag}>
            <Text style={styles.assetTypeText}>{item.assetType.toUpperCase()}</Text>
          </View>
        </View>

        <View style={styles.holdingStats}>
          <View style={styles.holdingStatRow}>
            <Text style={styles.holdingStatLabel}>보유 수량</Text>
            <Text style={styles.holdingStatValue}>{item.quantity.toLocaleString()}</Text>
          </View>

          <View style={styles.holdingStatRow}>
            <Text style={styles.holdingStatLabel}>평균 단가</Text>
            <Text style={styles.holdingStatValue}>
              {formatCurrency(item.averagePrice, item.currency)}
            </Text>
          </View>

          <View style={styles.holdingStatRow}>
            <Text style={styles.holdingStatLabel}>현재가</Text>
            <Text style={styles.holdingStatValue}>
              {formatCurrency(item.currentPrice, item.currency)}
            </Text>
          </View>

          <View style={styles.holdingStatRow}>
            <Text style={styles.holdingStatLabel}>평가금액</Text>
            <Text style={[styles.holdingStatValue, { fontWeight: '700' }]}>
              {formatCurrency(item.totalValue, item.currency)}
            </Text>
          </View>

          <View style={styles.holdingStatRow}>
            <Text style={styles.holdingStatLabel}>수익률</Text>
            <Text style={[styles.holdingStatValue, { color: profitColor, fontWeight: '700' }]}>
              {formatPercent(item.profitRate)}
            </Text>
          </View>
        </View>
      </View>
    );
  };

  const renderAnalytics = () => {
    if (!analytics) return null;

    return (
      <View style={styles.analyticsContainer}>
        <View style={styles.analyticsCard}>
          <Text style={styles.analyticsTitle}>자산 배분</Text>
          {analytics.assetAllocation.map((allocation, index) => (
            <View key={index} style={styles.allocationRow}>
              <View style={styles.allocationBar}>
                <View
                  style={[
                    styles.allocationFill,
                    { width: `${allocation.percentage}%` },
                  ]}
                />
              </View>
              <View style={styles.allocationInfo}>
                <Text style={styles.allocationType}>{allocation.assetType}</Text>
                <Text style={styles.allocationPercent}>
                  {allocation.percentage.toFixed(1)}%
                </Text>
              </View>
            </View>
          ))}
        </View>

        <View style={styles.analyticsCard}>
          <Text style={styles.analyticsTitle}>일일 변동</Text>
          <View style={styles.dailyChangeContainer}>
            <Text
              style={[
                styles.dailyChangeValue,
                { color: analytics.dailyChange >= 0 ? '#34C759' : '#FF3B30' },
              ]}
            >
              {formatCurrency(analytics.dailyChange, portfolio?.currency || 'USD')}
            </Text>
            <Text
              style={[
                styles.dailyChangePercent,
                { color: analytics.dailyChangeRate >= 0 ? '#34C759' : '#FF3B30' },
              ]}
            >
              {formatPercent(analytics.dailyChangeRate)}
            </Text>
          </View>
        </View>
      </View>
    );
  };

  if (!portfolio) {
    return (
      <View style={styles.container}>
        <Text>Loading...</Text>
      </View>
    );
  }

  const profitColor = portfolio.totalProfitRate >= 0 ? '#34C759' : '#FF3B30';

  return (
    <ScrollView
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={isLoading} onRefresh={refetch} />
      }
    >
      <View style={styles.portfolioHeader}>
        <Text style={styles.portfolioName}>{portfolio.name}</Text>
        {portfolio.description && (
          <Text style={styles.portfolioDescription}>{portfolio.description}</Text>
        )}

        <View style={styles.portfolioTotalContainer}>
          <Text style={styles.portfolioTotalLabel}>총 자산 가치</Text>
          <Text style={styles.portfolioTotalValue}>
            {formatCurrency(portfolio.totalValue, portfolio.currency)}
          </Text>
        </View>

        <View style={styles.portfolioProfitContainer}>
          <View style={styles.profitItem}>
            <Text style={styles.profitLabel}>총 수익/손실</Text>
            <Text style={[styles.profitValue, { color: profitColor }]}>
              {formatCurrency(portfolio.totalProfit, portfolio.currency)}
            </Text>
          </View>
          <View style={styles.profitItem}>
            <Text style={styles.profitLabel}>수익률</Text>
            <Text style={[styles.profitValue, { color: profitColor }]}>
              {formatPercent(portfolio.totalProfitRate)}
            </Text>
          </View>
        </View>
      </View>

      <View style={styles.tabContainer}>
        <TouchableOpacity
          style={[styles.tab, selectedTab === 'holdings' && styles.activeTab]}
          onPress={() => setSelectedTab('holdings')}
        >
          <Text style={[styles.tabText, selectedTab === 'holdings' && styles.activeTabText]}>
            보유 종목
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, selectedTab === 'analytics' && styles.activeTab]}
          onPress={() => setSelectedTab('analytics')}
        >
          <Text style={[styles.tabText, selectedTab === 'analytics' && styles.activeTabText]}>
            분석
          </Text>
        </TouchableOpacity>
      </View>

      {selectedTab === 'holdings' ? (
        <View style={styles.holdingsContainer}>
          {holdings && holdings.length > 0 ? (
            holdings.map((holding) => (
              <View key={holding.holdingId}>{renderHolding({ item: holding })}</View>
            ))
          ) : (
            <View style={styles.emptyContainer}>
              <Ionicons name="pie-chart-outline" size={64} color="#C7C7CC" />
              <Text style={styles.emptyText}>보유 종목이 없습니다</Text>
            </View>
          )}
        </View>
      ) : (
        renderAnalytics()
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F2F2F7',
  },
  portfolioHeader: {
    backgroundColor: '#FFFFFF',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E5EA',
  },
  portfolioName: {
    fontSize: 28,
    fontWeight: '700',
    color: '#000000',
    marginBottom: 8,
  },
  portfolioDescription: {
    fontSize: 14,
    color: '#8E8E93',
    marginBottom: 20,
  },
  portfolioTotalContainer: {
    marginBottom: 16,
  },
  portfolioTotalLabel: {
    fontSize: 14,
    color: '#8E8E93',
    marginBottom: 4,
  },
  portfolioTotalValue: {
    fontSize: 32,
    fontWeight: '700',
    color: '#000000',
  },
  portfolioProfitContainer: {
    flexDirection: 'row',
    gap: 24,
  },
  profitItem: {
    flex: 1,
  },
  profitLabel: {
    fontSize: 12,
    color: '#8E8E93',
    marginBottom: 4,
  },
  profitValue: {
    fontSize: 18,
    fontWeight: '600',
  },
  tabContainer: {
    flexDirection: 'row',
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#E5E5EA',
  },
  tab: {
    flex: 1,
    paddingVertical: 16,
    alignItems: 'center',
    borderBottomWidth: 2,
    borderBottomColor: 'transparent',
  },
  activeTab: {
    borderBottomColor: '#007AFF',
  },
  tabText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#8E8E93',
  },
  activeTabText: {
    color: '#007AFF',
    fontWeight: '600',
  },
  holdingsContainer: {
    padding: 16,
  },
  holdingCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
  },
  holdingHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 16,
  },
  holdingSymbol: {
    fontSize: 20,
    fontWeight: '700',
    color: '#000000',
  },
  holdingName: {
    fontSize: 14,
    color: '#8E8E93',
    marginTop: 2,
  },
  assetTypeTag: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  assetTypeText: {
    fontSize: 10,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  holdingStats: {
    gap: 12,
  },
  holdingStatRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  holdingStatLabel: {
    fontSize: 14,
    color: '#8E8E93',
  },
  holdingStatValue: {
    fontSize: 14,
    fontWeight: '600',
    color: '#000000',
  },
  analyticsContainer: {
    padding: 16,
  },
  analyticsCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
  },
  analyticsTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 16,
  },
  allocationRow: {
    marginBottom: 12,
  },
  allocationBar: {
    height: 8,
    backgroundColor: '#E5E5EA',
    borderRadius: 4,
    marginBottom: 8,
    overflow: 'hidden',
  },
  allocationFill: {
    height: '100%',
    backgroundColor: '#007AFF',
  },
  allocationInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  allocationType: {
    fontSize: 14,
    color: '#000000',
    textTransform: 'capitalize',
  },
  allocationPercent: {
    fontSize: 14,
    fontWeight: '600',
    color: '#007AFF',
  },
  dailyChangeContainer: {
    alignItems: 'center',
  },
  dailyChangeValue: {
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 4,
  },
  dailyChangePercent: {
    fontSize: 18,
    fontWeight: '600',
  },
  emptyContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 64,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#8E8E93',
    marginTop: 16,
  },
});
