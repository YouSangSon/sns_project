import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class PostProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  List<PostModel> _feedPosts = [];
  List<PostModel> _userPosts = [];
  PostModel? _currentPost;
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PostModel> get feedPosts => _feedPosts;
  List<PostModel> get userPosts => _userPosts;
  PostModel? get currentPost => _currentPost;
  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load feed posts
  Future<void> loadFeedPosts(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _feedPosts = await _databaseService.getFeedPosts(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load user posts
  Future<void> loadUserPosts(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _userPosts = await _databaseService.getUserPosts(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load post by ID
  Future<void> loadPost(String postId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentPost = await _databaseService.getPostById(postId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Create post
  Future<bool> createPost({
    required String userId,
    required String username,
    required String userPhotoUrl,
    required List<String> imagePaths,
    required String caption,
    String? location,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

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

  // Like post
  Future<bool> likePost(String postId, String userId) async {
    try {
      await _databaseService.likePost(postId, userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Unlike post
  Future<bool> unlikePost(String postId, String userId) async {
    try {
      await _databaseService.unlikePost(postId, userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check if post is liked
  Future<bool> isPostLiked(String postId, String userId) async {
    try {
      return await _databaseService.isPostLiked(postId, userId);
    } catch (e) {
      return false;
    }
  }

  // Load comments
  Future<void> loadComments(String postId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _comments = await _databaseService.getComments(postId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Add comment
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

      // Reload comments
      await loadComments(postId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete post
  Future<bool> deletePost(String postId) async {
    try {
      await _databaseService.deletePost(postId);
      _feedPosts.removeWhere((post) => post.postId == postId);
      _userPosts.removeWhere((post) => post.postId == postId);
      notifyListeners();
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
