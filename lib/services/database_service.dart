import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/story_model.dart';
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
}
