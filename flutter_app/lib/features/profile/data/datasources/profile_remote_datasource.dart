import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../feed/data/models/post_model.dart';

/// 프로필 원격 데이터소스 인터페이스
abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile(String userId);
  Future<UserModel> updateProfile({
    String? name,
    String? bio,
    String? profileImagePath,
  });
  Future<List<PostModel>> getUserPosts(String userId, {int page, int limit});
  Future<UserModel> follow(String userId);
  Future<UserModel> unfollow(String userId);
  Future<List<UserModel>> getFollowers(String userId, {int page, int limit});
  Future<List<UserModel>> getFollowing(String userId, {int page, int limit});
  Future<List<PostModel>> getBookmarkedPosts({int page, int limit});
}

/// 프로필 원격 데이터소스 구현
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _client;

  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> getProfile(String userId) async {
    try {
      final response = await _client.get(ApiEndpoints.userProfile(userId));
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? bio,
    String? profileImagePath,
  }) async {
    try {
      if (profileImagePath != null) {
        final formData = FormData.fromMap({
          if (name != null) 'name': name,
          if (bio != null) 'bio': bio,
          'profile_image': await MultipartFile.fromFile(profileImagePath),
        });
        final response = await _client.uploadFile('/users/me', formData: formData);
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        final response = await _client.patch(
          '/users/me',
          data: {
            if (name != null) 'name': name,
            if (bio != null) 'bio': bio,
          },
        );
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(
    String userId, {
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.userPosts(userId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = response.data['posts'] as List;
      return list
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> follow(String userId) async {
    try {
      final response = await _client.post(ApiEndpoints.follow(userId));
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> unfollow(String userId) async {
    try {
      final response = await _client.delete(ApiEndpoints.unfollow(userId));
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<UserModel>> getFollowers(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        '/users/$userId/followers',
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = response.data['users'] as List;
      return list
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<UserModel>> getFollowing(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        '/users/$userId/following',
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = response.data['users'] as List;
      return list
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PostModel>> getBookmarkedPosts({
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final response = await _client.get(
        '/users/me/bookmarks',
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = response.data['posts'] as List;
      return list
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
