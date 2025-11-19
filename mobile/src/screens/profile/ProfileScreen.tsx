import React, { useState } from 'react';
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  FlatList,
  StyleSheet,
  SafeAreaView,
  ActivityIndicator,
  Dimensions,
  RefreshControl,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '../../stores/authStore';
import { useUserProfile, useUserPosts, useFollowUser, useUnfollowUser } from '../../hooks/useProfile';
import { COLORS } from '../../constants';
import type { Post } from '../../../../shared/types';

const { width } = Dimensions.get('window');
const GRID_ITEM_SIZE = width / 3;

export const ProfileScreen = () => {
  const { user: currentUser } = useAuthStore();
  const [isFollowing, setIsFollowing] = useState(false);

  // For now, show the current user's profile
  // Later, we can add navigation params to show other users' profiles
  const userId = currentUser?.uid || '';

  const {
    data: profileData,
    isLoading: isProfileLoading,
    refetch: refetchProfile,
  } = useUserProfile(userId);

  const {
    data: postsData,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading: isPostsLoading,
    refetch: refetchPosts,
  } = useUserPosts(userId, { limit: 12 });

  const followMutation = useFollowUser();
  const unfollowMutation = useUnfollowUser();

  const posts = postsData?.pages.flatMap((page) => page.data) || [];
  const isOwnProfile = currentUser?.uid === userId;
  const isRefreshing = false;

  const handleRefresh = async () => {
    await Promise.all([refetchProfile(), refetchPosts()]);
  };

  const handleFollowToggle = async () => {
    if (!userId) return;

    try {
      if (isFollowing) {
        await unfollowMutation.mutateAsync(userId);
        setIsFollowing(false);
      } else {
        await followMutation.mutateAsync(userId);
        setIsFollowing(true);
      }
    } catch (error) {
      console.error('Error toggling follow:', error);
    }
  };

  const renderPostItem = ({ item }: { item: Post }) => (
    <TouchableOpacity
      style={styles.gridItem}
      onPress={() => console.log('Post clicked:', item.postId)}
    >
      <Image
        source={{ uri: item.imageUrls[0] }}
        style={styles.gridImage}
      />
      {item.imageUrls.length > 1 && (
        <View style={styles.multipleImagesIndicator}>
          <Ionicons name="copy-outline" size={16} color="#fff" />
        </View>
      )}
    </TouchableOpacity>
  );

  const renderHeader = () => (
    <View style={styles.header}>
      {/* Profile Info */}
      <View style={styles.profileInfo}>
        {/* Avatar */}
        <Image
          source={{
            uri: profileData?.photoUrl || 'https://via.placeholder.com/100',
          }}
          style={styles.avatar}
        />

        {/* Stats */}
        <View style={styles.stats}>
          <View style={styles.stat}>
            <Text style={styles.statNumber}>{profileData?.posts || 0}</Text>
            <Text style={styles.statLabel}>Posts</Text>
          </View>
          <View style={styles.stat}>
            <Text style={styles.statNumber}>
              {profileData?.followers || 0}
            </Text>
            <Text style={styles.statLabel}>Followers</Text>
          </View>
          <View style={styles.stat}>
            <Text style={styles.statNumber}>
              {profileData?.following || 0}
            </Text>
            <Text style={styles.statLabel}>Following</Text>
          </View>
        </View>
      </View>

      {/* Name and Bio */}
      <View style={styles.bio}>
        <Text style={styles.displayName}>{profileData?.displayName}</Text>
        {profileData?.bio && <Text style={styles.bioText}>{profileData.bio}</Text>}
      </View>

      {/* Action Buttons */}
      <View style={styles.actionButtons}>
        {isOwnProfile ? (
          <TouchableOpacity
            style={styles.editButton}
            onPress={() => console.log('Edit profile')}
          >
            <Text style={styles.editButtonText}>Edit Profile</Text>
          </TouchableOpacity>
        ) : (
          <>
            <TouchableOpacity
              style={[
                styles.followButton,
                isFollowing && styles.followingButton,
              ]}
              onPress={handleFollowToggle}
              disabled={followMutation.isPending || unfollowMutation.isPending}
            >
              {followMutation.isPending || unfollowMutation.isPending ? (
                <ActivityIndicator color={isFollowing ? '#000' : '#fff'} size="small" />
              ) : (
                <Text
                  style={[
                    styles.followButtonText,
                    isFollowing && styles.followingButtonText,
                  ]}
                >
                  {isFollowing ? 'Following' : 'Follow'}
                </Text>
              )}
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.messageButton}
              onPress={() => console.log('Message')}
            >
              <Text style={styles.messageButtonText}>Message</Text>
            </TouchableOpacity>
          </>
        )}
      </View>

      {/* Tab Bar */}
      <View style={styles.tabBar}>
        <TouchableOpacity style={styles.tab}>
          <Ionicons name="grid-outline" size={24} color={COLORS.text} />
        </TouchableOpacity>
        <TouchableOpacity style={styles.tab}>
          <Ionicons name="videocam-outline" size={24} color={COLORS.textSecondary} />
        </TouchableOpacity>
        <TouchableOpacity style={styles.tab}>
          <Ionicons name="person-outline" size={24} color={COLORS.textSecondary} />
        </TouchableOpacity>
      </View>
    </View>
  );

  if (isProfileLoading || isPostsLoading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={COLORS.primary} />
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.topBar}>
        <TouchableOpacity onPress={() => console.log('Settings')}>
          <Ionicons name="settings-outline" size={24} color={COLORS.text} />
        </TouchableOpacity>
        <Text style={styles.username}>@{profileData?.username}</Text>
        <TouchableOpacity onPress={() => console.log('Menu')}>
          <Ionicons name="menu-outline" size={24} color={COLORS.text} />
        </TouchableOpacity>
      </View>

      {/* Posts Grid */}
      <FlatList
        data={posts}
        renderItem={renderPostItem}
        keyExtractor={(item) => item.postId}
        numColumns={3}
        ListHeaderComponent={renderHeader}
        onEndReached={() => {
          if (hasNextPage && !isFetchingNextPage) {
            fetchNextPage();
          }
        }}
        onEndReachedThreshold={0.5}
        refreshControl={
          <RefreshControl refreshing={isRefreshing} onRefresh={handleRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Ionicons name="camera-outline" size={64} color={COLORS.textSecondary} />
            <Text style={styles.emptyText}>No posts yet</Text>
          </View>
        }
        ListFooterComponent={
          isFetchingNextPage ? (
            <View style={styles.footerLoader}>
              <ActivityIndicator color={COLORS.primary} />
            </View>
          ) : null
        }
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  topBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  username: {
    fontSize: 18,
    fontWeight: '600',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    paddingBottom: 8,
  },
  profileInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 12,
  },
  avatar: {
    width: 88,
    height: 88,
    borderRadius: 44,
    marginRight: 24,
  },
  stats: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  stat: {
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 18,
    fontWeight: '600',
  },
  statLabel: {
    fontSize: 13,
    color: COLORS.textSecondary,
    marginTop: 2,
  },
  bio: {
    paddingHorizontal: 16,
    paddingBottom: 12,
  },
  displayName: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
  },
  bioText: {
    fontSize: 14,
    lineHeight: 20,
  },
  actionButtons: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    paddingBottom: 16,
    gap: 8,
  },
  editButton: {
    flex: 1,
    backgroundColor: COLORS.border,
    paddingVertical: 8,
    borderRadius: 8,
    alignItems: 'center',
  },
  editButtonText: {
    fontSize: 14,
    fontWeight: '600',
  },
  followButton: {
    flex: 1,
    backgroundColor: COLORS.primary,
    paddingVertical: 8,
    borderRadius: 8,
    alignItems: 'center',
  },
  followButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#fff',
  },
  followingButton: {
    backgroundColor: COLORS.border,
  },
  followingButtonText: {
    color: COLORS.text,
  },
  messageButton: {
    flex: 1,
    backgroundColor: COLORS.border,
    paddingVertical: 8,
    borderRadius: 8,
    alignItems: 'center',
  },
  messageButtonText: {
    fontSize: 14,
    fontWeight: '600',
  },
  tabBar: {
    flexDirection: 'row',
    borderTopWidth: 1,
    borderTopColor: COLORS.border,
  },
  tab: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'transparent',
  },
  gridItem: {
    width: GRID_ITEM_SIZE,
    height: GRID_ITEM_SIZE,
    padding: 1,
  },
  gridImage: {
    width: '100%',
    height: '100%',
  },
  multipleImagesIndicator: {
    position: 'absolute',
    top: 8,
    right: 8,
  },
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: 48,
  },
  emptyText: {
    fontSize: 16,
    color: COLORS.textSecondary,
    marginTop: 12,
  },
  footerLoader: {
    paddingVertical: 20,
    alignItems: 'center',
  },
});

export default ProfileScreen;
