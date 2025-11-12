import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/vault/secure_vault.dart';
import '../models/investment/asset_holding.dart';

/// Real-time Price Update Model
class PriceUpdate {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final int volume;
  final DateTime timestamp;

  PriceUpdate({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.timestamp,
  });

  factory PriceUpdate.fromJson(Map<String, dynamic> json) {
    return PriceUpdate(
      symbol: json['symbol'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

/// Real-time Price Service using WebSocket
/// Supports multi-instance environments with connection pooling
class RealtimePriceService {
  static final RealtimePriceService _instance = RealtimePriceService._internal();
  factory RealtimePriceService() => _instance;
  RealtimePriceService._internal();

  final SecureVault _vault = SecureVault();

  // WebSocket connections pool
  final Map<String, WebSocketChannel> _connections = {};
  final Map<String, StreamController<PriceUpdate>> _priceControllers = {};
  final Map<String, Set<String>> _subscriptions = {}; // symbol -> set of subscriber IDs

  // Connection state
  final Map<String, bool> _isConnected = {};
  final Map<String, Timer?> _reconnectTimers = {};

  // Configuration
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 2);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  // ========== FINNHUB WEBSOCKET (STOCKS) ==========

  /// Connect to Finnhub WebSocket for stock prices
  Future<void> connectStockWebSocket() async {
    const String key = 'finnhub_stock';

    if (_isConnected[key] == true) {
      print('Finnhub WebSocket already connected');
      return;
    }

    try {
      final apiKey = await _vault.getFinnhubApiKey();
      if (apiKey == null) {
        print('Finnhub API key not found, using mock data');
        _startMockPriceUpdates(key, AssetType.stock);
        return;
      }

      final uri = Uri.parse('wss://ws.finnhub.io?token=$apiKey');
      final channel = WebSocketChannel.connect(uri);

      _connections[key] = channel;
      _isConnected[key] = true;

      // Listen to messages
      channel.stream.listen(
        (message) {
          _handleStockMessage(message);
        },
        onError: (error) {
          print('Finnhub WebSocket error: $error');
          _handleDisconnect(key);
        },
        onDone: () {
          print('Finnhub WebSocket disconnected');
          _handleDisconnect(key);
        },
      );

      // Start heartbeat
      _startHeartbeat(key);

      print('Finnhub WebSocket connected');
    } catch (e) {
      print('Error connecting to Finnhub WebSocket: $e');
      _handleDisconnect(key);
    }
  }

  /// Subscribe to stock symbol
  Future<Stream<PriceUpdate>> subscribeToStock(String symbol) async {
    const String key = 'finnhub_stock';

    if (!_priceControllers.containsKey(symbol)) {
      _priceControllers[symbol] = StreamController<PriceUpdate>.broadcast();
    }

    // Add subscription tracking
    final subscriberId = DateTime.now().millisecondsSinceEpoch.toString();
    _subscriptions.putIfAbsent(symbol, () => {}).add(subscriberId);

    // Ensure connected
    if (_isConnected[key] != true) {
      await connectStockWebSocket();
    }

    // Send subscribe message
    if (_isConnected[key] == true) {
      final subscribeMsg = jsonEncode({
        'type': 'subscribe',
        'symbol': symbol.toUpperCase(),
      });
      _connections[key]?.sink.add(subscribeMsg);
    }

    return _priceControllers[symbol]!.stream;
  }

  /// Unsubscribe from stock symbol
  void unsubscribeFromStock(String symbol) {
    const String key = 'finnhub_stock';

    _subscriptions[symbol]?.clear();
    _subscriptions.remove(symbol);

    if (_isConnected[key] == true && _connections.containsKey(key)) {
      final unsubscribeMsg = jsonEncode({
        'type': 'unsubscribe',
        'symbol': symbol.toUpperCase(),
      });
      _connections[key]?.sink.add(unsubscribeMsg);
    }

    _priceControllers[symbol]?.close();
    _priceControllers.remove(symbol);
  }

  // ========== BINANCE WEBSOCKET (CRYPTO) ==========

  /// Connect to Binance WebSocket for crypto prices
  Future<void> connectCryptoWebSocket() async {
    const String key = 'binance_crypto';

    if (_isConnected[key] == true) {
      print('Binance WebSocket already connected');
      return;
    }

    try {
      // Binance doesn't require API key for public streams
      final uri = Uri.parse('wss://stream.binance.com:9443/ws');
      final channel = WebSocketChannel.connect(uri);

      _connections[key] = channel;
      _isConnected[key] = true;

      channel.stream.listen(
        (message) {
          _handleCryptoMessage(message);
        },
        onError: (error) {
          print('Binance WebSocket error: $error');
          _handleDisconnect(key);
        },
        onDone: () {
          print('Binance WebSocket disconnected');
          _handleDisconnect(key);
        },
      );

      _startHeartbeat(key);

      print('Binance WebSocket connected');
    } catch (e) {
      print('Error connecting to Binance WebSocket: $e');
      _handleDisconnect(key);
    }
  }

  /// Subscribe to crypto symbol
  Future<Stream<PriceUpdate>> subscribeToCrypto(String symbol) async {
    const String key = 'binance_crypto';

    if (!_priceControllers.containsKey(symbol)) {
      _priceControllers[symbol] = StreamController<PriceUpdate>.broadcast();
    }

    final subscriberId = DateTime.now().millisecondsSinceEpoch.toString();
    _subscriptions.putIfAbsent(symbol, () => {}).add(subscriberId);

    if (_isConnected[key] != true) {
      await connectCryptoWebSocket();
    }

    // Subscribe to ticker stream
    if (_isConnected[key] == true) {
      final streamName = '${symbol.toLowerCase()}usdt@ticker';
      final subscribeMsg = jsonEncode({
        'method': 'SUBSCRIBE',
        'params': [streamName],
        'id': DateTime.now().millisecondsSinceEpoch,
      });
      _connections[key]?.sink.add(subscribeMsg);
    }

    return _priceControllers[symbol]!.stream;
  }

  /// Unsubscribe from crypto symbol
  void unsubscribeFromCrypto(String symbol) {
    const String key = 'binance_crypto';

    _subscriptions[symbol]?.clear();
    _subscriptions.remove(symbol);

    if (_isConnected[key] == true && _connections.containsKey(key)) {
      final streamName = '${symbol.toLowerCase()}usdt@ticker';
      final unsubscribeMsg = jsonEncode({
        'method': 'UNSUBSCRIBE',
        'params': [streamName],
        'id': DateTime.now().millisecondsSinceEpoch,
      });
      _connections[key]?.sink.add(unsubscribeMsg);
    }

    _priceControllers[symbol]?.close();
    _priceControllers.remove(symbol);
  }

  // ========== MESSAGE HANDLERS ==========

  void _handleStockMessage(dynamic message) {
    try {
      final data = jsonDecode(message);

      if (data['type'] == 'trade') {
        final trades = data['data'] as List;
        for (var trade in trades) {
          final symbol = trade['s'] as String;
          final price = (trade['p'] as num).toDouble();
          final volume = trade['v'] as int;

          if (_priceControllers.containsKey(symbol)) {
            final update = PriceUpdate(
              symbol: symbol,
              price: price,
              change: 0, // Calculate from previous price
              changePercent: 0,
              volume: volume,
              timestamp: DateTime.now(),
            );

            _priceControllers[symbol]!.add(update);
          }
        }
      }
    } catch (e) {
      print('Error handling stock message: $e');
    }
  }

  void _handleCryptoMessage(dynamic message) {
    try {
      final data = jsonDecode(message);

      if (data['e'] == '24hrTicker') {
        final symbol = (data['s'] as String).replaceAll('USDT', '');
        final price = double.parse(data['c'] ?? '0');
        final change = double.parse(data['p'] ?? '0');
        final changePercent = double.parse(data['P'] ?? '0');
        final volume = (data['v'] as num).toInt();

        if (_priceControllers.containsKey(symbol)) {
          final update = PriceUpdate(
            symbol: symbol,
            price: price,
            change: change,
            changePercent: changePercent,
            volume: volume,
            timestamp: DateTime.now(),
          );

          _priceControllers[symbol]!.add(update);
        }
      }
    } catch (e) {
      print('Error handling crypto message: $e');
    }
  }

  // ========== CONNECTION MANAGEMENT ==========

  void _handleDisconnect(String key) {
    _isConnected[key] = false;
    _connections.remove(key);
    _reconnectTimers[key]?.cancel();

    // Attempt reconnect with exponential backoff
    _attemptReconnect(key, 0);
  }

  void _attemptReconnect(String key, int attempt) {
    if (attempt >= _maxReconnectAttempts) {
      print('Max reconnect attempts reached for $key');
      return;
    }

    final delay = _reconnectDelay * (attempt + 1);
    _reconnectTimers[key] = Timer(delay, () async {
      print('Attempting reconnect for $key (attempt ${attempt + 1})');

      if (key == 'finnhub_stock') {
        await connectStockWebSocket();
      } else if (key == 'binance_crypto') {
        await connectCryptoWebSocket();
      }

      if (_isConnected[key] != true) {
        _attemptReconnect(key, attempt + 1);
      }
    });
  }

  void _startHeartbeat(String key) {
    Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected[key] != true) {
        timer.cancel();
        return;
      }

      try {
        _connections[key]?.sink.add(jsonEncode({'type': 'ping'}));
      } catch (e) {
        print('Heartbeat error for $key: $e');
        _handleDisconnect(key);
        timer.cancel();
      }
    });
  }

  // ========== MOCK DATA (for testing) ==========

  void _startMockPriceUpdates(String key, AssetType assetType) {
    _isConnected[key] = true;

    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isConnected[key] != true) {
        timer.cancel();
        return;
      }

      for (var symbol in _priceControllers.keys) {
        if (_subscriptions[symbol]?.isNotEmpty == true) {
          final basePrice = assetType == AssetType.crypto ? 30000.0 : 150.0;
          final randomChange = (DateTime.now().millisecond % 100 - 50) / 10;
          final price = basePrice + randomChange;

          final update = PriceUpdate(
            symbol: symbol,
            price: price,
            change: randomChange,
            changePercent: (randomChange / basePrice) * 100,
            volume: 1000000 + (DateTime.now().millisecond * 100),
            timestamp: DateTime.now(),
          );

          _priceControllers[symbol]?.add(update);
        }
      }
    });
  }

  // ========== CLEANUP ==========

  /// Dispose all connections and streams
  void dispose() {
    for (var timer in _reconnectTimers.values) {
      timer?.cancel();
    }
    _reconnectTimers.clear();

    for (var controller in _priceControllers.values) {
      controller.close();
    }
    _priceControllers.clear();

    for (var connection in _connections.values) {
      connection.sink.close();
    }
    _connections.clear();

    _subscriptions.clear();
    _isConnected.clear();
  }

  /// Get current connection status
  Map<String, bool> getConnectionStatus() {
    return Map.from(_isConnected);
  }

  /// Get active subscriptions count
  int getActiveSubscriptionsCount() {
    return _subscriptions.values
        .where((subscribers) => subscribers.isNotEmpty)
        .length;
  }
}
