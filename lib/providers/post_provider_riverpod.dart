import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

// Feed posts provider
final feedPostsProvider = FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  final databaseService = DatabaseService();
  return await databaseService.getFeedPosts(userId);
});

// User posts provider
final userPostsProvider = FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  final databaseService = DatabaseService();
  return await databaseService.getUserPosts(userId);
});

// Single post provider
final postProvider = FutureProvider.family<PostModel?, String>((ref, postId) async {
  final databaseService = DatabaseService();
  return await databaseService.getPostById(postId);
});

// Post comments provider
final postCommentsProvider = FutureProvider.family<List<CommentModel>, String>((ref, postId) async {
  final databaseService = DatabaseService();
  return await databaseService.getComments(postId);
});

// Post liked status provider
final postLikedProvider = FutureProvider.family<bool, ({String postId, String userId})>((ref, params) async {
  final databaseService = DatabaseService();
  return await databaseService.isPostLiked(params.postId, params.userId);
});

// Post notifier for mutations
class PostNotifier extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  PostNotifier() : super(const AsyncValue.data(null));

  Future<bool> createPost({
    required String userId,
    required String username,
    required String userPhotoUrl,
    required List<String> imagePaths,
    required String caption,
    String? location,
  }) async {
    try {
      state = const AsyncValue.loading();

      // Upload images
      List<String> imageUrls = [];
      for (String path in imagePaths) {
        final url = await _storageService.uploadPostImage(path);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      if (imageUrls.isEmpty) {
        throw Exception('Failed to upload images');
      }

      // Extract hashtags
      final hashtags = PostModel.extractHashtags(caption);

      // Create post
      await _databaseService.createPost(
        userId: userId,
        username: username,
        userPhotoUrl: userPhotoUrl,
        imageUrls: imageUrls,
        caption: caption,
        location: location ?? '',
        hashtags: hashtags,
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> likePost(String postId, String userId) async {
    try {
      await _databaseService.likePost(postId, userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unlikePost(String postId, String userId) async {
    try {
      await _databaseService.unlikePost(postId, userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addComment({
    required String postId,
    required String userId,
    required String username,
    required String userPhotoUrl,
    required String text,
  }) async {
    try {
      await _databaseService.addComment(
        postId: postId,
        userId: userId,
        username: username,
        userPhotoUrl: userPhotoUrl,
        text: text,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _databaseService.deletePost(postId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final postNotifierProvider = StateNotifierProvider<PostNotifier, AsyncValue<void>>((ref) {
  return PostNotifier();
});
