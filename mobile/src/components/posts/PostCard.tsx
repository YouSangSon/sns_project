import React, { useState } from 'react';
import {
  View,
  Text,
  Image,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import type { Post } from '../../../shared/types';
import { COLORS } from '../constants';
import { useLikePost, useUnlikePost } from '../../hooks/usePosts';

interface PostCardProps {
  post: Post;
  onComment?: () => void;
  onShare?: () => void;
  onUserPress?: () => void;
}

const { width } = Dimensions.get('window');

export const PostCard: React.FC<PostCardProps> = ({
  post,
  onComment,
  onShare,
  onUserPress,
}) => {
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [isLiked, setIsLiked] = useState(false);
  const [likesCount, setLikesCount] = useState(post.likes);

  const likeMutation = useLikePost();
  const unlikeMutation = useUnlikePost();

  const handleLike = async () => {
    const wasLiked = isLiked;
    const previousCount = likesCount;

    // Optimistic update
    setIsLiked(!wasLiked);
    setLikesCount(wasLiked ? likesCount - 1 : likesCount + 1);

    try {
      if (wasLiked) {
        await unlikeMutation.mutateAsync(post.postId);
      } else {
        await likeMutation.mutateAsync(post.postId);
      }
    } catch (error) {
      // Revert on error
      setIsLiked(wasLiked);
      setLikesCount(previousCount);
      console.error('Error toggling like:', error);
    }
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <TouchableOpacity
        style={styles.header}
        onPress={onUserPress}
        activeOpacity={0.7}
      >
        <Image
          source={{
            uri: post.userPhotoUrl || 'https://via.placeholder.com/40',
          }}
          style={styles.avatar}
        />
        <View style={styles.userInfo}>
          <Text style={styles.username}>{post.username}</Text>
          {post.location && (
            <Text style={styles.location}>{post.location}</Text>
          )}
        </View>
        <TouchableOpacity style={styles.moreButton}>
          <Ionicons name="ellipsis-horizontal" size={20} color={COLORS.text} />
        </TouchableOpacity>
      </TouchableOpacity>

      {/* Image(s) */}
      <View style={styles.imageContainer}>
        <Image
          source={{ uri: post.imageUrls[currentImageIndex] }}
          style={styles.image}
          resizeMode="cover"
        />

        {/* Image Indicator */}
        {post.imageUrls.length > 1 && (
          <View style={styles.indicator}>
            {post.imageUrls.map((_, index) => (
              <View
                key={index}
                style={[
                  styles.dot,
                  index === currentImageIndex && styles.activeDot,
                ]}
              />
            ))}
          </View>
        )}
      </View>

      {/* Actions */}
      <View style={styles.actions}>
        <View style={styles.leftActions}>
          <TouchableOpacity onPress={handleLike} style={styles.actionButton}>
            <Ionicons
              name={isLiked ? 'heart' : 'heart-outline'}
              size={28}
              color={isLiked ? COLORS.like : COLORS.text}
            />
          </TouchableOpacity>
          <TouchableOpacity onPress={onComment} style={styles.actionButton}>
            <Ionicons name="chatbubble-outline" size={26} color={COLORS.text} />
          </TouchableOpacity>
          <TouchableOpacity onPress={onShare} style={styles.actionButton}>
            <Ionicons name="paper-plane-outline" size={26} color={COLORS.text} />
          </TouchableOpacity>
        </View>

        <TouchableOpacity style={styles.actionButton}>
          <Ionicons name="bookmark-outline" size={26} color={COLORS.text} />
        </TouchableOpacity>
      </View>

      {/* Likes Count */}
      <TouchableOpacity style={styles.likesContainer}>
        <Text style={styles.likes}>
          {likesCount.toLocaleString()} likes
        </Text>
      </TouchableOpacity>

      {/* Caption */}
      {post.caption && (
        <View style={styles.captionContainer}>
          <Text style={styles.caption}>
            <Text style={styles.username}>{post.username}</Text>{' '}
            {post.caption}
          </Text>
        </View>
      )}

      {/* Comments Preview */}
      {post.comments > 0 && (
        <TouchableOpacity onPress={onComment} style={styles.commentsButton}>
          <Text style={styles.commentsText}>
            View all {post.comments} comments
          </Text>
        </TouchableOpacity>
      )}

      {/* Timestamp */}
      <Text style={styles.timestamp}>
        {formatTimestamp(post.createdAt)}
      </Text>
    </View>
  );
};

const formatTimestamp = (date: Date) => {
  const now = new Date();
  const diff = now.getTime() - new Date(date).getTime();
  const seconds = Math.floor(diff / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (days > 7) {
    return new Date(date).toLocaleDateString();
  } else if (days > 0) {
    return `${days} day${days > 1 ? 's' : ''} ago`;
  } else if (hours > 0) {
    return `${hours} hour${hours > 1 ? 's' : ''} ago`;
  } else if (minutes > 0) {
    return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
  } else {
    return 'Just now';
  }
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
    backgroundColor: '#fff',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: COLORS.backgroundGray,
  },
  userInfo: {
    flex: 1,
    marginLeft: 12,
  },
  username: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.text,
  },
  location: {
    fontSize: 12,
    color: COLORS.textSecondary,
    marginTop: 2,
  },
  moreButton: {
    padding: 4,
  },
  imageContainer: {
    width: width,
    height: width,
    backgroundColor: COLORS.backgroundGray,
  },
  image: {
    width: '100%',
    height: '100%',
  },
  indicator: {
    position: 'absolute',
    bottom: 12,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  dot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: 'rgba(255, 255, 255, 0.5)',
    marginHorizontal: 3,
  },
  activeDot: {
    backgroundColor: '#fff',
  },
  actions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  leftActions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  actionButton: {
    marginRight: 16,
  },
  likesContainer: {
    paddingHorizontal: 12,
    paddingVertical: 4,
  },
  likes: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.text,
  },
  captionContainer: {
    paddingHorizontal: 12,
    paddingVertical: 4,
  },
  caption: {
    fontSize: 14,
    color: COLORS.text,
    lineHeight: 18,
  },
  commentsButton: {
    paddingHorizontal: 12,
    paddingVertical: 4,
  },
  commentsText: {
    fontSize: 14,
    color: COLORS.textSecondary,
  },
  timestamp: {
    fontSize: 10,
    color: COLORS.textSecondary,
    paddingHorizontal: 12,
    paddingVertical: 4,
  },
});
