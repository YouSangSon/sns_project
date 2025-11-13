import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/investment/investment_portfolio.dart';
import '../models/investment/asset_holding.dart';

/// Portfolio Analytics - Advanced analysis and insights
class PortfolioAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Calculate portfolio risk score (0-100)
  Future<double> calculateRiskScore(String portfolioId) async {
    try {
      final holdings = await _firestore
          .collection('asset_holdings')
          .where('portfolioId', isEqualTo: portfolioId)
          .get();

      if (holdings.docs.isEmpty) {
        return 0.0;
      }

      // Factors: concentration, volatility, asset type mix
      double concentrationRisk = _calculateConcentrationRisk(holdings.docs);
      double assetTypeRisk = _calculateAssetTypeRisk(holdings.docs);

      // Weighted average
      double riskScore = (concentrationRisk * 0.6) + (assetTypeRisk * 0.4);

      return riskScore.clamp(0.0, 100.0);
    } catch (e) {
      print('Error calculating risk score: $e');
      return 50.0; // Default medium risk
    }
  }

  /// Calculate concentration risk (higher if portfolio is concentrated)
  double _calculateConcentrationRisk(List<QueryDocumentSnapshot> holdings) {
    if (holdings.isEmpty) return 0.0;

    List<double> values = holdings.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return (data['totalValue'] as num?)?.toDouble() ?? 0.0;
    }).toList();

    double totalValue = values.reduce((a, b) => a + b);

    if (totalValue == 0) return 0.0;

    // Calculate Herfindahl Index (concentration measure)
    double herfindahlIndex = 0.0;
    for (var value in values) {
      double share = value / totalValue;
      herfindahlIndex += share * share;
    }

    // Convert to risk score (0-100)
    // HHI ranges from 1/n (perfectly diversified) to 1 (all in one asset)
    return herfindahlIndex * 100;
  }

  /// Calculate asset type risk
  double _calculateAssetTypeRisk(List<QueryDocumentSnapshot> holdings) {
    Map<AssetType, double> typeValues = {};
    double totalValue = 0.0;

    for (var doc in holdings) {
      final data = doc.data() as Map<String, dynamic>;
      final assetType = AssetTypeExtension.fromString(data['assetType'] ?? 'stock');
      final value = (data['totalValue'] as num?)?.toDouble() ?? 0.0;

      typeValues[assetType] = (typeValues[assetType] ?? 0.0) + value;
      totalValue += value;
    }

    if (totalValue == 0) return 50.0;

    // Risk weights by asset type
    const riskWeights = {
      AssetType.stock: 50.0,
      AssetType.crypto: 80.0,
      AssetType.etf: 30.0,
      AssetType.bond: 20.0,
      AssetType.commodity: 60.0,
      AssetType.forex: 70.0,
    };

    double weightedRisk = 0.0;
    typeValues.forEach((type, value) {
      double weight = value / totalValue;
      weightedRisk += weight * (riskWeights[type] ?? 50.0);
    });

    return weightedRisk;
  }

  /// Get risk level label
  String getRiskLevel(double riskScore) {
    if (riskScore < 30) return '낮음';
    if (riskScore < 60) return '중간';
    if (riskScore < 80) return '높음';
    return '매우 높음';
  }

  /// Calculate portfolio diversification score
  Future<double> calculateDiversificationScore(String portfolioId) async {
    try {
      final holdings = await _firestore
          .collection('asset_holdings')
          .where('portfolioId', isEqualTo: portfolioId)
          .get();

      if (holdings.docs.isEmpty) {
        return 0.0;
      }

      // Count unique sectors, asset types
      Set<String> assetTypes = {};
      double totalValue = 0.0;
      List<double> values = [];

      for (var doc in holdings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        assetTypes.add(data['assetType'] ?? 'stock');
        final value = (data['totalValue'] as num?)?.toDouble() ?? 0.0;
        values.add(value);
        totalValue += value;
      }

      // Diversification factors
      double assetTypeDiversity = assetTypes.length / 6.0; // 6 asset types
      double assetCount = min(holdings.docs.length / 20.0, 1.0); // Ideal 20 assets

      // Calculate balance (how evenly distributed)
      double balance = 1.0 - _calculateConcentrationRisk(holdings.docs) / 100.0;

      // Weighted score
      double score = (assetTypeDiversity * 0.3) + (assetCount * 0.3) + (balance * 0.4);

      return (score * 100).clamp(0.0, 100.0);
    } catch (e) {
      print('Error calculating diversification score: $e');
      return 0.0;
    }
  }

  /// Get sector allocation
  Future<Map<String, double>> getSectorAllocation(String portfolioId) async {
    try {
      final holdings = await _firestore
          .collection('asset_holdings')
          .where('portfolioId', isEqualTo: portfolioId)
          .get();

      Map<AssetType, double> allocation = {};
      double totalValue = 0.0;

      for (var doc in holdings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final assetType = AssetTypeExtension.fromString(data['assetType'] ?? 'stock');
        final value = (data['totalValue'] as num?)?.toDouble() ?? 0.0;

        allocation[assetType] = (allocation[assetType] ?? 0.0) + value;
        totalValue += value;
      }

      // Convert to percentages
      Map<String, double> percentages = {};
      allocation.forEach((type, value) {
        percentages[type.koreanName] = (value / totalValue) * 100;
      });

      return percentages;
    } catch (e) {
      print('Error getting sector allocation: $e');
      return {};
    }
  }

  /// Calculate Sharpe Ratio (simplified)
  Future<double> calculateSharpeRatio(String portfolioId) async {
    try {
      final portfolio = await _firestore
          .collection('investment_portfolios')
          .doc(portfolioId)
          .get();

      if (!portfolio.exists) return 0.0;

      final data = portfolio.data() as Map<String, dynamic>;
      final returnPercentage = (data['returnPercentage'] as num?)?.toDouble() ?? 0.0;

      // Simplified: assume risk-free rate of 3% and estimate volatility
      const riskFreeRate = 3.0;
      final riskScore = await calculateRiskScore(portfolioId);
      final estimatedVolatility = riskScore / 2; // Rough estimate

      if (estimatedVolatility == 0) return 0.0;

      // Sharpe Ratio = (Return - Risk Free Rate) / Volatility
      double sharpeRatio = (returnPercentage - riskFreeRate) / estimatedVolatility;

      return sharpeRatio;
    } catch (e) {
      print('Error calculating Sharpe ratio: $e');
      return 0.0;
    }
  }

  /// Get performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics(String portfolioId) async {
    try {
      final riskScore = await calculateRiskScore(portfolioId);
      final diversificationScore = await calculateDiversificationScore(portfolioId);
      final sharpeRatio = await calculateSharpeRatio(portfolioId);
      final sectorAllocation = await getSectorAllocation(portfolioId);

      return {
        'riskScore': riskScore,
        'riskLevel': getRiskLevel(riskScore),
        'diversificationScore': diversificationScore,
        'sharpeRatio': sharpeRatio,
        'sectorAllocation': sectorAllocation,
      };
    } catch (e) {
      print('Error getting performance metrics: $e');
      return {};
    }
  }
}
