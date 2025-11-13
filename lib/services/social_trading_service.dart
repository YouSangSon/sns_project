import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/investment/investment_portfolio.dart';
import '../models/investment/asset_holding.dart';

/// Social Trading Service - Follow and copy portfolios
class SocialTradingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _followedPortfoliosCollection = 'followed_portfolios';
  static const String _copiedPortfoliosCollection = 'copied_portfolios';

  /// Follow a portfolio
  Future<void> followPortfolio(String userId, String portfolioId) async {
    try {
      final followId = '${userId}_$portfolioId';

      await _firestore.collection(_followedPortfoliosCollection).doc(followId).set({
        'userId': userId,
        'portfolioId': portfolioId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // Increment follower count
      await _firestore
          .collection('investment_portfolios')
          .doc(portfolioId)
          .update({
        'followerCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error following portfolio: $e');
      rethrow;
    }
  }

  /// Unfollow a portfolio
  Future<void> unfollowPortfolio(String userId, String portfolioId) async {
    try {
      final followId = '${userId}_$portfolioId';

      await _firestore.collection(_followedPortfoliosCollection).doc(followId).delete();

      // Decrement follower count
      await _firestore
          .collection('investment_portfolios')
          .doc(portfolioId)
          .update({
        'followerCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unfollowing portfolio: $e');
      rethrow;
    }
  }

  /// Check if following portfolio
  Future<bool> isFollowingPortfolio(String userId, String portfolioId) async {
    try {
      final followId = '${userId}_$portfolioId';
      final doc = await _firestore
          .collection(_followedPortfoliosCollection)
          .doc(followId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  /// Get followed portfolios
  Stream<List<InvestmentPortfolio>> getFollowedPortfolios(String userId) {
    return _firestore
        .collection(_followedPortfoliosCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('followedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<InvestmentPortfolio> portfolios = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final portfolioId = data['portfolioId'] as String;

        final portfolioDoc = await _firestore
            .collection('investment_portfolios')
            .doc(portfolioId)
            .get();

        if (portfolioDoc.exists) {
          portfolios.add(InvestmentPortfolio.fromDocument(portfolioDoc));
        }
      }

      return portfolios;
    });
  }

  /// Copy portfolio
  Future<String> copyPortfolio(
    String userId,
    String sourcePortfolioId,
    String newPortfolioName,
  ) async {
    try {
      // Get source portfolio
      final sourceDoc = await _firestore
          .collection('investment_portfolios')
          .doc(sourcePortfolioId)
          .get();

      if (!sourceDoc.exists) {
        throw Exception('Source portfolio not found');
      }

      final sourcePortfolio = InvestmentPortfolio.fromDocument(sourceDoc);

      // Create new portfolio
      final newPortfolioRef = _firestore.collection('investment_portfolios').doc();
      final newPortfolio = InvestmentPortfolio(
        portfolioId: newPortfolioRef.id,
        userId: userId,
        name: newPortfolioName,
        description: 'Copied from ${sourcePortfolio.name}',
        totalValue: 0,
        totalCost: 0,
        totalReturn: 0,
        returnPercentage: 0,
        isPublic: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await newPortfolioRef.set(newPortfolio.toMap());

      // Copy holdings (proportionally if needed)
      final holdingsQuery = await _firestore
          .collection('asset_holdings')
          .where('portfolioId', isEqualTo: sourcePortfolioId)
          .get();

      for (var holdingDoc in holdingsQuery.docs) {
        final holding = AssetHolding.fromDocument(holdingDoc);

        // Create new holding (with quantity = 0, user needs to buy)
        final newHoldingRef = _firestore.collection('asset_holdings').doc();
        final newHolding = AssetHolding(
          holdingId: newHoldingRef.id,
          portfolioId: newPortfolio.portfolioId,
          userId: userId,
          assetSymbol: holding.assetSymbol,
          assetName: holding.assetName,
          assetType: holding.assetType,
          quantity: 0, // User needs to buy
          averagePrice: 0,
          currentPrice: holding.currentPrice,
          totalValue: 0,
          unrealizedGain: 0,
          unrealizedGainPercent: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await newHoldingRef.set(newHolding.toMap());
      }

      // Record copy
      await _firestore.collection(_copiedPortfoliosCollection).add({
        'userId': userId,
        'sourcePortfolioId': sourcePortfolioId,
        'newPortfolioId': newPortfolio.portfolioId,
        'copiedAt': FieldValue.serverTimestamp(),
      });

      return newPortfolio.portfolioId;
    } catch (e) {
      print('Error copying portfolio: $e');
      rethrow;
    }
  }

  /// Get portfolio followers count
  Future<int> getFollowerCount(String portfolioId) async {
    try {
      final query = await _firestore
          .collection(_followedPortfoliosCollection)
          .where('portfolioId', isEqualTo: portfolioId)
          .get();

      return query.docs.length;
    } catch (e) {
      print('Error getting follower count: $e');
      return 0;
    }
  }

  /// Get trending portfolios (most followed)
  Stream<List<InvestmentPortfolio>> getTrendingPortfolios({int limit = 20}) {
    return _firestore
        .collection('investment_portfolios')
        .where('isPublic', isEqualTo: true)
        .orderBy('followerCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvestmentPortfolio.fromDocument(doc))
            .toList());
  }
}
