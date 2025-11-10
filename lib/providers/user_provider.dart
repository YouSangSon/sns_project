import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  UserModel? _currentUser;
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load current user
  Future<void> loadUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentUser = await _databaseService.getUserById(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Search users
  Future<void> searchUsers(String query) async {
    try {
      _isLoading = true;
      notifyListeners();

      _searchResults = await _databaseService.searchUsers(query);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Follow user
  Future<bool> followUser(String currentUserId, String targetUserId) async {
    try {
      await _databaseService.followUser(currentUserId, targetUserId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Unfollow user
  Future<bool> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      await _databaseService.unfollowUser(currentUserId, targetUserId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check if following
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      return await _databaseService.isFollowing(currentUserId, targetUserId);
    } catch (e) {
      return false;
    }
  }

  // Get followers
  Future<List<UserModel>> getFollowers(String userId) async {
    try {
      return await _databaseService.getFollowers(userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get following
  Future<List<UserModel>> getFollowing(String userId) async {
    try {
      return await _databaseService.getFollowing(userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
