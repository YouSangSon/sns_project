import React, { useState } from 'react';
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import type { Comment } from '../../../../shared/types';
import { COLORS } from '../../constants';
import { useLikeComment, useUnlikeComment, useDeleteComment } from '../../hooks/useComments';
import { useAuthStore } from '../../stores/authStore';

interface CommentItemProps {
  comment: Comment;
  postId: string;
  onReply?: (comment: Comment) => void;
  onViewReplies?: (comment: Comment) => void;
}

export const CommentItem: React.FC<CommentItemProps> = ({
  comment,
  postId,
  onReply,
  onViewReplies,
}) => {
  const { user } = useAuthStore();
  const [isLiked, setIsLiked] = useState(false);
  const [likesCount, setLikesCount] = useState(comment.likes);

  const likeMutation = useLikeComment();
  const unlikeMutation = useUnlikeComment();
  const deleteMutation = useDeleteComment();

  const isOwnComment = user?.uid === comment.userId;

  const handleLike = async () => {
    const wasLiked = isLiked;
    const previousCount = likesCount;

    // Optimistic update
    setIsLiked(!wasLiked);
    setLikesCount(wasLiked ? likesCount - 1 : likesCount + 1);

    try {
      if (wasLiked) {
        await unlikeMutation.mutateAsync(comment.commentId);
      } else {
        await likeMutation.mutateAsync(comment.commentId);
      }
    } catch (error) {
      // Revert on error
      setIsLiked(wasLiked);
      setLikesCount(previousCount);
      console.error('Error toggling like:', error);
    }
  };

  const handleDelete = () => {
    Alert.alert(
      'Delete Comment',
      'Are you sure you want to delete this comment?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await deleteMutation.mutateAsync({
                commentId: comment.commentId,
                postId,
              });
            } catch (error) {
              console.error('Error deleting comment:', error);
              Alert.alert('Error', 'Failed to delete comment');
            }
          },
        },
      ]
    );
  };

  const formatTimestamp = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - new Date(date).getTime();
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);
    const weeks = Math.floor(days / 7);

    if (weeks > 0) return `${weeks}w`;
    if (days > 0) return `${days}d`;
    if (hours > 0) return `${hours}h`;
    if (minutes > 0) return `${minutes}m`;
    return 'now';
  };

  return (
    <View style={styles.container}>
      <Image
        source={{ uri: comment.userPhotoUrl || 'https://via.placeholder.com/32' }}
        style={styles.avatar}
      />

      <View style={styles.content}>
        <View style={styles.bubble}>
          <Text style={styles.username}>{comment.username}</Text>
          <Text style={styles.text}>{comment.text}</Text>
        </View>

        <View style={styles.actions}>
          <Text style={styles.timestamp}>{formatTimestamp(comment.createdAt)}</Text>

          {likesCount > 0 && (
            <Text style={styles.likesText}>
              {likesCount} {likesCount === 1 ? 'like' : 'likes'}
            </Text>
          )}

          <TouchableOpacity onPress={() => onReply?.(comment)}>
            <Text style={styles.actionText}>Reply</Text>
          </TouchableOpacity>

          {isOwnComment && (
            <TouchableOpacity onPress={handleDelete}>
              <Text style={[styles.actionText, styles.deleteText]}>Delete</Text>
            </TouchableOpacity>
          )}
        </View>

        {comment.repliesCount > 0 && (
          <TouchableOpacity
            style={styles.viewReplies}
            onPress={() => onViewReplies?.(comment)}
          >
            <View style={styles.replyLine} />
            <Text style={styles.viewRepliesText}>
              View {comment.repliesCount} {comment.repliesCount === 1 ? 'reply' : 'replies'}
            </Text>
          </TouchableOpacity>
        )}
      </View>

      <TouchableOpacity onPress={handleLike} style={styles.likeButton}>
        <Ionicons
          name={isLiked ? 'heart' : 'heart-outline'}
          size={12}
          color={isLiked ? COLORS.like : COLORS.textSecondary}
        />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    paddingVertical: 8,
    paddingHorizontal: 16,
  },
  avatar: {
    width: 32,
    height: 32,
    borderRadius: 16,
    marginRight: 12,
  },
  content: {
    flex: 1,
  },
  bubble: {
    backgroundColor: COLORS.backgroundGray,
    borderRadius: 16,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  username: {
    fontSize: 13,
    fontWeight: '600',
    marginBottom: 2,
  },
  text: {
    fontSize: 14,
    lineHeight: 18,
  },
  actions: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
    marginLeft: 12,
    gap: 12,
  },
  timestamp: {
    fontSize: 12,
    color: COLORS.textSecondary,
  },
  likesText: {
    fontSize: 12,
    fontWeight: '600',
    color: COLORS.text,
  },
  actionText: {
    fontSize: 12,
    fontWeight: '600',
    color: COLORS.textSecondary,
  },
  deleteText: {
    color: COLORS.error || '#ff3b30',
  },
  viewReplies: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
    marginLeft: 12,
  },
  replyLine: {
    width: 24,
    height: 1,
    backgroundColor: COLORS.border,
    marginRight: 8,
  },
  viewRepliesText: {
    fontSize: 13,
    fontWeight: '600',
    color: COLORS.textSecondary,
  },
  likeButton: {
    padding: 4,
  },
});
