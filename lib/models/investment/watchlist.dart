import 'package:cloud_firestore/cloud_firestore.dart';
import 'asset_holding.dart';

/// Price Alert Condition
enum AlertCondition {
  above, // Price goes above target
  below, // Price goes below target
  change, // Price changes by percentage
}

/// WatchList Model - User's list of assets to watch
class WatchList {
  final String watchlistId;
  final String userId;
  final String assetSymbol;
  final String assetName;
  final AssetType assetType;
  final double addedPrice; // Price when added to watchlist
  final double? targetPrice; // Alert price
  final AlertCondition? alertCondition;
  final double? alertPercentage; // Alert when price changes by this %
  final bool alertEnabled;
  final String? notes; // User's notes
  final DateTime addedAt;
  final DateTime updatedAt;

  WatchList({
    required this.watchlistId,
    required this.userId,
    required this.assetSymbol,
    required this.assetName,
    required this.assetType,
    required this.addedPrice,
    this.targetPrice,
    this.alertCondition,
    this.alertPercentage,
    this.alertEnabled = false,
    this.notes,
    required this.addedAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'watchlistId': watchlistId,
      'userId': userId,
      'assetSymbol': assetSymbol,
      'assetName': assetName,
      'assetType': assetType.toString().split('.').last,
      'addedPrice': addedPrice,
      'targetPrice': targetPrice,
      'alertCondition': alertCondition?.toString().split('.').last,
      'alertPercentage': alertPercentage,
      'alertEnabled': alertEnabled,
      'notes': notes,
      'addedAt': Timestamp.fromDate(addedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory WatchList.fromMap(Map<String, dynamic> map) {
    AlertCondition? condition;
    if (map['alertCondition'] != null) {
      switch (map['alertCondition'].toString().toLowerCase()) {
        case 'above':
          condition = AlertCondition.above;
          break;
        case 'below':
          condition = AlertCondition.below;
          break;
        case 'change':
          condition = AlertCondition.change;
          break;
      }
    }

    return WatchList(
      watchlistId: map['watchlistId'] ?? '',
      userId: map['userId'] ?? '',
      assetSymbol: map['assetSymbol'] ?? '',
      assetName: map['assetName'] ?? '',
      assetType: AssetTypeExtension.fromString(map['assetType'] ?? 'other'),
      addedPrice: (map['addedPrice'] ?? 0).toDouble(),
      targetPrice: map['targetPrice']?.toDouble(),
      alertCondition: condition,
      alertPercentage: map['alertPercentage']?.toDouble(),
      alertEnabled: map['alertEnabled'] ?? false,
      notes: map['notes'],
      addedAt: (map['addedAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory WatchList.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WatchList.fromMap({
      ...data,
      'watchlistId': doc.id,
    });
  }

  WatchList copyWith({
    String? watchlistId,
    String? userId,
    String? assetSymbol,
    String? assetName,
    AssetType? assetType,
    double? addedPrice,
    double? targetPrice,
    AlertCondition? alertCondition,
    double? alertPercentage,
    bool? alertEnabled,
    String? notes,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return WatchList(
      watchlistId: watchlistId ?? this.watchlistId,
      userId: userId ?? this.userId,
      assetSymbol: assetSymbol ?? this.assetSymbol,
      assetName: assetName ?? this.assetName,
      assetType: assetType ?? this.assetType,
      addedPrice: addedPrice ?? this.addedPrice,
      targetPrice: targetPrice ?? this.targetPrice,
      alertCondition: alertCondition ?? this.alertCondition,
      alertPercentage: alertPercentage ?? this.alertPercentage,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
