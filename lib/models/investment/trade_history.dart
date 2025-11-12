import 'package:cloud_firestore/cloud_firestore.dart';
import 'asset_holding.dart';

/// Trade Type Enum
enum TradeType {
  buy,
  sell,
}

extension TradeTypeExtension on TradeType {
  String get name {
    switch (this) {
      case TradeType.buy:
        return 'Buy';
      case TradeType.sell:
        return 'Sell';
    }
  }

  String get koreanName {
    switch (this) {
      case TradeType.buy:
        return '매수';
      case TradeType.sell:
        return '매도';
    }
  }

  static TradeType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'buy':
        return TradeType.buy;
      case 'sell':
        return TradeType.sell;
      default:
        return TradeType.buy;
    }
  }
}

/// Trade History Model - Records all buy/sell transactions
class TradeHistory {
  final String tradeId;
  final String userId;
  final String portfolioId;
  final String assetSymbol;
  final String assetName;
  final AssetType assetType;
  final TradeType tradeType;
  final double quantity;
  final double price; // Price per unit
  final double totalAmount; // quantity * price
  final double fee; // Transaction fee
  final String? currency;
  final DateTime tradeDate;
  final String? note; // User's note about this trade
  final String? reason; // Investment thesis/reason
  final bool isSharedPublicly; // Whether to share in feed
  final DateTime createdAt;

  TradeHistory({
    required this.tradeId,
    required this.userId,
    required this.portfolioId,
    required this.assetSymbol,
    required this.assetName,
    required this.assetType,
    required this.tradeType,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    this.fee = 0.0,
    this.currency = 'USD',
    required this.tradeDate,
    this.note,
    this.reason,
    this.isSharedPublicly = false,
    required this.createdAt,
  });

  // Calculate net amount (including fees)
  double get netAmount {
    if (tradeType == TradeType.buy) {
      return totalAmount + fee;
    } else {
      return totalAmount - fee;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'tradeId': tradeId,
      'userId': userId,
      'portfolioId': portfolioId,
      'assetSymbol': assetSymbol,
      'assetName': assetName,
      'assetType': assetType.toString().split('.').last,
      'tradeType': tradeType.toString().split('.').last,
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
      'fee': fee,
      'currency': currency,
      'tradeDate': Timestamp.fromDate(tradeDate),
      'note': note,
      'reason': reason,
      'isSharedPublicly': isSharedPublicly,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TradeHistory.fromMap(Map<String, dynamic> map) {
    return TradeHistory(
      tradeId: map['tradeId'] ?? '',
      userId: map['userId'] ?? '',
      portfolioId: map['portfolioId'] ?? '',
      assetSymbol: map['assetSymbol'] ?? '',
      assetName: map['assetName'] ?? '',
      assetType: AssetTypeExtension.fromString(map['assetType'] ?? 'other'),
      tradeType: TradeTypeExtension.fromString(map['tradeType'] ?? 'buy'),
      quantity: (map['quantity'] ?? 0).toDouble(),
      price: (map['price'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      fee: (map['fee'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      tradeDate: (map['tradeDate'] as Timestamp).toDate(),
      note: map['note'],
      reason: map['reason'],
      isSharedPublicly: map['isSharedPublicly'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory TradeHistory.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TradeHistory.fromMap({
      ...data,
      'tradeId': doc.id,
    });
  }

  TradeHistory copyWith({
    String? tradeId,
    String? userId,
    String? portfolioId,
    String? assetSymbol,
    String? assetName,
    AssetType? assetType,
    TradeType? tradeType,
    double? quantity,
    double? price,
    double? totalAmount,
    double? fee,
    String? currency,
    DateTime? tradeDate,
    String? note,
    String? reason,
    bool? isSharedPublicly,
    DateTime? createdAt,
  }) {
    return TradeHistory(
      tradeId: tradeId ?? this.tradeId,
      userId: userId ?? this.userId,
      portfolioId: portfolioId ?? this.portfolioId,
      assetSymbol: assetSymbol ?? this.assetSymbol,
      assetName: assetName ?? this.assetName,
      assetType: assetType ?? this.assetType,
      tradeType: tradeType ?? this.tradeType,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalAmount: totalAmount ?? this.totalAmount,
      fee: fee ?? this.fee,
      currency: currency ?? this.currency,
      tradeDate: tradeDate ?? this.tradeDate,
      note: note ?? this.note,
      reason: reason ?? this.reason,
      isSharedPublicly: isSharedPublicly ?? this.isSharedPublicly,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
