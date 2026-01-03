import 'package:equatable/equatable.dart';

class Portfolio extends Equatable {
  final String portfolioId;
  final String userId;
  final String name;
  final String? description;
  final String currency;
  final double totalValue;
  final double totalProfit;
  final double totalProfitRate;
  final int followers;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Portfolio({
    required this.portfolioId,
    required this.userId,
    required this.name,
    this.description,
    this.currency = 'USD',
    this.totalValue = 0,
    this.totalProfit = 0,
    this.totalProfitRate = 0,
    this.followers = 0,
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      portfolioId: json['portfolioId'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      currency: json['currency'] ?? 'USD',
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0).toDouble(),
      totalProfitRate: (json['totalProfitRate'] ?? 0).toDouble(),
      followers: json['followers'] ?? 0,
      isPublic: json['isPublic'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolioId': portfolioId,
      'userId': userId,
      'name': name,
      'description': description,
      'currency': currency,
      'totalValue': totalValue,
      'totalProfit': totalProfit,
      'totalProfitRate': totalProfitRate,
      'followers': followers,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        portfolioId,
        userId,
        name,
        description,
        currency,
        totalValue,
        totalProfit,
        totalProfitRate,
        followers,
        isPublic,
        createdAt,
        updatedAt,
      ];
}

class Holding extends Equatable {
  final String holdingId;
  final String portfolioId;
  final String symbol;
  final String name;
  final double quantity;
  final double averagePrice;
  final double currentPrice;
  final double totalValue;
  final double profit;
  final double profitRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Holding({
    required this.holdingId,
    required this.portfolioId,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.totalValue,
    required this.profit,
    required this.profitRate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      holdingId: json['holdingId'] ?? '',
      portfolioId: json['portfolioId'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      averagePrice: (json['averagePrice'] ?? 0).toDouble(),
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      profitRate: (json['profitRate'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        holdingId,
        portfolioId,
        symbol,
        name,
        quantity,
        averagePrice,
        currentPrice,
        totalValue,
        profit,
        profitRate,
        createdAt,
        updatedAt,
      ];
}

class CreatePortfolioDto {
  final String name;
  final String? description;
  final String currency;
  final bool isPublic;

  const CreatePortfolioDto({
    required this.name,
    this.description,
    this.currency = 'USD',
    this.isPublic = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'currency': currency,
      'isPublic': isPublic,
    };
  }
}
