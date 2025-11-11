import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

/// Supabase Service for PostgreSQL database operations
///
/// This service provides a PostgreSQL backend alternative to Firebase
/// Features:
/// - User data management with PostgreSQL
/// - Post storage and retrieval
/// - Real-time subscriptions
/// - Advanced SQL queries
///
/// Database Schema (create these tables in Supabase):
///
/// users table:
/// - id: uuid (primary key)
/// - username: text (unique)
/// - email: text (unique)
/// - display_name: text
/// - bio: text
/// - photo_url: text
/// - followers_count: int
/// - following_count: int
/// - posts_count: int
/// - created_at: timestamp
/// - updated_at: timestamp
///
/// posts table:
/// - id: uuid (primary key)
/// - user_id: uuid (foreign key to users)
/// - caption: text
/// - image_urls: text[] (array)
/// - location: text
/// - likes: int
/// - comments: int
/// - created_at: timestamp
/// - updated_at: timestamp
///
/// comments table:
/// - id: uuid (primary key)
/// - post_id: uuid (foreign key to posts)
/// - user_id: uuid (foreign key to users)
/// - text: text
/// - likes: int
/// - created_at: timestamp
///
/// likes table:
/// - id: uuid (primary key)
/// - post_id: uuid (foreign key to posts)
/// - user_id: uuid (foreign key to users)
/// - created_at: timestamp
/// - unique constraint on (post_id, user_id)
///
/// follows table:
/// - id: uuid (primary key)
/// - follower_id: uuid (foreign key to users)
/// - following_id: uuid (foreign key to users)
/// - created_at: timestamp
/// - unique constraint on (follower_id, following_id)

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static bool get isInitialized => _client != null;

  /// Initialize Supabase
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      print('⚠️ Supabase not configured. Using Firebase only.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );
      _client = Supabase.instance.client;
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  // ==================== User Operations ====================

  /// Create or update user profile
  Future<void> upsertUser(UserModel user) async {
    await client.from('users').upsert({
      'id': user.uid,
      'username': user.username,
      'email': user.email,
      'display_name': user.displayName,
      'bio': user.bio,
      'photo_url': user.photoUrl,
      'followers_count': user.followersCount,
      'following_count': user.followingCount,
      'posts_count': user.postsCount,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final response = await client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return UserModel(
      uid: response['id'],
      username: response['username'] ?? '',
      email: response['email'] ?? '',
      displayName: response['display_name'] ?? '',
      bio: response['bio'] ?? '',
      photoUrl: response['photo_url'] ?? '',
      followersCount: response['followers_count'] ?? 0,
      followingCount: response['following_count'] ?? 0,
      postsCount: response['posts_count'] ?? 0,
      createdAt: DateTime.parse(response['created_at']),
    );
  }

  /// Search users by username
  Future<List<UserModel>> searchUsers(String query) async {
    final response = await client
        .from('users')
        .select()
        .ilike('username', '%$query%')
        .limit(20);

    return (response as List)
        .map((data) => UserModel(
              uid: data['id'],
              username: data['username'] ?? '',
              email: data['email'] ?? '',
              displayName: data['display_name'] ?? '',
              bio: data['bio'] ?? '',
              photoUrl: data['photo_url'] ?? '',
              followersCount: data['followers_count'] ?? 0,
              followingCount: data['following_count'] ?? 0,
              postsCount: data['posts_count'] ?? 0,
              createdAt: DateTime.parse(data['created_at']),
            ))
        .toList();
  }

  // ==================== Post Operations ====================

  /// Create a new post
  Future<String> createPost(PostModel post) async {
    final response = await client.from('posts').insert({
      'id': post.postId,
      'user_id': post.userId,
      'caption': post.caption,
      'image_urls': post.imageUrls,
      'location': post.location,
      'likes': post.likes,
      'comments': post.comments,
      'created_at': post.createdAt.toIso8601String(),
    }).select('id').single();

    return response['id'];
  }

  /// Get posts by user ID
  Future<List<PostModel>> getUserPosts(String userId) async {
    final response = await client
        .from('posts')
        .select('*, users!posts_user_id_fkey(username, photo_url)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => PostModel(
              postId: data['id'],
              userId: data['user_id'],
              username: data['users']['username'] ?? '',
              userPhotoUrl: data['users']['photo_url'] ?? '',
              caption: data['caption'] ?? '',
              imageUrls: List<String>.from(data['image_urls'] ?? []),
              location: data['location'] ?? '',
              likes: data['likes'] ?? 0,
              comments: data['comments'] ?? 0,
              createdAt: DateTime.parse(data['created_at']),
            ))
        .toList();
  }

  /// Get feed posts (posts from followed users)
  Future<List<PostModel>> getFeedPosts(String userId) async {
    final response = await client.rpc('get_feed_posts', params: {
      'current_user_id': userId,
    });

    return (response as List)
        .map((data) => PostModel(
              postId: data['id'],
              userId: data['user_id'],
              username: data['username'] ?? '',
              userPhotoUrl: data['photo_url'] ?? '',
              caption: data['caption'] ?? '',
              imageUrls: List<String>.from(data['image_urls'] ?? []),
              location: data['location'] ?? '',
              likes: data['likes'] ?? 0,
              comments: data['comments'] ?? 0,
              createdAt: DateTime.parse(data['created_at']),
            ))
        .toList();
  }

  // ==================== Like Operations ====================

  /// Like a post
  Future<void> likePost(String postId, String userId) async {
    await client.from('likes').insert({
      'post_id': postId,
      'user_id': userId,
    });

    // Increment likes count
    await client.rpc('increment_post_likes', params: {
      'post_id': postId,
    });
  }

  /// Unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    await client
        .from('likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);

    // Decrement likes count
    await client.rpc('decrement_post_likes', params: {
      'post_id': postId,
    });
  }

  /// Check if user liked a post
  Future<bool> isPostLiked(String postId, String userId) async {
    final response = await client
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    return response != null;
  }

  // ==================== Follow Operations ====================

  /// Follow a user
  Future<void> followUser(String followerId, String followingId) async {
    await client.from('follows').insert({
      'follower_id': followerId,
      'following_id': followingId,
    });

    // Update counters
    await client.rpc('increment_follower_count', params: {
      'user_id': followingId,
    });
    await client.rpc('increment_following_count', params: {
      'user_id': followerId,
    });
  }

  /// Unfollow a user
  Future<void> unfollowUser(String followerId, String followingId) async {
    await client
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', followingId);

    // Update counters
    await client.rpc('decrement_follower_count', params: {
      'user_id': followingId,
    });
    await client.rpc('decrement_following_count', params: {
      'user_id': followerId,
    });
  }

  /// Check if user is following another user
  Future<bool> isFollowing(String followerId, String followingId) async {
    final response = await client
        .from('follows')
        .select()
        .eq('follower_id', followerId)
        .eq('following_id', followingId)
        .maybeSingle();

    return response != null;
  }

  // ==================== Real-time Subscriptions ====================

  /// Subscribe to new posts from followed users
  RealtimeChannel subscribeToFeedPosts(
    String userId,
    void Function(List<PostModel>) onUpdate,
  ) {
    return client.channel('feed_posts_$userId').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'posts',
      ),
      (payload, [ref]) async {
        // Reload feed posts
        final posts = await getFeedPosts(userId);
        onUpdate(posts);
      },
    ).subscribe();
  }

  /// Subscribe to post likes
  RealtimeChannel subscribeToPostLikes(
    String postId,
    void Function(int) onUpdate,
  ) {
    return client.channel('post_likes_$postId').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'likes',
        filter: 'post_id=eq.$postId',
      ),
      (payload, [ref]) async {
        // Get updated likes count
        final response = await client
            .from('posts')
            .select('likes')
            .eq('id', postId)
            .single();
        onUpdate(response['likes'] ?? 0);
      },
    ).subscribe();
  }
}
