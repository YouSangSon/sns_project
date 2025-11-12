import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/investment/watchlist.dart';
import '../models/notification_model.dart';
import 'realtime_price_service.dart';

/// Price Alert Service - Monitors watchlist and triggers alerts
class PriceAlertService {
  static final PriceAlertService _instance = PriceAlertService._internal();
  factory PriceAlertService() => _instance;
  PriceAlertService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RealtimePriceService _priceService = RealtimePriceService();

  final Map<String, StreamSubscription> _priceSubscriptions = {};
  final Map<String, WatchList> _activeWatchlists = {};

  /// Start monitoring a watchlist item
  Future<void> startMonitoring(WatchList item) async {
    if (!item.alertEnabled || item.targetPrice == null) {
      return;
    }

    final key = '${item.userId}_${item.assetSymbol}';

    // Already monitoring
    if (_priceSubscriptions.containsKey(key)) {
      return;
    }

    // Store watchlist item
    _activeWatchlists[key] = item;

    // Subscribe to real-time prices
    Stream<PriceUpdate> priceStream;
    if (item.assetType == AssetType.crypto) {
      priceStream = await _priceService.subscribeToCrypto(item.assetSymbol);
    } else {
      priceStream = await _priceService.subscribeToStock(item.assetSymbol);
    }

    // Monitor price updates
    _priceSubscriptions[key] = priceStream.listen((priceUpdate) {
      _checkPriceAlert(item, priceUpdate.price);
    });

    print('Started monitoring price alerts for ${item.assetSymbol}');
  }

  /// Stop monitoring a watchlist item
  void stopMonitoring(String userId, String assetSymbol) {
    final key = '${userId}_$assetSymbol';

    _priceSubscriptions[key]?.cancel();
    _priceSubscriptions.remove(key);
    _activeWatchlists.remove(key);

    print('Stopped monitoring price alerts for $assetSymbol');
  }

  /// Check if price alert should be triggered
  void _checkPriceAlert(WatchList item, double currentPrice) {
    if (item.targetPrice == null ||
        item.alertCondition == null ||
        !item.alertEnabled) {
      return;
    }

    bool shouldAlert = false;

    switch (item.alertCondition!) {
      case AlertCondition.above:
        shouldAlert = currentPrice >= item.targetPrice!;
        break;
      case AlertCondition.below:
        shouldAlert = currentPrice <= item.targetPrice!;
        break;
      case AlertCondition.change:
        // Alert if price changed by target percentage
        final changePercent =
            ((currentPrice - item.addedPrice) / item.addedPrice) * 100;
        shouldAlert = changePercent.abs() >= (item.targetPrice ?? 0);
        break;
    }

    if (shouldAlert) {
      _triggerPriceAlert(item, currentPrice);
    }
  }

  /// Trigger price alert notification
  Future<void> _triggerPriceAlert(WatchList item, double currentPrice) async {
    try {
      // Create notification
      final notification = NotificationModel(
        notificationId: '',
        userId: item.userId,
        fromUserId: 'system',
        fromUsername: 'Price Alert',
        fromUserPhotoUrl: '',
        type: 'price_alert',
        text: _getPriceAlertMessage(item, currentPrice),
        isRead: false,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('notifications').add(notification.toMap());

      print('Price alert triggered: ${notification.text}');

      // Disable alert after triggering (one-time alert)
      await _firestore
          .collection('watchlists')
          .doc(item.watchlistId)
          .update({
        'alertEnabled': false,
        'alertTriggered': true,
        'alertTriggeredAt': Timestamp.now(),
        'alertTriggeredPrice': currentPrice,
      });

      // Stop monitoring this item
      stopMonitoring(item.userId, item.assetSymbol);
    } catch (e) {
      print('Error triggering price alert: $e');
    }
  }

  /// Get price alert message
  String _getPriceAlertMessage(WatchList item, double currentPrice) {
    switch (item.alertCondition!) {
      case AlertCondition.above:
        return '${item.assetSymbol}이(가) \$${currentPrice.toStringAsFixed(2)}에 도달했습니다 (목표: \$${item.targetPrice!.toStringAsFixed(2)} 이상)';
      case AlertCondition.below:
        return '${item.assetSymbol}이(가) \$${currentPrice.toStringAsFixed(2)}로 하락했습니다 (목표: \$${item.targetPrice!.toStringAsFixed(2)} 이하)';
      case AlertCondition.change:
        final changePercent =
            ((currentPrice - item.addedPrice) / item.addedPrice) * 100;
        return '${item.assetSymbol}의 가격이 ${changePercent.toStringAsFixed(2)}% 변동했습니다 (현재가: \$${currentPrice.toStringAsFixed(2)})';
    }
  }

  /// Start monitoring all watchlist items for a user
  Future<void> startMonitoringUser(String userId) async {
    try {
      final watchlistQuery = await _firestore
          .collection('watchlists')
          .where('userId', isEqualTo: userId)
          .where('alertEnabled', isEqualTo: true)
          .get();

      for (var doc in watchlistQuery.docs) {
        final watchlistItem = WatchList.fromDocument(doc);
        await startMonitoring(watchlistItem);
      }

      print('Started monitoring ${watchlistQuery.docs.length} watchlist items for user');
    } catch (e) {
      print('Error starting user monitoring: $e');
    }
  }

  /// Stop monitoring all watchlist items for a user
  void stopMonitoringUser(String userId) {
    final keysToRemove = <String>[];

    _activeWatchlists.forEach((key, item) {
      if (item.userId == userId) {
        _priceSubscriptions[key]?.cancel();
        keysToRemove.add(key);
      }
    });

    for (var key in keysToRemove) {
      _priceSubscriptions.remove(key);
      _activeWatchlists.remove(key);
    }

    print('Stopped monitoring ${keysToRemove.length} items for user');
  }

  /// Cleanup all subscriptions
  void dispose() {
    for (var subscription in _priceSubscriptions.values) {
      subscription.cancel();
    }
    _priceSubscriptions.clear();
    _activeWatchlists.clear();
  }
}
