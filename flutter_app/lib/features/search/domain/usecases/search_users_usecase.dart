import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/search_repository.dart';

/// 사용자 검색 유즈케이스
class SearchUsersUseCase {
  final SearchRepository _repository;

  SearchUsersUseCase(this._repository);

  Future<Either<Failure, List<UserEntity>>> call(
    String query, {
    int page = 1,
    int limit = 20,
  }) {
    return _repository.searchUsers(query, page: page, limit: limit);
  }
}
