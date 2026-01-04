import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../feed/data/models/post_model.dart';

/// 검색 원격 데이터소스 인터페이스
abstract class SearchRemoteDataSource {
  Future<List<UserModel>> searchUsers(String query, {int page, int limit});
  Future<List<PostModel>> searchPosts(String query, {int page, int limit});
  Future<List<PostModel>> getExploreFeed({int page, int limit});
}

/// 검색 원격 데이터소스 구현
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final DioClient _client;

  SearchRemoteDataSourceImpl(this._client);

  @override
  Future<List<UserModel>> searchUsers(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.searchUsers,
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
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
  Future<List<PostModel>> searchPosts(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        '/posts/search',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
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
  Future<List<PostModel>> getExploreFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        '/explore',
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
