import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/post_model.dart';

/// 피드 원격 데이터소스 인터페이스
abstract class FeedRemoteDataSource {
  Future<FeedResponseModel> getFeed({int page = 1, int limit = 10});
}

/// 피드 원격 데이터소스 구현
class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final DioClient _client;

  FeedRemoteDataSourceImpl(this._client);

  @override
  Future<FeedResponseModel> getFeed({int page = 1, int limit = 10}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.feed,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return FeedResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
