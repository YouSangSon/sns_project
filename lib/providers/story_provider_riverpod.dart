import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

// User stories provider
final userStoriesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final databaseService = DatabaseService();
  return await databaseService.getStoriesFromFollowing(userId);
});

// Story notifier for mutations
class StoryNotifier extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  StoryNotifier() : super(const AsyncValue.data(null));

  Future<bool> createStory({
    required String userId,
    required String username,
    required String userPhotoUrl,
    required String mediaPath,
    required String mediaType,
  }) async {
    try {
      state = const AsyncValue.loading();

      // Upload media
      final mediaUrl = await _storageService.uploadStoryMedia(mediaPath, mediaType);

      if (mediaUrl == null) {
        throw Exception('Failed to upload media');
      }

      // Create story
      await _databaseService.createStory(
        userId: userId,
        username: username,
        userPhotoUrl: userPhotoUrl,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> viewStory(String storyId, String userId) async {
    try {
      await _databaseService.addStoryView(storyId, userId);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<bool> deleteStory(String storyId) async {
    try {
      await _databaseService.deleteStory(storyId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final storyNotifierProvider = StateNotifierProvider<StoryNotifier, AsyncValue<void>>((ref) {
  return StoryNotifier();
});
