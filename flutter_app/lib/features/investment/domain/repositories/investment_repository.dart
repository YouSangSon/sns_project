import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/portfolio_entity.dart';

/// 투자 레포지토리 인터페이스
abstract class InvestmentRepository {
  /// 포트폴리오 목록 조회
  Future<Either<Failure, List<PortfolioEntity>>> getPortfolios();

  /// 포트폴리오 상세 조회
  Future<Either<Failure, PortfolioEntity>> getPortfolio(String id);

  /// 포트폴리오 생성
  Future<Either<Failure, PortfolioEntity>> createPortfolio(String name);

  /// 포트폴리오 삭제
  Future<Either<Failure, void>> deletePortfolio(String id);

  /// 보유 종목 추가
  Future<Either<Failure, HoldingEntity>> addHolding({
    required String portfolioId,
    required String symbol,
    required double quantity,
    required double price,
  });

  /// 보유 종목 수정
  Future<Either<Failure, HoldingEntity>> updateHolding({
    required String holdingId,
    double? quantity,
    double? averageCost,
  });

  /// 보유 종목 삭제
  Future<Either<Failure, void>> deleteHolding(String holdingId);

  /// 주식 검색
  Future<Either<Failure, List<StockSearchResult>>> searchStocks(String query);
}

/// 주식 검색 결과
class StockSearchResult {
  final String symbol;
  final String name;
  final String? exchange;
  final String? type;

  const StockSearchResult({
    required this.symbol,
    required this.name,
    this.exchange,
    this.type,
  });
}
