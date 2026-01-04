import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/story_entity.dart';
import '../models/story_model.dart';

/// 스토리 원격 데이터소스 인터페이스
abstract class StoryRemoteDataSource {
  Future<List<StoryGroupModel>> getStoryFeed();
  Future<List<StoryModel>> getUserStories(String userId);
  Future<StoryModel> createStory({
    required String mediaPath,
    required StoryType type,
  });
  Future<void> deleteStory(String id);
  Future<void> viewStory(String id);
}

/// 스토리 원격 데이터소스 구현
class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final DioClient _client;

  StoryRemoteDataSourceImpl(this._client);

  @override
  Future<List<StoryGroupModel>> getStoryFeed() async {
    try {
      final response = await _client.get(ApiEndpoints.stories);
      final list = response.data['story_groups'] as List;
      return list
          .map((json) => StoryGroupModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<StoryModel>> getUserStories(String userId) async {
    try {
      final response = await _client.get(ApiEndpoints.userStories(userId));
      final list = response.data['stories'] as List;
      return list
          .map((json) => StoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<StoryModel> createStory({
    required String mediaPath,
    required StoryType type,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': type.name,
        'media': await MultipartFile.fromFile(mediaPath),
      });

      final response = await _client.uploadFile(
        ApiEndpoints.stories,
        formData: formData,
      );
      return StoryModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteStory(String id) async {
    try {
      await _client.delete(ApiEndpoints.story(id));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> viewStory(String id) async {
    try {
      await _client.post('${ApiEndpoints.story(id)}/view');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
