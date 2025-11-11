import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class StoryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  List<Map<String, dynamic>> _userStories = []; // userId -> List<StoryModel>
  List<StoryModel> _viewingStories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get userStories => _userStories;
  List<StoryModel> get viewingStories => _viewingStories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load stories from followed users
  Future<void> loadStories(String currentUserId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _userStories = await _databaseService.getStoriesFromFollowing(currentUserId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load user's stories
  Future<void> loadUserStories(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _viewingStories = await _databaseService.getUserStories(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Create story
  Future<bool> createStory({
    required String userId,
    required String username,
    required String userPhotoUrl,
    required String mediaPath,
    required String mediaType,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

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

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // View story (add current user to views)
  Future<void> viewStory(String storyId, String userId) async {
    try {
      await _databaseService.addStoryView(storyId, userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Delete story
  Future<bool> deleteStory(String storyId) async {
    try {
      await _databaseService.deleteStory(storyId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
