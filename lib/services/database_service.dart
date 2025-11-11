import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/story_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../core/constants/app_constants.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ============ USER OPERATIONS ============

  // Create user
  Future<void> createUser({
    required String uid,
    required String email,
    required String username,
    required String displayName,
    String photoUrl = '',
  }) async {
    try {
      final user = UserModel(
        uid: uid,
        email: email,
        username: username,
        displayName: displayName,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Check if user exists
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? photoUrl,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(AppConstants.usersPerPage)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // ============ POST OPERATIONS ============

  // Create post
  Future<String> createPost({
    required String userId,
    required String username,
    required String userPhotoUrl,
    required List<String> imageUrls,
    required String caption,
    String location = '',
    List<String> hashtags = const [],
  }) async {
    try {
      final postId = _uuid.v4();

      final post = PostModel(
        postId: postId,
        userId: userId,
        username: username,
        userPhotoUrl: userPhotoUrl,
        imageUrls: imageUrls,
        caption: caption,
        location: location,
        hashtags: hashtags,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .set(post.toMap());

      // Increment user's post count
      await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
        'posts': FieldValue.increment(1),
      });

      return postId;
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  // Get post by ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .get();

      if (doc.exists) {
        return PostModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting post: $e');
      return null;
    }
  }

  // Get user posts
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.postsPerPage)
          .get();

      return querySnapshot.docs
          .map((doc) => PostModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting user posts: $e');
      return [];
    }
  }

  // Get feed posts (posts from followed users)
  Future<List<PostModel>> getFeedPosts(String userId) async {
    try {
      // Get list of followed users
      final followingIds = await getFollowingIds(userId);

      // Include user's own posts
      followingIds.add(userId);

      if (followingIds.isEmpty) {
        return [];
      }

      // Get posts from followed users
      final querySnapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .where('userId', whereIn: followingIds.take(10).toList())
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.postsPerPage)
          .get();

      return querySnapshot.docs
          .map((doc) => PostModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting feed posts: $e');
      return [];
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      final post = await getPostById(postId);
      if (post != null) {
        await _firestore.collection(AppConstants.postsCollection).doc(postId).delete();

        // Decrement user's post count
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(post.userId)
            .update({
          'posts': FieldValue.increment(-1),
        });
      }
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  // ============ LIKE OPERATIONS ============

  // Like post
  Future<void> likePost(String postId, String userId) async {
    try {
      final likeId = '${postId}_$userId';

      await _firestore
          .collection(AppConstants.likesCollection)
          .doc(likeId)
          .set({
        'postId': postId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Increment likes count
      await _firestore.collection(AppConstants.postsCollection).doc(postId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error liking post: $e');
      rethrow;
    }
  }

  // Unlike post
  Future<void> unlikePost(String postId, String userId) async {
    try {
      final likeId = '${postId}_$userId';

      await _firestore
          .collection(AppConstants.likesCollection)
          .doc(likeId)
          .delete();

      // Decrement likes count
      await _firestore.collection(AppConstants.postsCollection).doc(postId).update({
        'likes': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unliking post: $e');
      rethrow;
    }
  }

  // Check if post is liked
  Future<bool> isPostLiked(String postId, String userId) async {
    try {
      final likeId = '${postId}_$userId';
      final doc = await _firestore
          .collection(AppConstants.likesCollection)
          .doc(likeId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ============ COMMENT OPERATIONS ============

  // Add comment
  Future<void> addComment({
    required String postId,
    required String userId,
    required String username,
    required String userPhotoUrl,
    required String text,
  }) async {
    try {
      final commentId = _uuid.v4();

      final comment = CommentModel(
        commentId: commentId,
        postId: postId,
        userId: userId,
        username: username,
        userPhotoUrl: userPhotoUrl,
        text: text,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.commentsCollection)
          .doc(commentId)
          .set(comment.toMap());

      // Increment comments count
      await _firestore.collection(AppConstants.postsCollection).doc(postId).update({
        'comments': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Get comments
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.commentsCollection)
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false)
          .limit(AppConstants.commentsPerPage)
          .get();

      return querySnapshot.docs
          .map((doc) => CommentModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  // ============ FOLLOW OPERATIONS ============

  // Follow user
  Future<void> followUser(String followerId, String followingId) async {
    try {
      final followId = '${followerId}_$followingId';

      await _firestore
          .collection(AppConstants.followsCollection)
          .doc(followId)
          .set({
        'followerId': followerId,
        'followingId': followingId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update follower and following counts
      await _firestore.collection(AppConstants.usersCollection).doc(followerId).update({
        'following': FieldValue.increment(1),
      });

      await _firestore.collection(AppConstants.usersCollection).doc(followingId).update({
        'followers': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error following user: $e');
      rethrow;
    }
  }

  // Unfollow user
  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      final followId = '${followerId}_$followingId';

      await _firestore
          .collection(AppConstants.followsCollection)
          .doc(followId)
          .delete();

      // Update follower and following counts
      await _firestore.collection(AppConstants.usersCollection).doc(followerId).update({
        'following': FieldValue.increment(-1),
      });

      await _firestore.collection(AppConstants.usersCollection).doc(followingId).update({
        'followers': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unfollowing user: $e');
      rethrow;
    }
  }

  // Check if following
  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final followId = '${followerId}_$followingId';
      final doc = await _firestore
          .collection(AppConstants.followsCollection)
          .doc(followId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get following IDs
  Future<List<String>> getFollowingIds(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.followsCollection)
          .where('followerId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['followingId'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get followers
  Future<List<UserModel>> getFollowers(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.followsCollection)
          .where('followingId', isEqualTo: userId)
          .get();

      List<UserModel> followers = [];
      for (var doc in querySnapshot.docs) {
        final followerId = doc.data()['followerId'] as String;
        final user = await getUserById(followerId);
        if (user != null) {
          followers.add(user);
        }
      }

      return followers;
    } catch (e) {
      return [];
    }
  }

  // Get following
  Future<List<UserModel>> getFollowing(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.followsCollection)
          .where('followerId', isEqualTo: userId)
          .get();

      List<UserModel> following = [];
      for (var doc in querySnapshot.docs) {
        final followingId = doc.data()['followingId'] as String;
        final user = await getUserById(followingId);
        if (user != null) {
          following.add(user);
        }
      }

      return following;
    } catch (e) {
      return [];
    }
  }

  // ============ STORY OPERATIONS ============

  // Create story
  Future<String> createStory({
    required String userId,
    required String username,
    required String userPhotoUrl,
    required String mediaUrl,
    required String mediaType,
  }) async {
    try {
      final storyId = _uuid.v4();
      final now = DateTime.now();
      final expiresAt = now.add(Duration(hours: AppConstants.storyDurationHours));

      final story = StoryModel(
        storyId: storyId,
        userId: userId,
        username: username,
        userPhotoUrl: userPhotoUrl,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        createdAt: now,
        expiresAt: expiresAt,
      );

      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .set(story.toMap());

      return storyId;
    } catch (e) {
      print('Error creating story: $e');
      rethrow;
    }
  }

  // Get stories from following users
  Future<List<Map<String, dynamic>>> getStoriesFromFollowing(String userId) async {
    try {
      final followingIds = await getFollowingIds(userId);
      followingIds.add(userId); // Include own stories

      if (followingIds.isEmpty) {
        return [];
      }

      final now = DateTime.now();

      // Get stories for each user
      List<Map<String, dynamic>> userStoriesMap = [];

      for (String followingId in followingIds) {
        final storiesSnapshot = await _firestore
            .collection(AppConstants.storiesCollection)
            .where('userId', isEqualTo: followingId)
            .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
            .orderBy('expiresAt')
            .orderBy('createdAt', descending: false)
            .get();

        if (storiesSnapshot.docs.isNotEmpty) {
          final stories = storiesSnapshot.docs
              .map((doc) => StoryModel.fromDocument(doc))
              .toList();

          final user = await getUserById(followingId);
          if (user != null) {
            userStoriesMap.add({
              'user': user,
              'stories': stories,
            });
          }
        }
      }

      return userStoriesMap;
    } catch (e) {
      print('Error getting stories: $e');
      return [];
    }
  }

  // Get user stories
  Future<List<StoryModel>> getUserStories(String userId) async {
    try {
      final now = DateTime.now();

      final querySnapshot = await _firestore
          .collection(AppConstants.storiesCollection)
          .where('userId', isEqualTo: userId)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => StoryModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting user stories: $e');
      return [];
    }
  }

  // Add story view
  Future<void> addStoryView(String storyId, String userId) async {
    try {
      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .update({
        'views': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error adding story view: $e');
      rethrow;
    }
  }

  // Delete story
  Future<void> deleteStory(String storyId) async {
    try {
      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .delete();
    } catch (e) {
      print('Error deleting story: $e');
      rethrow;
    }
  }

  // ============ MESSAGE OPERATIONS ============

  // Create or get conversation
  Future<String> createOrGetConversation(String user1Id, String user2Id) async {
    try {
      // Create consistent conversation ID
      final participants = [user1Id, user2Id]..sort();
      final conversationId = '${participants[0]}_${participants[1]}';

      final doc = await _firestore
          .collection(AppConstants.conversationsCollection)
          .doc(conversationId)
          .get();

      if (!doc.exists) {
        // Create new conversation
        await _firestore
            .collection(AppConstants.conversationsCollection)
            .doc(conversationId)
            .set({
          'conversationId': conversationId,
          'participants': participants,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': {user1Id: 0, user2Id: 0},
        });
      }

      return conversationId;
    } catch (e) {
      print('Error creating conversation: $e');
      rethrow;
    }
  }

  // Send message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    required String type,
    String? mediaUrl,
  }) async {
    try {
      final messageId = _uuid.v4();

      final message = MessageModel(
        messageId: messageId,
        conversationId: conversationId,
        senderId: senderId,
        text: text,
        mediaUrl: mediaUrl,
        type: type,
        createdAt: DateTime.now(),
      );

      // Add message
      await _firestore
          .collection(AppConstants.conversationsCollection)
          .doc(conversationId)
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .set(message.toMap());

      // Update conversation
      final conversationDoc = await _firestore
          .collection(AppConstants.conversationsCollection)
          .doc(conversationId)
          .get();

      final conversationData = conversationDoc.data()!;
      final participants = List<String>.from(conversationData['participants']);
      final otherUserId = participants.firstWhere((id) => id != senderId);

      await _firestore
          .collection(AppConstants.conversationsCollection)
          .doc(conversationId)
          .update({
        'lastMessage': type == 'text' ? text : '📷 Photo',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount.$otherUserId': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages stream
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _firestore
        .collection(AppConstants.conversationsCollection)
        .doc(conversationId)
        .collection(AppConstants.messagesCollection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromDocument(doc)).toList());
  }

  // Get user conversations
  Future<List<ConversationModel>> getUserConversations(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.conversationsCollection)
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ConversationModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting conversations: $e');
      return [];
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _firestore
          .collection(AppConstants.conversationsCollection)
          .doc(conversationId)
          .update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      print('Error marking messages as read: $e');
      rethrow;
    }
  }

  // ============ NOTIFICATION OPERATIONS ============

  // Create notification
  Future<void> createNotification({
    required String userId,
    required String fromUserId,
    required String fromUsername,
    required String fromUserPhotoUrl,
    required String type,
    required String text,
    String? postId,
    String? postImageUrl,
  }) async {
    try {
      // Don't create notification for own actions
      if (userId == fromUserId) return;

      final notificationId = _uuid.v4();

      final notification = NotificationModel(
        notificationId: notificationId,
        userId: userId,
        fromUserId: fromUserId,
        fromUsername: fromUsername,
        fromUserPhotoUrl: fromUserPhotoUrl,
        type: type,
        postId: postId,
        postImageUrl: postImageUrl,
        text: text,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .set(notification.toMap());
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  // Get user notifications
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Get notifications stream
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromDocument(doc))
            .toList());
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }
}
