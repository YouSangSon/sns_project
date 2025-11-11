import 'database_service.dart';
import 'supabase_service.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

/// Hybrid Database Service
///
/// This service intelligently routes database operations between Firebase and Supabase
/// based on configuration and availability.
///
/// Strategy:
/// - If Supabase is configured: Use Supabase as primary, Firebase as fallback
/// - If only Firebase: Use Firebase exclusively
/// - Supports dual-write for critical data (optional)
///
/// Benefits:
/// - PostgreSQL advanced queries (Supabase)
/// - Real-time updates (both)
/// - Flexibility to migrate between platforms
/// - Cost optimization
///
/// Usage:
/// ```dart
/// final hybridDb = HybridDatabaseService();
/// final user = await hybridDb.getUserById('user_id');
/// ```

enum DatabaseBackend {
  firebase,
  supabase,
  both, // Dual-write mode
}

class HybridDatabaseService {
  final DatabaseService _firebaseDb = DatabaseService();
  final SupabaseService _supabaseDb = SupabaseService();

  DatabaseBackend _primaryBackend = DatabaseBackend.firebase;
  bool _useDualWrite = false;

  HybridDatabaseService({
    DatabaseBackend? primaryBackend,
    bool useDualWrite = false,
  }) {
    _primaryBackend = primaryBackend ?? _detectPrimaryBackend();
    _useDualWrite = useDualWrite;

    print('🔄 Hybrid Database initialized');
    print('   Primary: $_primaryBackend');
    print('   Dual-write: $_useDualWrite');
  }

  /// Automatically detect which backend to use
  DatabaseBackend _detectPrimaryBackend() {
    if (SupabaseService.isInitialized) {
      return DatabaseBackend.supabase;
    }
    return DatabaseBackend.firebase;
  }

  /// Get appropriate backend for read operations
  DatabaseBackend get _readBackend => _primaryBackend;

  /// Get backends for write operations
  List<DatabaseBackend> get _writeBackends {
    if (_useDualWrite &&
        _primaryBackend != DatabaseBackend.both &&
        SupabaseService.isInitialized) {
      return [DatabaseBackend.firebase, DatabaseBackend.supabase];
    }
    return [_primaryBackend];
  }

  // ==================== User Operations ====================

  Future<void> createUser(UserModel user) async {
    for (final backend in _writeBackends) {
      try {
        switch (backend) {
          case DatabaseBackend.firebase:
            await _firebaseDb.createUser(user);
            break;
          case DatabaseBackend.supabase:
            await _supabaseDb.upsertUser(user);
            break;
          case DatabaseBackend.both:
            await Future.wait([
              _firebaseDb.createUser(user),
              _supabaseDb.upsertUser(user),
            ]);
            break;
        }
      } catch (e) {
        print('❌ Error creating user in $backend: $e');
        rethrow;
      }
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      switch (_readBackend) {
        case DatabaseBackend.supabase:
          return await _supabaseDb.getUserById(userId);
        case DatabaseBackend.firebase:
        case DatabaseBackend.both:
          return await _firebaseDb.getUserById(userId);
      }
    } catch (e) {
      print('❌ Error getting user from $_readBackend: $e');
      // Fallback to other backend
      if (_readBackend == DatabaseBackend.supabase) {
        print('🔄 Falling back to Firebase');
        return await _firebaseDb.getUserById(userId);
      }
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    for (final backend in _writeBackends) {
      try {
        switch (backend) {
          case DatabaseBackend.firebase:
            await _firebaseDb.updateUser(userId, updates);
            break;
          case DatabaseBackend.supabase:
            // Convert updates to UserModel and upsert
            final user = await getUserById(userId);
            if (user != null) {
              final updatedUser = UserModel(
                uid: user.uid,
                username: updates['username'] ?? user.username,
                email: updates['email'] ?? user.email,
                displayName: updates['displayName'] ?? user.displayName,
                bio: updates['bio'] ?? user.bio,
                photoUrl: updates['photoUrl'] ?? user.photoUrl,
                followersCount: updates['followersCount'] ?? user.followersCount,
                followingCount: updates['followingCount'] ?? user.followingCount,
                postsCount: updates['postsCount'] ?? user.postsCount,
                createdAt: user.createdAt,
              );
              await _supabaseDb.upsertUser(updatedUser);
            }
            break;
          case DatabaseBackend.both:
            await updateUser(userId, updates);
            break;
        }
      } catch (e) {
        print('❌ Error updating user in $backend: $e');
      }
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      switch (_readBackend) {
        case DatabaseBackend.supabase:
          return await _supabaseDb.searchUsers(query);
        case DatabaseBackend.firebase:
        case DatabaseBackend.both:
          return await _firebaseDb.searchUsers(query);
      }
    } catch (e) {
      print('❌ Error searching users in $_readBackend: $e');
      if (_readBackend == DatabaseBackend.supabase) {
        print('🔄 Falling back to Firebase');
        return await _firebaseDb.searchUsers(query);
      }
      rethrow;
    }
  }

  // ==================== Post Operations ====================

  Future<String> createPost(PostModel post) async {
    String? postId;

    for (final backend in _writeBackends) {
      try {
        switch (backend) {
          case DatabaseBackend.firebase:
            postId = await _firebaseDb.createPost(post);
            break;
          case DatabaseBackend.supabase:
            postId = await _supabaseDb.createPost(post);
            break;
          case DatabaseBackend.both:
            final results = await Future.wait([
              _firebaseDb.createPost(post),
              _supabaseDb.createPost(post),
            ]);
            postId = results.first;
            break;
        }
      } catch (e) {
        print('❌ Error creating post in $backend: $e');
      }
    }

    return postId ?? post.postId;
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      switch (_readBackend) {
        case DatabaseBackend.supabase:
          return await _supabaseDb.getUserPosts(userId);
        case DatabaseBackend.firebase:
        case DatabaseBackend.both:
          return await _firebaseDb.getUserPosts(userId);
      }
    } catch (e) {
      print('❌ Error getting user posts from $_readBackend: $e');
      if (_readBackend == DatabaseBackend.supabase) {
        print('🔄 Falling back to Firebase');
        return await _firebaseDb.getUserPosts(userId);
      }
      rethrow;
    }
  }

  Future<List<PostModel>> getFeedPosts(String userId) async {
    try {
      switch (_readBackend) {
        case DatabaseBackend.supabase:
          return await _supabaseDb.getFeedPosts(userId);
        case DatabaseBackend.firebase:
        case DatabaseBackend.both:
          return await _firebaseDb.getFeedPosts(userId);
      }
    } catch (e) {
      print('❌ Error getting feed posts from $_readBackend: $e');
      if (_readBackend == DatabaseBackend.supabase) {
        print('🔄 Falling back to Firebase');
        return await _firebaseDb.getFeedPosts(userId);
      }
      rethrow;
    }
  }

  Future<PostModel?> getPostById(String postId) async {
    try {
      switch (_readBackend) {
        case DatabaseBackend.firebase:
        case DatabaseBackend.both:
          return await _firebaseDb.getPostById(postId);
        case DatabaseBackend.supabase:
          // Supabase implementation needed
          return await _firebaseDb.getPostById(postId);
      }
    } catch (e) {
      print('❌ Error getting post from $_readBackend: $e');
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    for (final backend in _writeBackends) {
      try {
        switch (backend) {
          case DatabaseBackend.firebase:
            await _firebaseDb.deletePost(postId);
            break;
          case DatabaseBackend.supabase:
            // Supabase implementation needed
            break;
          case DatabaseBackend.both:
            await _firebaseDb.deletePost(postId);
            break;
        }
      } catch (e) {
        print('❌ Error deleting post in $backend: $e');
      }
    }
  }

  // ==================== Like Operations ====================

  Future<void> likePost(String postId, String userId) async {
    for (final backend in _writeBackends) {
      try {
        switch (backend) {
          case DatabaseBackend.firebase:
            await _firebaseDb.likePost(postId, userId);
            break;
          case DatabaseBackend.supabase:
            await _supabaseDb.likePost(postId, userId);
            break;
          case DatabaseBackend.both:
            await Future.wait([
              _firebaseDb.likePost(postId, userId),
              _supabaseDb.likePost(postId, userId),
            ]);
            break;
        }
      } catch (e) {
        print('❌ Error liking post in $backend: $e');
      }
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    for (final backend in _writeBackends) {
      try {
        switch (backend) {
          case DatabaseBackend.firebase:
            await _firebaseDb.unlikePost(postId, userId);
            break;
          case DatabaseBackend.supabase:
            await _supabaseDb.unlikePost(postId, userId);
            break;
          case DatabaseBackend.both:
            await Future.wait([
              _firebaseDb.unlikePost(postId, userId),
              _supabaseDb.unlikePost(postId, userId),
            ]);
            break;
        }
      } catch (e) {
        print('❌ Error unliking post in $backend: $e');
      }
    }
  }

  Future<bool> isPostLiked(String postId, String userId) async {
    try {
      switch (_readBackend) {
        case DatabaseBackend.supabase:
          return await _supabaseDb.isPostLiked(postId, userId);
        case DatabaseBackend.firebase:
        case DatabaseBackend.both:
          return await _firebaseDb.isPostLiked(postId, userId);
      }
    } catch (e) {
      print('❌ Error checking like status in $_readBackend: $e');
      if (_readBackend == DatabaseBackend.supabase) {
        return await _firebaseDb.isPostLiked(postId, userId);
      }
      rethrow;
    }
  }

  // ==================== Follow Operations ====================

  Future<void> followUser(String followerId, String followingId) async {
    for (final backend in _writeBackends) {
      try {
        switch (backend) {
          case DatabaseBackend.firebase:
            await _firebaseDb.followUser(followerId, followingId);
            break;
          case DatabaseBackend.supabase:
            await _supabaseDb.followUser(followerId, followingId);
            break;
          case DatabaseBackend.both:
            await Future.wait([
              _firebaseDb.followUser(followerId, followingId),
              _supabaseDb.followUser(followerId, followingId),
            ]);
            break;
        }
      } catch (e) {
        print('❌ Error following user in $backend: $e');
      }
    }
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    for (final backend in _writeBackends) {
      try {
        switch (backend) {
          case DatabaseBackend.firebase:
            await _firebaseDb.unfollowUser(followerId, followingId);
            break;
          case DatabaseBackend.supabase:
            await _supabaseDb.unfollowUser(followerId, followingId);
            break;
          case DatabaseBackend.both:
            await Future.wait([
              _firebaseDb.unfollowUser(followerId, followingId),
              _supabaseDb.unfollowUser(followerId, followingId),
            ]);
            break;
        }
      } catch (e) {
        print('❌ Error unfollowing user in $backend: $e');
      }
    }
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      switch (_readBackend) {
        case DatabaseBackend.supabase:
          return await _supabaseDb.isFollowing(followerId, followingId);
        case DatabaseBackend.firebase:
        case DatabaseBackend.both:
          return await _firebaseDb.isFollowing(followerId, followingId);
      }
    } catch (e) {
      print('❌ Error checking follow status in $_readBackend: $e');
      if (_readBackend == DatabaseBackend.supabase) {
        return await _firebaseDb.isFollowing(followerId, followingId);
      }
      rethrow;
    }
  }

  // ==================== Comment Operations ====================

  Future<void> addComment(CommentModel comment) async {
    for (final backend in _writeBackends) {
      try {
        switch (backend) {
          case DatabaseBackend.firebase:
            await _firebaseDb.addComment(comment);
            break;
          case DatabaseBackend.supabase:
            // Supabase implementation needed
            break;
          case DatabaseBackend.both:
            await _firebaseDb.addComment(comment);
            break;
        }
      } catch (e) {
        print('❌ Error adding comment in $backend: $e');
      }
    }
  }

  Future<List<CommentModel>> getComments(String postId) async {
    try {
      // Always use Firebase for comments for now
      return await _firebaseDb.getComments(postId);
    } catch (e) {
      print('❌ Error getting comments: $e');
      rethrow;
    }
  }

  // ==================== Follower/Following Lists ====================

  Future<List<UserModel>> getFollowers(String userId) async {
    try {
      return await _firebaseDb.getFollowers(userId);
    } catch (e) {
      print('❌ Error getting followers: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> getFollowing(String userId) async {
    try {
      return await _firebaseDb.getFollowing(userId);
    } catch (e) {
      print('❌ Error getting following: $e');
      rethrow;
    }
  }
}
