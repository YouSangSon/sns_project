import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  FlatList,
  StyleSheet,
  Dimensions,
  ActivityIndicator,
  Image,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Ionicons } from '@expo/vector-icons';
import { useReelsFeed, useToggleLikeReel, useViewReel } from '../../hooks/useReels';
import type { Reel } from '../../../../shared/types';
import type { RootStackParamList } from '../../navigation/types';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

const COLORS = {
  background: '#000',
  text: '#fff',
  textSecondary: '#bbb',
  overlay: 'rgba(0, 0, 0, 0.3)',
  like: '#ff3b5c',
};

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const ReelsScreen = () => {
  const navigation = useNavigation<NavigationProp>();
  const flatListRef = useRef<FlatList>(null);
  const [currentIndex, setCurrentIndex] = useState(0);

  const { data, fetchNextPage, hasNextPage, isFetchingNextPage, isLoading } =
    useReelsFeed({ limit: 10 });

  const { toggleLike } = useToggleLikeReel();
  const viewReelMutation = useViewReel();

  const reels = data?.pages.flatMap((page) => page.data) || [];

  // Mark reel as viewed when displayed
  const handleViewableItemsChanged = useRef(({ viewableItems }: any) => {
    if (viewableItems.length > 0) {
      const index = viewableItems[0].index;
      setCurrentIndex(index);

      const reelId = viewableItems[0].item.reelId;
      viewReelMutation.mutate(reelId);
    }
  }).current;

  const handleLike = async (reel: Reel) => {
    // For simplicity, we'll assume the reel is not liked
    // In a real app, you would track the like status per user
    await toggleLike(reel.reelId, false);
  };

  const renderReel = ({ item: reel }: { item: Reel }) => (
    <View style={styles.reelContainer}>
      {/* Video placeholder - In production, use Video component from expo-av */}
      {reel.thumbnailUrl ? (
        <Image
          source={{ uri: reel.thumbnailUrl }}
          style={styles.video}
          resizeMode="cover"
        />
      ) : (
        <View style={[styles.video, styles.videoPlaceholder]}>
          <Ionicons name="play-circle" size={80} color={COLORS.text} />
          <Text style={styles.placeholderText}>Video Player</Text>
        </View>
      )}

      {/* Dark overlay */}
      <View style={styles.overlay} />

      {/* Top bar */}
      <View style={styles.topBar}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Ionicons name="arrow-back" size={28} color={COLORS.text} />
        </TouchableOpacity>
        <Text style={styles.title}>Reels</Text>
        <TouchableOpacity>
          <Ionicons name="camera-outline" size={28} color={COLORS.text} />
        </TouchableOpacity>
      </View>

      {/* Side actions */}
      <View style={styles.sideActions}>
        {/* User profile */}
        <TouchableOpacity style={styles.actionButton}>
          {reel.userPhotoUrl ? (
            <Image
              source={{ uri: reel.userPhotoUrl }}
              style={styles.avatar}
            />
          ) : (
            <View style={[styles.avatar, styles.avatarPlaceholder]}>
              <Ionicons name="person" size={20} color={COLORS.text} />
            </View>
          )}
        </TouchableOpacity>

        {/* Like */}
        <TouchableOpacity
          style={styles.actionButton}
          onPress={() => handleLike(reel)}
        >
          <Ionicons name="heart" size={32} color={COLORS.like} />
          <Text style={styles.actionText}>{reel.likes}</Text>
        </TouchableOpacity>

        {/* Comments */}
        <TouchableOpacity style={styles.actionButton}>
          <Ionicons name="chatbubble" size={28} color={COLORS.text} />
          <Text style={styles.actionText}>{reel.comments}</Text>
        </TouchableOpacity>

        {/* Share */}
        <TouchableOpacity style={styles.actionButton}>
          <Ionicons name="paper-plane" size={28} color={COLORS.text} />
          <Text style={styles.actionText}>{reel.shares}</Text>
        </TouchableOpacity>

        {/* More */}
        <TouchableOpacity style={styles.actionButton}>
          <Ionicons name="ellipsis-vertical" size={28} color={COLORS.text} />
        </TouchableOpacity>
      </View>

      {/* Bottom info */}
      <View style={styles.bottomInfo}>
        <TouchableOpacity style={styles.userInfo}>
          <Text style={styles.username}>@{reel.username}</Text>
          <TouchableOpacity style={styles.followButton}>
            <Text style={styles.followText}>Follow</Text>
          </TouchableOpacity>
        </TouchableOpacity>

        {reel.caption && (
          <Text style={styles.caption} numberOfLines={2}>
            {reel.caption}
          </Text>
        )}

        {reel.audioName && (
          <View style={styles.audioInfo}>
            <Ionicons name="musical-notes" size={16} color={COLORS.text} />
            <Text style={styles.audioText} numberOfLines={1}>
              {reel.audioName}
            </Text>
          </View>
        )}

        <Text style={styles.views}>{reel.views} views</Text>
      </View>
    </View>
  );

  const renderFooter = () => {
    if (!isFetchingNextPage) return null;
    return (
      <View style={styles.footer}>
        <ActivityIndicator size="large" color={COLORS.text} />
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
        <ActivityIndicator size="large" color={COLORS.text} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        ref={flatListRef}
        data={reels}
        renderItem={renderReel}
        keyExtractor={(item) => item.reelId}
        pagingEnabled
        showsVerticalScrollIndicator={false}
        onEndReached={handleEndReached}
        onEndReachedThreshold={0.5}
        ListFooterComponent={renderFooter}
        onViewableItemsChanged={handleViewableItemsChanged}
        viewabilityConfig={{
          itemVisiblePercentThreshold: 80,
        }}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.background,
  },
  reelContainer: {
    width: SCREEN_WIDTH,
    height: SCREEN_HEIGHT,
  },
  video: {
    width: SCREEN_WIDTH,
    height: SCREEN_HEIGHT,
  },
  videoPlaceholder: {
    backgroundColor: '#1a1a1a',
    justifyContent: 'center',
    alignItems: 'center',
  },
  placeholderText: {
    color: COLORS.text,
    fontSize: 16,
    marginTop: 16,
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: COLORS.overlay,
  },
  topBar: {
    position: 'absolute',
    top: 50,
    left: 16,
    right: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    zIndex: 10,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.text,
  },
  sideActions: {
    position: 'absolute',
    right: 16,
    bottom: 120,
    gap: 24,
    zIndex: 10,
  },
  actionButton: {
    alignItems: 'center',
  },
  actionText: {
    color: COLORS.text,
    fontSize: 12,
    marginTop: 4,
    fontWeight: '600',
  },
  avatar: {
    width: 48,
    height: 48,
    borderRadius: 24,
    borderWidth: 2,
    borderColor: COLORS.text,
  },
  avatarPlaceholder: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  bottomInfo: {
    position: 'absolute',
    left: 16,
    right: 80,
    bottom: 40,
    zIndex: 10,
  },
  userInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  username: {
    fontSize: 15,
    fontWeight: 'bold',
    color: COLORS.text,
    marginRight: 12,
  },
  followButton: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderWidth: 1,
    borderColor: COLORS.text,
    borderRadius: 4,
  },
  followText: {
    color: COLORS.text,
    fontSize: 13,
    fontWeight: '600',
  },
  caption: {
    fontSize: 14,
    color: COLORS.text,
    lineHeight: 20,
    marginBottom: 8,
  },
  audioInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  audioText: {
    fontSize: 13,
    color: COLORS.text,
    marginLeft: 6,
    flex: 1,
  },
  views: {
    fontSize: 12,
    color: COLORS.textSecondary,
  },
  footer: {
    paddingVertical: 40,
    alignItems: 'center',
  },
});

export default ReelsScreen;
