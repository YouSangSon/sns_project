import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../feed/data/models/post_model.dart';

/// 게시물 원격 데이터소스 인터페이스
abstract class PostRemoteDataSource {
  Future<PostModel> getPost(String id);
  Future<PostModel> createPost({
    String? content,
    List<String>? imagePaths,
    String? location,
  });
  Future<PostModel> updatePost({
    required String id,
    String? content,
    String? location,
  });
  Future<void> deletePost(String id);
  Future<PostModel> likePost(String id);
  Future<PostModel> unlikePost(String id);
  Future<void> bookmarkPost(String id);
  Future<void> unbookmarkPost(String id);
  Future<List<CommentModel>> getComments(String postId, {int page, int limit});
  Future<CommentModel> createComment({required String postId, required String content});
  Future<void> deleteComment(String id);
}

/// 게시물 원격 데이터소스 구현
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient _client;

  PostRemoteDataSourceImpl(this._client);

  @override
  Future<PostModel> getPost(String id) async {
    try {
      final response = await _client.get(ApiEndpoints.post(id));
      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PostModel> createPost({
    String? content,
    List<String>? imagePaths,
    String? location,
  }) async {
    try {
      FormData? formData;

      if (imagePaths != null && imagePaths.isNotEmpty) {
        formData = FormData.fromMap({
          if (content != null) 'content': content,
          if (location != null) 'location': location,
          'images': await Future.wait(
            imagePaths.map((path) => MultipartFile.fromFile(path)),
          ),
        });

        final response = await _client.uploadFile(
          ApiEndpoints.posts,
          formData: formData,
        );
        return PostModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        final response = await _client.post(
          ApiEndpoints.posts,
          data: {
            if (content != null) 'content': content,
            if (location != null) 'location': location,
          },
        );
        return PostModel.fromJson(response.data as Map<String, dynamic>);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PostModel> updatePost({
    required String id,
    String? content,
    String? location,
  }) async {
    try {
      final response = await _client.patch(
        ApiEndpoints.post(id),
        data: {
          if (content != null) 'content': content,
          if (location != null) 'location': location,
        },
      );
      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      await _client.delete(ApiEndpoints.post(id));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PostModel> likePost(String id) async {
    try {
      final response = await _client.post(ApiEndpoints.likePost(id));
      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PostModel> unlikePost(String id) async {
    try {
      final response = await _client.delete(ApiEndpoints.unlikePost(id));
      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> bookmarkPost(String id) async {
    try {
      await _client.post('/posts/$id/bookmark');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unbookmarkPost(String id) async {
    try {
      await _client.delete('/posts/$id/bookmark');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CommentModel>> getComments(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.postComments(postId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = response.data['comments'] as List;
      return list
          .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CommentModel> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.postComments(postId),
        data: {'content': content},
      );
      return CommentModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteComment(String id) async {
    try {
      await _client.delete(ApiEndpoints.comment(id));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
