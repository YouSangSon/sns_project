import 'package:cloud_firestore/cloud_firestore.dart';

/// Asset Type Enum
enum AssetType {
  stock, // 주식
  crypto, // 암호화폐
  etf, // ETF
  fund, // 펀드
  bond, // 채권
  forex, // 외환
  commodity, // 원자재
  realEstate, // 부동산
  other, // 기타
}

extension AssetTypeExtension on AssetType {
  String get name {
    switch (this) {
      case AssetType.stock:
        return 'Stock';
      case AssetType.crypto:
        return 'Crypto';
      case AssetType.etf:
        return 'ETF';
      case AssetType.fund:
        return 'Fund';
      case AssetType.bond:
        return 'Bond';
      case AssetType.forex:
        return 'Forex';
      case AssetType.commodity:
        return 'Commodity';
      case AssetType.realEstate:
        return 'Real Estate';
      case AssetType.other:
        return 'Other';
    }
  }

  String get koreanName {
    switch (this) {
      case AssetType.stock:
        return '주식';
      case AssetType.crypto:
        return '암호화폐';
      case AssetType.etf:
        return 'ETF';
      case AssetType.fund:
        return '펀드';
      case AssetType.bond:
        return '채권';
      case AssetType.forex:
        return '외환';
      case AssetType.commodity:
        return '원자재';
      case AssetType.realEstate:
        return '부동산';
      case AssetType.other:
        return '기타';
    }
  }

  static AssetType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'stock':
        return AssetType.stock;
      case 'crypto':
        return AssetType.crypto;
      case 'etf':
        return AssetType.etf;
      case 'fund':
        return AssetType.fund;
      case 'bond':
        return AssetType.bond;
      case 'forex':
        return AssetType.forex;
      case 'commodity':
        return AssetType.commodity;
      case 'realestate':
        return AssetType.realEstate;
      default:
        return AssetType.other;
    }
  }
}

/// Asset Holding Model - Represents a single asset in a portfolio
class AssetHolding {
  final String holdingId;
  final String portfolioId;
  final AssetType assetType;
  final String symbol; // Ticker symbol (e.g., AAPL, BTC)
  final String assetName; // Full name (e.g., Apple Inc., Bitcoin)
  final double quantity; // Number of shares/coins
  final double averagePrice; // Average purchase price
  final double currentPrice; // Current market price
  final double totalValue; // quantity * currentPrice
  final double totalCost; // quantity * averagePrice
  final String? currency; // USD, KRW, etc.
  final DateTime? purchaseDate; // First purchase date
  final DateTime updatedAt;

  AssetHolding({
    required this.holdingId,
    required this.portfolioId,
    required this.assetType,
    required this.symbol,
    required this.assetName,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.totalValue,
    required this.totalCost,
    this.currency = 'USD',
    this.purchaseDate,
    required this.updatedAt,
  });

  // Calculate metrics
  double get unrealizedGain => totalValue - totalCost;
  double get unrealizedGainPercent =>
      totalCost > 0 ? ((totalValue - totalCost) / totalCost) * 100 : 0;
  double get priceChange => currentPrice - averagePrice;
  double get priceChangePercent =>
      averagePrice > 0 ? ((currentPrice - averagePrice) / averagePrice) * 100 : 0;

  bool get isProfit => unrealizedGain > 0;
  bool get isLoss => unrealizedGain < 0;

  Map<String, dynamic> toMap() {
    return {
      'holdingId': holdingId,
      'portfolioId': portfolioId,
      'assetType': assetType.toString().split('.').last,
      'symbol': symbol,
      'assetName': assetName,
      'quantity': quantity,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'totalValue': totalValue,
      'totalCost': totalCost,
      'currency': currency,
      'purchaseDate': purchaseDate != null ? Timestamp.fromDate(purchaseDate!) : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory AssetHolding.fromMap(Map<String, dynamic> map) {
    return AssetHolding(
      holdingId: map['holdingId'] ?? '',
      portfolioId: map['portfolioId'] ?? '',
      assetType: AssetTypeExtension.fromString(map['assetType'] ?? 'other'),
      symbol: map['symbol'] ?? '',
      assetName: map['assetName'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      averagePrice: (map['averagePrice'] ?? 0).toDouble(),
      currentPrice: (map['currentPrice'] ?? 0).toDouble(),
      totalValue: (map['totalValue'] ?? 0).toDouble(),
      totalCost: (map['totalCost'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      purchaseDate: map['purchaseDate'] != null
          ? (map['purchaseDate'] as Timestamp).toDate()
          : null,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory AssetHolding.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssetHolding.fromMap({
      ...data,
      'holdingId': doc.id,
    });
  }

  AssetHolding copyWith({
    String? holdingId,
    String? portfolioId,
    AssetType? assetType,
    String? symbol,
    String? assetName,
    double? quantity,
    double? averagePrice,
    double? currentPrice,
    double? totalValue,
    double? totalCost,
    String? currency,
    DateTime? purchaseDate,
    DateTime? updatedAt,
  }) {
    return AssetHolding(
      holdingId: holdingId ?? this.holdingId,
      portfolioId: portfolioId ?? this.portfolioId,
      assetType: assetType ?? this.assetType,
      symbol: symbol ?? this.symbol,
      assetName: assetName ?? this.assetName,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      totalValue: totalValue ?? this.totalValue,
      totalCost: totalCost ?? this.totalCost,
      currency: currency ?? this.currency,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
