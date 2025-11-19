import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  FlatList,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  ActivityIndicator,
  SafeAreaView,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRoute, useNavigation, type RouteProp } from '@react-navigation/native';
import { PostCard } from '../../components/posts';
import { CommentItem } from '../../components/comments';
import { usePost } from '../../hooks/usePosts';
import { usePostComments, useCreateComment } from '../../hooks/useComments';
import { COLORS } from '../../constants';
import type { Comment } from '../../../../shared/types';

type PostDetailRouteProp = RouteProp<{ PostDetail: { postId: string } }, 'PostDetail'>;

const PostDetailScreen = () => {
  const route = useRoute<PostDetailRouteProp>();
  const navigation = useNavigation();
  const { postId } = route.params;

  const [commentText, setCommentText] = useState('');
  const [replyingTo, setReplyingTo] = useState<Comment | null>(null);
  const inputRef = useRef<TextInput>(null);

  const { data: post, isLoading: isPostLoading } = usePost(postId);
  const {
    data: commentsData,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading: isCommentsLoading,
  } = usePostComments(postId, { limit: 20 });

  const createCommentMutation = useCreateComment();

  const comments = commentsData?.pages.flatMap((page) => page.data) || [];

  const handleSendComment = async () => {
    if (!commentText.trim()) return;

    const text = commentText.trim();
    setCommentText('');
    setReplyingTo(null);

    try {
      await createCommentMutation.mutateAsync({
        postId,
        text,
        parentCommentId: replyingTo?.commentId,
      });
    } catch (error) {
      console.error('Error creating comment:', error);
      setCommentText(text); // Restore text on error
    }
  };

  const handleReply = (comment: Comment) => {
    setReplyingTo(comment);
    setCommentText(`@${comment.username} `);
    inputRef.current?.focus();
  };

  const handleCancelReply = () => {
    setReplyingTo(null);
    setCommentText('');
  };

  const handleViewReplies = (comment: Comment) => {
    // Navigate to replies screen or expand inline
    console.log('View replies for:', comment.commentId);
  };

  const renderHeader = () => {
    if (!post) return null;

    return (
      <View>
        <PostCard
          post={post}
          onComment={() => inputRef.current?.focus()}
          onShare={() => console.log('Share')}
          onUserPress={() => console.log('User')}
        />
        <View style={styles.commentsHeader}>
          <Text style={styles.commentsTitle}>Comments</Text>
        </View>
      </View>
    );
  };

  const renderFooter = () => {
    if (!isFetchingNextPage) return null;

    return (
      <View style={styles.footer}>
        <ActivityIndicator size="small" color={COLORS.primary} />
      </View>
    );
  };

  const renderEmpty = () => {
    if (isCommentsLoading) {
      return (
        <View style={styles.centered}>
          <ActivityIndicator size="small" color={COLORS.primary} />
        </View>
      );
    }

    return (
      <View style={styles.centered}>
        <Ionicons name="chatbubble-outline" size={48} color={COLORS.textSecondary} />
        <Text style={styles.emptyText}>No comments yet</Text>
        <Text style={styles.emptySubtext}>Be the first to comment!</Text>
      </View>
    );
  };

  if (isPostLoading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centered}>
          <ActivityIndicator size="large" color={COLORS.primary} />
        </View>
      </SafeAreaView>
    );
  }

  if (!post) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centered}>
          <Text style={styles.errorText}>Post not found</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container} edges={['bottom']}>
      <KeyboardAvoidingView
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 88 : 0}
      >
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
            <Ionicons name="arrow-back" size={24} color={COLORS.text} />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Post</Text>
          <View style={styles.headerRight} />
        </View>

        {/* Comments List */}
        <FlatList
          data={comments}
          keyExtractor={(item) => item.commentId}
          renderItem={({ item }) => (
            <CommentItem
              comment={item}
              postId={postId}
              onReply={handleReply}
              onViewReplies={handleViewReplies}
            />
          )}
          ListHeaderComponent={renderHeader}
          ListFooterComponent={renderFooter}
          ListEmptyComponent={renderEmpty}
          onEndReached={() => {
            if (hasNextPage && !isFetchingNextPage) {
              fetchNextPage();
            }
          }}
          onEndReachedThreshold={0.5}
          showsVerticalScrollIndicator={false}
        />

        {/* Comment Input */}
        <View style={styles.inputContainer}>
          {replyingTo && (
            <View style={styles.replyingBanner}>
              <Text style={styles.replyingText}>
                Replying to @{replyingTo.username}
              </Text>
              <TouchableOpacity onPress={handleCancelReply}>
                <Ionicons name="close" size={20} color={COLORS.textSecondary} />
              </TouchableOpacity>
            </View>
          )}

          <View style={styles.inputRow}>
            <TextInput
              ref={inputRef}
              style={styles.input}
              placeholder="Add a comment..."
              value={commentText}
              onChangeText={setCommentText}
              multiline
              maxLength={500}
            />

            <TouchableOpacity
              onPress={handleSendComment}
              disabled={!commentText.trim() || createCommentMutation.isPending}
              style={styles.sendButton}
            >
              {createCommentMutation.isPending ? (
                <ActivityIndicator size="small" color={COLORS.primary} />
              ) : (
                <Ionicons
                  name="send"
                  size={20}
                  color={commentText.trim() ? COLORS.primary : COLORS.textSecondary}
                />
              )}
            </TouchableOpacity>
          </View>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  backButton: {
    padding: 4,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  headerRight: {
    width: 32,
  },
  commentsHeader: {
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderTopWidth: 1,
    borderTopColor: COLORS.border,
  },
  commentsTitle: {
    fontSize: 16,
    fontWeight: '600',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 40,
  },
  emptyText: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.text,
    marginTop: 12,
  },
  emptySubtext: {
    fontSize: 14,
    color: COLORS.textSecondary,
    marginTop: 4,
  },
  errorText: {
    fontSize: 16,
    color: COLORS.error || '#ff3b30',
  },
  footer: {
    paddingVertical: 20,
    alignItems: 'center',
  },
  inputContainer: {
    borderTopWidth: 1,
    borderTopColor: COLORS.border,
    backgroundColor: '#fff',
  },
  replyingBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: COLORS.backgroundGray,
  },
  replyingText: {
    fontSize: 13,
    color: COLORS.textSecondary,
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    paddingHorizontal: 16,
    paddingVertical: 8,
    gap: 8,
  },
  input: {
    flex: 1,
    maxHeight: 100,
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: COLORS.backgroundGray,
    borderRadius: 20,
    fontSize: 15,
  },
  sendButton: {
    padding: 8,
  },
});

export default PostDetailScreen;
