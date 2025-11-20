import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  FlatList,
  StyleSheet,
  ActivityIndicator,
  Image,
  Dimensions,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Ionicons } from '@expo/vector-icons';
import { useBookmarks, useDeleteBookmark } from '../../hooks/useBookmarks';
import type { Bookmark } from '../../../../shared/types';
import type { RootStackParamList } from '../../navigation/types';

const { width: SCREEN_WIDTH } = Dimensions.get('window');
const ITEM_WIDTH = (SCREEN_WIDTH - 3) / 3; // 3 columns with 1px gaps

const COLORS = {
  primary: '#0095f6',
  border: '#dbdbdb',
  text: '#262626',
  textSecondary: '#8e8e8e',
  background: '#fff',
};

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const BookmarksScreen = () => {
  const navigation = useNavigation<NavigationProp>();
  const [selectedType, setSelectedType] = useState<'post' | 'reel'>('post');

  const { data, fetchNextPage, hasNextPage, isFetchingNextPage, isLoading, refetch } =
    useBookmarks({ limit: 30, type: selectedType });

  const deleteBookmarkMutation = useDeleteBookmark();

  const bookmarks = data?.pages.flatMap((page) => page.data) || [];

  const handleBookmarkPress = (bookmark: Bookmark) => {
    if (bookmark.type === 'post' && bookmark.post) {
      navigation.navigate('PostDetail', { postId: bookmark.post.postId });
    } else if (bookmark.type === 'reel' && bookmark.reel) {
      // Navigate to reel detail or reels feed
      // navigation.navigate('Reels');
    }
  };

  const handleDeleteBookmark = async (bookmarkId: string) => {
    try {
      await deleteBookmarkMutation.mutateAsync(bookmarkId);
    } catch (error) {
      console.error('Error deleting bookmark:', error);
    }
  };

  const renderBookmark = ({ item }: { item: Bookmark }) => {
    const content = item.type === 'post' ? item.post : item.reel;
    if (!content) return null;

    const imageUrl = item.type === 'post'
      ? item.post?.imageUrls?.[0]
      : item.reel?.thumbnailUrl || item.reel?.videoUrl;

    return (
      <TouchableOpacity
        style={styles.bookmarkItem}
        onPress={() => handleBookmarkPress(item)}
        onLongPress={() => handleDeleteBookmark(item.bookmarkId)}
      >
        {imageUrl ? (
          <Image source={{ uri: imageUrl }} style={styles.thumbnail} />
        ) : (
          <View style={[styles.thumbnail, styles.thumbnailPlaceholder]}>
            <Ionicons
              name={item.type === 'post' ? 'image' : 'play'}
              size={32}
              color={COLORS.textSecondary}
            />
          </View>
        )}

        {item.type === 'reel' && (
          <View style={styles.reelIndicator}>
            <Ionicons name="play" size={16} color="#fff" />
          </View>
        )}

        {item.type === 'post' && item.post && item.post.imageUrls && item.post.imageUrls.length > 1 && (
          <View style={styles.multipleIndicator}>
            <Ionicons name="copy" size={16} color="#fff" />
          </View>
        )}
      </TouchableOpacity>
    );
  };

  const renderEmpty = () => (
    <View style={styles.emptyContainer}>
      <Ionicons name="bookmark-outline" size={64} color={COLORS.textSecondary} />
      <Text style={styles.emptyTitle}>No bookmarks yet</Text>
      <Text style={styles.emptyText}>
        {selectedType === 'post'
          ? 'Save posts to view them later'
          : 'Save reels to view them later'}
      </Text>
    </View>
  );

  const renderFooter = () => {
    if (!isFetchingNextPage) return null;
    return (
      <View style={styles.footer}>
        <ActivityIndicator size="small" color={COLORS.primary} />
      </View>
    );
  };

  const handleEndReached = () => {
    if (hasNextPage && !isFetchingNextPage) {
      fetchNextPage();
    }
  };

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={COLORS.primary} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
          <Ionicons name="arrow-back" size={24} color={COLORS.text} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Bookmarks</Text>
        <View style={styles.headerRight} />
      </View>

      {/* Tabs */}
      <View style={styles.tabs}>
        <TouchableOpacity
          style={[styles.tab, selectedType === 'post' && styles.activeTab]}
          onPress={() => setSelectedType('post')}
        >
          <Ionicons
            name="grid"
            size={20}
            color={selectedType === 'post' ? COLORS.text : COLORS.textSecondary}
          />
          <Text style={[styles.tabText, selectedType === 'post' && styles.activeTabText]}>
            Posts
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.tab, selectedType === 'reel' && styles.activeTab]}
          onPress={() => setSelectedType('reel')}
        >
          <Ionicons
            name="play-circle"
            size={20}
            color={selectedType === 'reel' ? COLORS.text : COLORS.textSecondary}
          />
          <Text style={[styles.tabText, selectedType === 'reel' && styles.activeTabText]}>
            Reels
          </Text>
        </TouchableOpacity>
      </View>

      {/* Grid */}
      <FlatList
        data={bookmarks}
        renderItem={renderBookmark}
        keyExtractor={(item) => item.bookmarkId}
        numColumns={3}
        contentContainerStyle={
          bookmarks.length === 0 ? styles.emptyList : styles.gridContainer
        }
        ListEmptyComponent={renderEmpty}
        ListFooterComponent={renderFooter}
        onEndReached={handleEndReached}
        onEndReachedThreshold={0.5}
        refreshing={false}
        onRefresh={refetch}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    paddingTop: 50,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  backButton: {
    padding: 4,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.text,
  },
  headerRight: {
    width: 32,
  },
  tabs: {
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  tab: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    gap: 6,
    borderBottomWidth: 2,
    borderBottomColor: 'transparent',
  },
  activeTab: {
    borderBottomColor: COLORS.text,
  },
  tabText: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.textSecondary,
  },
  activeTabText: {
    color: COLORS.text,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.background,
  },
  gridContainer: {
    paddingBottom: 16,
  },
  bookmarkItem: {
    width: ITEM_WIDTH,
    height: ITEM_WIDTH,
    margin: 0.5,
    position: 'relative',
  },
  thumbnail: {
    width: '100%',
    height: '100%',
  },
  thumbnailPlaceholder: {
    backgroundColor: '#f0f0f0',
    justifyContent: 'center',
    alignItems: 'center',
  },
  reelIndicator: {
    position: 'absolute',
    top: 8,
    right: 8,
  },
  multipleIndicator: {
    position: 'absolute',
    top: 8,
    right: 8,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
    paddingVertical: 80,
  },
  emptyList: {
    flexGrow: 1,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: COLORS.text,
    marginTop: 16,
    marginBottom: 8,
  },
  emptyText: {
    fontSize: 14,
    color: COLORS.textSecondary,
    textAlign: 'center',
    lineHeight: 20,
  },
  footer: {
    paddingVertical: 16,
    alignItems: 'center',
  },
});

export default BookmarksScreen;
