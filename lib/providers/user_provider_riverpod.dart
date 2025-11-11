import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

// User provider
final userProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  final databaseService = DatabaseService();
  return await databaseService.getUserById(userId);
});

// Search users provider
final searchUsersProvider = FutureProvider.family<List<UserModel>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final databaseService = DatabaseService();
  return await databaseService.searchUsers(query);
});

// Following status provider
final isFollowingProvider = FutureProvider.family<bool, ({String currentUserId, String targetUserId})>((ref, params) async {
  final databaseService = DatabaseService();
  return await databaseService.isFollowing(params.currentUserId, params.targetUserId);
});

// Followers provider
final followersProvider = FutureProvider.family<List<UserModel>, String>((ref, userId) async {
  final databaseService = DatabaseService();
  return await databaseService.getFollowers(userId);
});

// Following provider
final followingProvider = FutureProvider.family<List<UserModel>, String>((ref, userId) async {
  final databaseService = DatabaseService();
  return await databaseService.getFollowing(userId);
});

// User notifier for mutations
class UserNotifier extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _databaseService = DatabaseService();

  UserNotifier() : super(const AsyncValue.data(null));

  Future<bool> followUser(String currentUserId, String targetUserId) async {
    try {
      await _databaseService.followUser(currentUserId, targetUserId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      await _databaseService.unfollowUser(currentUserId, targetUserId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<void>>((ref) {
  return UserNotifier();
});
