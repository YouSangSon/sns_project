import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/portfolio_entity.dart';
import '../../domain/repositories/investment_repository.dart';
import '../datasources/investment_remote_datasource.dart';

/// 투자 레포지토리 구현
class InvestmentRepositoryImpl implements InvestmentRepository {
  final InvestmentRemoteDataSource _remoteDataSource;

  InvestmentRepositoryImpl({required InvestmentRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<PortfolioEntity>>> getPortfolios() async {
    try {
      final portfolios = await _remoteDataSource.getPortfolios();
      return Right(portfolios.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PortfolioEntity>> getPortfolio(String id) async {
    try {
      final portfolio = await _remoteDataSource.getPortfolio(id);
      return Right(portfolio.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PortfolioEntity>> createPortfolio(String name) async {
    try {
      final portfolio = await _remoteDataSource.createPortfolio(name);
      return Right(portfolio.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePortfolio(String id) async {
    try {
      await _remoteDataSource.deletePortfolio(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HoldingEntity>> addHolding({
    required String portfolioId,
    required String symbol,
    required double quantity,
    required double price,
  }) async {
    try {
      final holding = await _remoteDataSource.addHolding(
        portfolioId: portfolioId,
        symbol: symbol,
        quantity: quantity,
        price: price,
      );
      return Right(holding.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HoldingEntity>> updateHolding({
    required String holdingId,
    double? quantity,
    double? averageCost,
  }) async {
    try {
      final holding = await _remoteDataSource.updateHolding(
        holdingId: holdingId,
        quantity: quantity,
        averageCost: averageCost,
      );
      return Right(holding.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHolding(String holdingId) async {
    try {
      await _remoteDataSource.deleteHolding(holdingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockSearchResult>>> searchStocks(
      String query) async {
    try {
      final results = await _remoteDataSource.searchStocks(query);
      return Right(results);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
