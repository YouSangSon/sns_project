import 'package:cloud_firestore/cloud_firestore.dart';

/// Investment Portfolio Model
class InvestmentPortfolio {
  final String portfolioId;
  final String userId;
  final String portfolioName;
  final String? description;
  final double totalValue; // Current total value
  final double totalCost; // Total invested amount
  final double totalReturn; // Absolute return
  final double returnRate; // Percentage return
  final bool isPublic; // Whether to show in profile
  final DateTime createdAt;
  final DateTime updatedAt;

  InvestmentPortfolio({
    required this.portfolioId,
    required this.userId,
    required this.portfolioName,
    this.description,
    required this.totalValue,
    required this.totalCost,
    required this.totalReturn,
    required this.returnRate,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate metrics
  double get unrealizedGain => totalValue - totalCost;
  double get unrealizedGainPercent =>
      totalCost > 0 ? ((totalValue - totalCost) / totalCost) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'portfolioId': portfolioId,
      'userId': userId,
      'portfolioName': portfolioName,
      'description': description,
      'totalValue': totalValue,
      'totalCost': totalCost,
      'totalReturn': totalReturn,
      'returnRate': returnRate,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory InvestmentPortfolio.fromMap(Map<String, dynamic> map) {
    return InvestmentPortfolio(
      portfolioId: map['portfolioId'] ?? '',
      userId: map['userId'] ?? '',
      portfolioName: map['portfolioName'] ?? 'My Portfolio',
      description: map['description'],
      totalValue: (map['totalValue'] ?? 0).toDouble(),
      totalCost: (map['totalCost'] ?? 0).toDouble(),
      totalReturn: (map['totalReturn'] ?? 0).toDouble(),
      returnRate: (map['returnRate'] ?? 0).toDouble(),
      isPublic: map['isPublic'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory InvestmentPortfolio.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvestmentPortfolio.fromMap({
      ...data,
      'portfolioId': doc.id,
    });
  }

  InvestmentPortfolio copyWith({
    String? portfolioId,
    String? userId,
    String? portfolioName,
    String? description,
    double? totalValue,
    double? totalCost,
    double? totalReturn,
    double? returnRate,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentPortfolio(
      portfolioId: portfolioId ?? this.portfolioId,
      userId: userId ?? this.userId,
      portfolioName: portfolioName ?? this.portfolioName,
      description: description ?? this.description,
      totalValue: totalValue ?? this.totalValue,
      totalCost: totalCost ?? this.totalCost,
      totalReturn: totalReturn ?? this.totalReturn,
      returnRate: returnRate ?? this.returnRate,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
