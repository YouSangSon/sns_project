import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  RefreshControl,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useWatchlist, useRemoveFromWatchlist } from '../../hooks/useWatchlist';
import type { WatchlistItem } from '@shared/types';

export default function WatchlistScreen() {
  const { data: watchlist, isLoading, refetch } = useWatchlist();
  const removeFromWatchlistMutation = useRemoveFromWatchlist();

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('ko-KR', {
      style: 'currency',
      currency: 'USD',
    }).format(value);
  };

  const formatPercent = (value: number) => {
    const sign = value >= 0 ? '+' : '';
    return `${sign}${value.toFixed(2)}%`;
  };

  const handleRemove = (item: WatchlistItem) => {
    Alert.alert(
      '관심종목 삭제',
      `${item.assetName}을(를) 관심종목에서 삭제하시겠습니까?`,
      [
        { text: '취소', style: 'cancel' },
        {
          text: '삭제',
          style: 'destructive',
          onPress: async () => {
            try {
              await removeFromWatchlistMutation.mutateAsync(item.watchlistId);
            } catch (error) {
              Alert.alert('오류', '관심종목 삭제에 실패했습니다');
            }
          },
        },
      ]
    );
  };

  const renderWatchlistItem = ({ item }: { item: WatchlistItem }) => {
    const hasPrice = item.currentPrice !== undefined;
    const priceChangeColor =
      item.priceChangeRate !== undefined && item.priceChangeRate >= 0
        ? '#34C759'
        : '#FF3B30';

    return (
      <View style={styles.watchlistCard}>
        <View style={styles.cardHeader}>
          <View style={styles.assetInfo}>
            <Text style={styles.assetSymbol}>{item.symbol}</Text>
            <Text style={styles.assetName}>{item.assetName}</Text>
          </View>

          <View style={styles.assetTypeTag}>
            <Text style={styles.assetTypeText}>{item.assetType.toUpperCase()}</Text>
          </View>
        </View>

        {hasPrice && (
          <View style={styles.priceContainer}>
            <View style={styles.priceRow}>
              <Text style={styles.priceLabel}>현재가</Text>
              <Text style={styles.priceValue}>
                {formatCurrency(item.currentPrice!)}
              </Text>
            </View>

            {item.priceChangeRate !== undefined && (
              <View style={styles.priceRow}>
                <Text style={styles.priceLabel}>변동</Text>
                <View style={styles.changeContainer}>
                  {item.priceChange !== undefined && (
                    <Text style={[styles.changeValue, { color: priceChangeColor }]}>
                      {formatCurrency(item.priceChange)}
                    </Text>
                  )}
                  <Text style={[styles.changePercent, { color: priceChangeColor }]}>
                    {formatPercent(item.priceChangeRate)}
                  </Text>
                </View>
              </View>
            )}
          </View>
        )}

        {item.targetPrice !== undefined && (
          <View style={styles.targetPriceContainer}>
            <Ionicons name="flag-outline" size={16} color="#007AFF" />
            <Text style={styles.targetPriceLabel}>목표가</Text>
            <Text style={styles.targetPriceValue}>
              {formatCurrency(item.targetPrice)}
            </Text>
          </View>
        )}

        {item.note && (
          <Text style={styles.note} numberOfLines={2}>
            {item.note}
          </Text>
        )}

        <View style={styles.cardFooter}>
          <Text style={styles.addedDate}>
            추가일: {new Date(item.createdAt).toLocaleDateString('ko-KR')}
          </Text>

          <TouchableOpacity
            style={styles.removeButton}
            onPress={() => handleRemove(item)}
          >
            <Ionicons name="trash-outline" size={20} color="#FF3B30" />
          </TouchableOpacity>
        </View>
      </View>
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>관심종목</Text>
        <TouchableOpacity style={styles.addButton}>
          <Ionicons name="add-circle" size={28} color="#007AFF" />
        </TouchableOpacity>
      </View>

      <FlatList
        data={watchlist?.data || []}
        renderItem={renderWatchlistItem}
        keyExtractor={(item) => item.watchlistId}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl refreshing={isLoading} onRefresh={refetch} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Ionicons name="star-outline" size={64} color="#C7C7CC" />
            <Text style={styles.emptyText}>관심종목이 없습니다</Text>
            <Text style={styles.emptySubtext}>
              관심 있는 종목을 추가하여 추적하세요
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
  watchlistCard: {
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
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  assetInfo: {
    flex: 1,
  },
  assetSymbol: {
    fontSize: 20,
    fontWeight: '700',
    color: '#000000',
  },
  assetName: {
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
  priceContainer: {
    marginBottom: 12,
    gap: 8,
  },
  priceRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  priceLabel: {
    fontSize: 14,
    color: '#8E8E93',
  },
  priceValue: {
    fontSize: 18,
    fontWeight: '700',
    color: '#000000',
  },
  changeContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  changeValue: {
    fontSize: 14,
    fontWeight: '600',
  },
  changePercent: {
    fontSize: 14,
    fontWeight: '600',
  },
  targetPriceContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingVertical: 8,
    paddingHorizontal: 12,
    backgroundColor: '#F2F2F7',
    borderRadius: 8,
    marginBottom: 12,
  },
  targetPriceLabel: {
    fontSize: 12,
    color: '#007AFF',
    fontWeight: '500',
  },
  targetPriceValue: {
    fontSize: 14,
    fontWeight: '700',
    color: '#007AFF',
    marginLeft: 'auto',
  },
  note: {
    fontSize: 14,
    color: '#8E8E93',
    marginBottom: 12,
    fontStyle: 'italic',
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#E5E5EA',
  },
  addedDate: {
    fontSize: 12,
    color: '#8E8E93',
  },
  removeButton: {
    padding: 4,
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
