import 'package:dio/dio.dart';
import '../core/vault/secure_vault.dart';
import '../models/investment/asset_holding.dart';

/// Market Data Model
class MarketData {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double previousClose;
  final int volume;
  final DateTime timestamp;

  MarketData({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.previousClose,
    required this.volume,
    required this.timestamp,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      open: (json['open'] ?? 0).toDouble(),
      high: (json['high'] ?? 0).toDouble(),
      low: (json['low'] ?? 0).toDouble(),
      previousClose: (json['previousClose'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'change': change,
      'changePercent': changePercent,
      'open': open,
      'high': high,
      'low': low,
      'previousClose': previousClose,
      'volume': volume,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Market Data Service - Fetches real-time prices from APIs
class MarketDataService {
  final Dio _dio = Dio();
  final SecureVault _vault = SecureVault();

  // API endpoints
  static const String _alphaVantageBase = 'https://www.alphavantage.co/query';
  static const String _coinGeckoBase = 'https://api.coingecko.com/api/v3';
  static const String _finnhubBase = 'https://finnhub.io/api/v1';
  static const String _polygonBase = 'https://api.polygon.io/v2';

  // ========== STOCK DATA (Alpha Vantage) ==========

  /// Get stock quote from Alpha Vantage
  Future<MarketData?> getStockQuote(String symbol) async {
    try {
      final apiKey = await _vault.getAlphaVantageApiKey();
      if (apiKey == null) {
        print('Alpha Vantage API key not found');
        return _getMockStockData(symbol); // Return mock data if no API key
      }

      final response = await _dio.get(
        _alphaVantageBase,
        queryParameters: {
          'function': 'GLOBAL_QUOTE',
          'symbol': symbol,
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final quote = response.data['Global Quote'];
        if (quote != null && quote.isNotEmpty) {
          return MarketData(
            symbol: symbol,
            name: symbol, // Alpha Vantage doesn't provide name in quote
            price: double.parse(quote['05. price'] ?? '0'),
            change: double.parse(quote['09. change'] ?? '0'),
            changePercent: double.parse(
                quote['10. change percent']?.replaceAll('%', '') ?? '0'),
            open: double.parse(quote['02. open'] ?? '0'),
            high: double.parse(quote['03. high'] ?? '0'),
            low: double.parse(quote['04. low'] ?? '0'),
            previousClose: double.parse(quote['08. previous close'] ?? '0'),
            volume: int.parse(quote['06. volume'] ?? '0'),
            timestamp: DateTime.now(),
          );
        }
      }
    } catch (e) {
      print('Error fetching stock quote: $e');
    }
    return _getMockStockData(symbol);
  }

  /// Search stocks
  Future<List<Map<String, String>>> searchStocks(String query) async {
    try {
      final apiKey = await _vault.getAlphaVantageApiKey();
      if (apiKey == null) {
        return _getMockSearchResults(query);
      }

      final response = await _dio.get(
        _alphaVantageBase,
        queryParameters: {
          'function': 'SYMBOL_SEARCH',
          'keywords': query,
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final matches = response.data['bestMatches'] as List? ?? [];
        return matches.map((match) {
          return {
            'symbol': match['1. symbol'] ?? '',
            'name': match['2. name'] ?? '',
            'type': match['3. type'] ?? '',
            'region': match['4. region'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      print('Error searching stocks: $e');
    }
    return _getMockSearchResults(query);
  }

  // ========== CRYPTO DATA (CoinGecko) ==========

  /// Get crypto quote from CoinGecko
  Future<MarketData?> getCryptoQuote(String symbol) async {
    try {
      // CoinGecko uses coin IDs, not symbols (e.g., bitcoin, ethereum)
      final coinId = _symbolToCoinGeckoId(symbol);

      final response = await _dio.get(
        '$_coinGeckoBase/simple/price',
        queryParameters: {
          'ids': coinId,
          'vs_currencies': 'usd',
          'include_24hr_change': true,
          'include_24hr_vol': true,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data[coinId];
        if (data != null) {
          final price = (data['usd'] ?? 0).toDouble();
          final change24h = (data['usd_24h_change'] ?? 0).toDouble();

          return MarketData(
            symbol: symbol.toUpperCase(),
            name: _getCryptoName(symbol),
            price: price,
            change: price * (change24h / 100),
            changePercent: change24h,
            open: price * (100 / (100 + change24h)),
            high: price * 1.05, // Approximate
            low: price * 0.95, // Approximate
            previousClose: price * (100 / (100 + change24h)),
            volume: (data['usd_24h_vol'] ?? 0).toInt(),
            timestamp: DateTime.now(),
          );
        }
      }
    } catch (e) {
      print('Error fetching crypto quote: $e');
    }
    return _getMockCryptoData(symbol);
  }

  /// Search cryptocurrencies
  Future<List<Map<String, String>>> searchCrypto(String query) async {
    try {
      final response = await _dio.get('$_coinGeckoBase/search', queryParameters: {
        'query': query,
      });

      if (response.statusCode == 200 && response.data != null) {
        final coins = response.data['coins'] as List? ?? [];
        return coins.take(10).map((coin) {
          return {
            'symbol': (coin['symbol'] ?? '').toUpperCase(),
            'name': coin['name'] ?? '',
            'id': coin['id'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      print('Error searching crypto: $e');
    }
    return [];
  }

  // ========== BATCH UPDATES ==========

  /// Update multiple holdings with current prices
  Future<Map<String, double>> batchUpdatePrices(
      List<String> symbols, AssetType type) async {
    final priceMap = <String, double>{};

    for (final symbol in symbols) {
      MarketData? data;
      if (type == AssetType.crypto) {
        data = await getCryptoQuote(symbol);
      } else {
        data = await getStockQuote(symbol);
      }

      if (data != null) {
        priceMap[symbol] = data.price;
      }
    }

    return priceMap;
  }

  // ========== HELPER FUNCTIONS ==========

  String _symbolToCoinGeckoId(String symbol) {
    final symbolMap = {
      'BTC': 'bitcoin',
      'ETH': 'ethereum',
      'BNB': 'binancecoin',
      'XRP': 'ripple',
      'ADA': 'cardano',
      'SOL': 'solana',
      'DOT': 'polkadot',
      'DOGE': 'dogecoin',
      'MATIC': 'matic-network',
      'AVAX': 'avalanche-2',
    };
    return symbolMap[symbol.toUpperCase()] ?? symbol.toLowerCase();
  }

  String _getCryptoName(String symbol) {
    final nameMap = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'BNB': 'Binance Coin',
      'XRP': 'Ripple',
      'ADA': 'Cardano',
      'SOL': 'Solana',
      'DOT': 'Polkadot',
      'DOGE': 'Dogecoin',
      'MATIC': 'Polygon',
      'AVAX': 'Avalanche',
    };
    return nameMap[symbol.toUpperCase()] ?? symbol;
  }

  // ========== MOCK DATA (for testing without API keys) ==========

  MarketData _getMockStockData(String symbol) {
    final random = DateTime.now().millisecond / 1000;
    final basePrice = 100.0 + random * 50;
    final change = (random - 0.5) * 10;

    return MarketData(
      symbol: symbol,
      name: 'Mock Company ($symbol)',
      price: basePrice,
      change: change,
      changePercent: (change / basePrice) * 100,
      open: basePrice - change,
      high: basePrice + 5,
      low: basePrice - 5,
      previousClose: basePrice - change,
      volume: 1000000,
      timestamp: DateTime.now(),
    );
  }

  MarketData _getMockCryptoData(String symbol) {
    final random = DateTime.now().millisecond / 1000;
    final basePrice = 1000.0 + random * 500;
    final change = (random - 0.5) * 50;

    return MarketData(
      symbol: symbol,
      name: _getCryptoName(symbol),
      price: basePrice,
      change: change,
      changePercent: (change / basePrice) * 100,
      open: basePrice - change,
      high: basePrice + 50,
      low: basePrice - 50,
      previousClose: basePrice - change,
      volume: 5000000,
      timestamp: DateTime.now(),
    );
  }

  List<Map<String, String>> _getMockSearchResults(String query) {
    return [
      {'symbol': 'AAPL', 'name': 'Apple Inc.', 'type': 'Equity', 'region': 'US'},
      {'symbol': 'GOOGL', 'name': 'Alphabet Inc.', 'type': 'Equity', 'region': 'US'},
      {'symbol': 'MSFT', 'name': 'Microsoft Corporation', 'type': 'Equity', 'region': 'US'},
      {'symbol': 'TSLA', 'name': 'Tesla Inc.', 'type': 'Equity', 'region': 'US'},
      {'symbol': 'AMZN', 'name': 'Amazon.com Inc.', 'type': 'Equity', 'region': 'US'},
    ];
  }
}
