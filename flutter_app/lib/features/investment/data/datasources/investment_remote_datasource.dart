import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/investment_repository.dart';
import '../models/portfolio_model.dart';

/// 투자 원격 데이터소스 인터페이스
abstract class InvestmentRemoteDataSource {
  Future<List<PortfolioModel>> getPortfolios();
  Future<PortfolioModel> getPortfolio(String id);
  Future<PortfolioModel> createPortfolio(String name);
  Future<void> deletePortfolio(String id);
  Future<HoldingModel> addHolding({
    required String portfolioId,
    required String symbol,
    required double quantity,
    required double price,
  });
  Future<HoldingModel> updateHolding({
    required String holdingId,
    double? quantity,
    double? averageCost,
  });
  Future<void> deleteHolding(String holdingId);
  Future<List<StockSearchResult>> searchStocks(String query);
}

/// 투자 원격 데이터소스 구현
class InvestmentRemoteDataSourceImpl implements InvestmentRemoteDataSource {
  final DioClient _client;

  InvestmentRemoteDataSourceImpl(this._client);

  @override
  Future<List<PortfolioModel>> getPortfolios() async {
    try {
      final response = await _client.get(ApiEndpoints.portfolios);
      final list = response.data['portfolios'] as List;
      return list
          .map((json) => PortfolioModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PortfolioModel> getPortfolio(String id) async {
    try {
      final response = await _client.get(ApiEndpoints.portfolio(id));
      return PortfolioModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PortfolioModel> createPortfolio(String name) async {
    try {
      final response = await _client.post(
        ApiEndpoints.portfolios,
        data: {'name': name},
      );
      return PortfolioModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deletePortfolio(String id) async {
    try {
      await _client.delete(ApiEndpoints.portfolio(id));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<HoldingModel> addHolding({
    required String portfolioId,
    required String symbol,
    required double quantity,
    required double price,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.portfolioHoldings(portfolioId),
        data: {
          'symbol': symbol,
          'quantity': quantity,
          'price': price,
        },
      );
      return HoldingModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<HoldingModel> updateHolding({
    required String holdingId,
    double? quantity,
    double? averageCost,
  }) async {
    try {
      final response = await _client.patch(
        '/holdings/$holdingId',
        data: {
          if (quantity != null) 'quantity': quantity,
          if (averageCost != null) 'average_cost': averageCost,
        },
      );
      return HoldingModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteHolding(String holdingId) async {
    try {
      await _client.delete('/holdings/$holdingId');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<StockSearchResult>> searchStocks(String query) async {
    try {
      final response = await _client.get(
        '/stocks/search',
        queryParameters: {'q': query},
      );
      final list = response.data['results'] as List;
      return list.map((json) {
        final map = json as Map<String, dynamic>;
        return StockSearchResult(
          symbol: map['symbol'] as String,
          name: map['name'] as String,
          exchange: map['exchange'] as String?,
          type: map['type'] as String?,
        );
      }).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
