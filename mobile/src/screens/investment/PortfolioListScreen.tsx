import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  RefreshControl,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { usePortfolios } from '../../hooks/usePortfolios';
import type { Portfolio } from '@shared/types';

export default function PortfolioListScreen() {
  const navigation = useNavigation();
  const { data: portfolios, isLoading, refetch } = usePortfolios();

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

  const renderPortfolioItem = ({ item }: { item: Portfolio }) => {
    const profitColor = item.totalProfitRate >= 0 ? '#34C759' : '#FF3B30';

    return (
      <TouchableOpacity
        style={styles.portfolioCard}
        onPress={() => navigation.navigate('PortfolioDetail' as never, { portfolioId: item.portfolioId } as never)}
      >
        <View style={styles.portfolioHeader}>
          <View style={styles.portfolioTitleContainer}>
            <Text style={styles.portfolioName}>{item.name}</Text>
            {item.isPublic && (
              <Ionicons name="globe-outline" size={16} color="#8E8E93" />
            )}
          </View>
          <Text style={styles.portfolioCurrency}>{item.currency}</Text>
        </View>

        {item.description && (
          <Text style={styles.portfolioDescription} numberOfLines={2}>
            {item.description}
          </Text>
        )}

        <View style={styles.portfolioStats}>
          <View style={styles.statItem}>
            <Text style={styles.statLabel}>총 자산</Text>
            <Text style={styles.statValue}>
              {formatCurrency(item.totalValue, item.currency)}
            </Text>
          </View>

          <View style={styles.statItem}>
            <Text style={styles.statLabel}>수익률</Text>
            <Text style={[styles.statValue, { color: profitColor }]}>
              {formatPercent(item.totalProfitRate)}
            </Text>
          </View>

          <View style={styles.statItem}>
            <Text style={styles.statLabel}>수익/손실</Text>
            <Text style={[styles.statValue, { color: profitColor }]}>
              {formatCurrency(item.totalProfit, item.currency)}
            </Text>
          </View>
        </View>

        <View style={styles.portfolioFooter}>
          <View style={styles.followersContainer}>
            <Ionicons name="people-outline" size={14} color="#8E8E93" />
            <Text style={styles.followersText}>{item.followers} 팔로워</Text>
          </View>
          <Text style={styles.portfolioDate}>
            {new Date(item.createdAt).toLocaleDateString('ko-KR')}
          </Text>
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>내 포트폴리오</Text>
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => navigation.navigate('CreatePortfolio' as never)}
        >
          <Ionicons name="add-circle" size={28} color="#007AFF" />
        </TouchableOpacity>
      </View>

      <FlatList
        data={portfolios?.data || []}
        renderItem={renderPortfolioItem}
        keyExtractor={(item) => item.portfolioId}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl refreshing={isLoading} onRefresh={refetch} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Ionicons name="briefcase-outline" size={64} color="#C7C7CC" />
            <Text style={styles.emptyText}>포트폴리오가 없습니다</Text>
            <Text style={styles.emptySubtext}>
              새 포트폴리오를 만들어 투자 내역을 관리하세요
            </Text>
          </View>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F2F2F7',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#E5E5EA',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: '700',
    color: '#000000',
  },
  addButton: {
    padding: 4,
  },
  listContainer: {
    padding: 16,
  },
  portfolioCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  portfolioHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  portfolioTitleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  portfolioName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
  },
  portfolioCurrency: {
    fontSize: 14,
    fontWeight: '500',
    color: '#8E8E93',
  },
  portfolioDescription: {
    fontSize: 14,
    color: '#8E8E93',
    marginBottom: 16,
  },
  portfolioStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  statItem: {
    flex: 1,
  },
  statLabel: {
    fontSize: 12,
    color: '#8E8E93',
    marginBottom: 4,
  },
  statValue: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000000',
  },
  portfolioFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#E5E5EA',
  },
  followersContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  followersText: {
    fontSize: 12,
    color: '#8E8E93',
  },
  portfolioDate: {
    fontSize: 12,
    color: '#8E8E93',
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
  emptySubtext: {
    fontSize: 14,
    color: '#C7C7CC',
    marginTop: 8,
    textAlign: 'center',
    paddingHorizontal: 32,
  },
});
