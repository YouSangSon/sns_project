import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/portfolio_entity.dart';
import '../repositories/investment_repository.dart';

/// 포트폴리오 목록 조회 유즈케이스
class GetPortfoliosUseCase {
  final InvestmentRepository _repository;

  GetPortfoliosUseCase(this._repository);

  Future<Either<Failure, List<PortfolioEntity>>> call() {
    return _repository.getPortfolios();
  }
}
