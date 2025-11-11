import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/story_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/reel_model.dart';
import '../models/live_stream_model.dart';
import '../models/product_model.dart';
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

  // ============ REELS OPERATIONS ============

  // Create reel
  Future<String> createReel({
    required String userId,
    required String username,
    required String userPhotoUrl,
    required String videoUrl,
    required String thumbnailUrl,
    required String caption,
    String? audioUrl,
    String? audioName,
    required double duration,
  }) async {
    try {
      final reelId = _uuid.v4();
      final hashtags = ReelModel.extractHashtags(caption);

      final reel = ReelModel(
        reelId: reelId,
        userId: userId,
        username: username,
        userPhotoUrl: userPhotoUrl,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        caption: caption,
        audioUrl: audioUrl,
        audioName: audioName,
        hashtags: hashtags,
        duration: duration,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('reels').doc(reelId).set(reel.toMap());

      // Update user's reels count
      await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
        'reelsCount': FieldValue.increment(1),
      });

      return reelId;
    } catch (e) {
      print('Error creating reel: $e');
      rethrow;
    }
  }

  // Get reel by ID
  Future<ReelModel?> getReelById(String reelId) async {
    try {
      final doc = await _firestore.collection('reels').doc(reelId).get();
      if (doc.exists) {
        return ReelModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting reel: $e');
      rethrow;
    }
  }

  // Get reels feed (all reels, sorted by newest)
  Stream<List<ReelModel>> getReelsFeed({int limit = 20}) {
    return _firestore
        .collection('reels')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReelModel.fromDocument(doc)).toList());
  }

  // Get user's reels
  Stream<List<ReelModel>> getUserReels(String userId) {
    return _firestore
        .collection('reels')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReelModel.fromDocument(doc)).toList());
  }

  // Like reel
  Future<void> likeReel(String reelId, String userId) async {
    try {
      final likeId = '${userId}_$reelId';
      await _firestore.collection('reel_likes').doc(likeId).set({
        'reelId': reelId,
        'userId': userId,
        'createdAt': Timestamp.now(),
      });

      await _firestore.collection('reels').doc(reelId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error liking reel: $e');
      rethrow;
    }
  }

  // Unlike reel
  Future<void> unlikeReel(String reelId, String userId) async {
    try {
      final likeId = '${userId}_$reelId';
      await _firestore.collection('reel_likes').doc(likeId).delete();

      await _firestore.collection('reels').doc(reelId).update({
        'likes': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unliking reel: $e');
      rethrow;
    }
  }

  // Check if user liked reel
  Future<bool> hasLikedReel(String reelId, String userId) async {
    try {
      final likeId = '${userId}_$reelId';
      final doc = await _firestore.collection('reel_likes').doc(likeId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking reel like: $e');
      return false;
    }
  }

  // Increment reel views
  Future<void> incrementReelViews(String reelId) async {
    try {
      await _firestore.collection('reels').doc(reelId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing reel views: $e');
      rethrow;
    }
  }

  // Delete reel
  Future<void> deleteReel(String reelId, String userId) async {
    try {
      await _firestore.collection('reels').doc(reelId).delete();

      // Delete all likes for this reel
      final likesQuery = await _firestore
          .collection('reel_likes')
          .where('reelId', isEqualTo: reelId)
          .get();

      final batch = _firestore.batch();
      for (var doc in likesQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Update user's reels count
      await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
        'reelsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error deleting reel: $e');
      rethrow;
    }
  }

  // ============ LIVE STREAMING OPERATIONS ============

  // Create live stream
  Future<String> createLiveStream({
    required String userId,
    required String username,
    required String userPhotoUrl,
    required String title,
    String description = '',
    String? thumbnailUrl,
    DateTime? scheduledAt,
  }) async {
    try {
      final streamId = _uuid.v4();

      final liveStream = LiveStreamModel(
        streamId: streamId,
        userId: userId,
        username: username,
        userPhotoUrl: userPhotoUrl,
        title: title,
        description: description,
        thumbnailUrl: thumbnailUrl ?? '',
        status: scheduledAt != null ? LiveStreamStatus.scheduled : LiveStreamStatus.live,
        scheduledAt: scheduledAt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('live_streams').doc(streamId).set(liveStream.toMap());

      return streamId;
    } catch (e) {
      print('Error creating live stream: $e');
      rethrow;
    }
  }

  // Get live stream by ID
  Future<LiveStreamModel?> getLiveStreamById(String streamId) async {
    try {
      final doc = await _firestore.collection('live_streams').doc(streamId).get();
      if (doc.exists) {
        return LiveStreamModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting live stream: $e');
      rethrow;
    }
  }

  // Get active live streams
  Stream<List<LiveStreamModel>> getActiveLiveStreams() {
    return _firestore
        .collection('live_streams')
        .where('status', isEqualTo: 'live')
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LiveStreamModel.fromDocument(doc)).toList());
  }

  // Get user's live streams
  Stream<List<LiveStreamModel>> getUserLiveStreams(String userId) {
    return _firestore
        .collection('live_streams')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LiveStreamModel.fromDocument(doc)).toList());
  }

  // Start live stream
  Future<void> startLiveStream(String streamId, String agoraChannelName, String agoraToken) async {
    try {
      await _firestore.collection('live_streams').doc(streamId).update({
        'status': 'live',
        'agoraChannelName': agoraChannelName,
        'agoraToken': agoraToken,
        'startedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error starting live stream: $e');
      rethrow;
    }
  }

  // End live stream
  Future<void> endLiveStream(String streamId) async {
    try {
      await _firestore.collection('live_streams').doc(streamId).update({
        'status': 'ended',
        'endedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error ending live stream: $e');
      rethrow;
    }
  }

  // Update live stream viewer count
  Future<void> updateLiveStreamViewers(String streamId, int viewerCount) async {
    try {
      final doc = await _firestore.collection('live_streams').doc(streamId).get();
      final currentPeak = doc.data()?['peakViewerCount'] ?? 0;

      await _firestore.collection('live_streams').doc(streamId).update({
        'viewerCount': viewerCount,
        'peakViewerCount': viewerCount > currentPeak ? viewerCount : currentPeak,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating live stream viewers: $e');
      rethrow;
    }
  }

  // Like live stream
  Future<void> likeLiveStream(String streamId) async {
    try {
      await _firestore.collection('live_streams').doc(streamId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error liking live stream: $e');
      rethrow;
    }
  }

  // Delete live stream
  Future<void> deleteLiveStream(String streamId) async {
    try {
      await _firestore.collection('live_streams').doc(streamId).delete();
    } catch (e) {
      print('Error deleting live stream: $e');
      rethrow;
    }
  }

  // ============ SHOPPING/PRODUCT OPERATIONS ============

  // Create product
  Future<String> createProduct({
    required String sellerId,
    required String sellerName,
    required String sellerPhotoUrl,
    required String name,
    required String description,
    required List<String> imageUrls,
    required double price,
    double? originalPrice,
    required ProductCategory category,
    required int stockQuantity,
    List<String> tags = const [],
  }) async {
    try {
      final productId = _uuid.v4();

      final product = ProductModel(
        productId: productId,
        sellerId: sellerId,
        sellerName: sellerName,
        sellerPhotoUrl: sellerPhotoUrl,
        name: name,
        description: description,
        imageUrls: imageUrls,
        price: price,
        originalPrice: originalPrice,
        category: category,
        stockQuantity: stockQuantity,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('products').doc(productId).set(product.toMap());

      return productId;
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      rethrow;
    }
  }

  // Get all products
  Stream<List<ProductModel>> getAllProducts({int limit = 20}) {
    return _firestore
        .collection('products')
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
  }

  // Get products by category
  Stream<List<ProductModel>> getProductsByCategory(ProductCategory category, {int limit = 20}) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category.toString().split('.').last)
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
  }

  // Get seller's products
  Stream<List<ProductModel>> getSellerProducts(String sellerId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
  }

  // Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection('products').doc(productId).update(updates);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // Create order
  Future<String> createOrder({
    required String userId,
    required List<CartItem> items,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      final orderId = _uuid.v4();

      final subtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
      final tax = subtotal * 0.1; // 10% tax
      final shipping = 5.0; // Flat shipping fee
      final total = subtotal + tax + shipping;

      final order = Order(
        orderId: orderId,
        userId: userId,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: total,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('orders').doc(orderId).set(order.toMap());

      // Update product stock quantities
      final batch = _firestore.batch();
      for (var item in items) {
        final productRef = _firestore.collection('products').doc(item.product.productId);
        batch.update(productRef, {
          'stockQuantity': FieldValue.increment(-item.quantity),
          'soldCount': FieldValue.increment(item.quantity),
        });
      }
      await batch.commit();

      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // Get user's orders
  Stream<List<Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Order.fromMap(doc.data())).toList());
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }
}
