import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/investment/investment_portfolio.dart';
import '../models/investment/asset_holding.dart';
import '../models/investment/trade_history.dart';
import '../models/investment/investment_post.dart';
import '../models/investment/investment_idea.dart';
import '../models/investment/watchlist.dart';

/// Investment Service - Handles all investment-related operations
class InvestmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Collection names
  static const String _portfoliosCollection = 'investment_portfolios';
  static const String _holdingsCollection = 'asset_holdings';
  static const String _tradesCollection = 'trade_history';
  static const String _investmentPostsCollection = 'investment_posts';
  static const String _ideasCollection = 'investment_ideas';
  static const String _watchlistsCollection = 'watchlists';

  // ========== PORTFOLIO OPERATIONS ==========

  /// Create a new portfolio
  Future<String> createPortfolio(InvestmentPortfolio portfolio) async {
    try {
      final docRef = _firestore.collection(_portfoliosCollection).doc();
      final portfolioWithId = portfolio.copyWith(portfolioId: docRef.id);
      await docRef.set(portfolioWithId.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating portfolio: $e');
      rethrow;
    }
  }

  /// Get user's portfolios
  Stream<List<InvestmentPortfolio>> getUserPortfolios(String userId) {
    return _firestore
        .collection(_portfoliosCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvestmentPortfolio.fromDocument(doc))
            .toList());
  }

  /// Get single portfolio
  Future<InvestmentPortfolio?> getPortfolio(String portfolioId) async {
    try {
      final doc = await _firestore
          .collection(_portfoliosCollection)
          .doc(portfolioId)
          .get();

      if (doc.exists) {
        return InvestmentPortfolio.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting portfolio: $e');
      return null;
    }
  }

  /// Get portfolio stream
  Stream<InvestmentPortfolio?> getPortfolioStream(String portfolioId) {
    return _firestore
        .collection(_portfoliosCollection)
        .doc(portfolioId)
        .snapshots()
        .map((doc) => doc.exists ? InvestmentPortfolio.fromDocument(doc) : null);
  }

  /// Update portfolio
  Future<void> updatePortfolio(InvestmentPortfolio portfolio) async {
    try {
      await _firestore
          .collection(_portfoliosCollection)
          .doc(portfolio.portfolioId)
          .update(portfolio.toMap());
    } catch (e) {
      print('Error updating portfolio: $e');
      rethrow;
    }
  }

  /// Delete portfolio
  Future<void> deletePortfolio(String portfolioId) async {
    try {
      // Delete all holdings first
      final holdings = await _firestore
          .collection(_holdingsCollection)
          .where('portfolioId', isEqualTo: portfolioId)
          .get();

      for (var doc in holdings.docs) {
        await doc.reference.delete();
      }

      // Delete portfolio
      await _firestore.collection(_portfoliosCollection).doc(portfolioId).delete();
    } catch (e) {
      print('Error deleting portfolio: $e');
      rethrow;
    }
  }

  /// Get public portfolios (for explore/feed)
  Stream<List<InvestmentPortfolio>> getPublicPortfolios({int limit = 20}) {
    return _firestore
        .collection(_portfoliosCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('returnRate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvestmentPortfolio.fromDocument(doc))
            .toList());
  }

  // ========== ASSET HOLDINGS OPERATIONS ==========

  /// Add holding to portfolio
  Future<String> addHolding(AssetHolding holding) async {
    try {
      final docRef = _firestore.collection(_holdingsCollection).doc();
      final holdingWithId = holding.copyWith(holdingId: docRef.id);
      await docRef.set(holdingWithId.toMap());

      // Update portfolio totals
      await _updatePortfolioTotals(holding.portfolioId);

      return docRef.id;
    } catch (e) {
      print('Error adding holding: $e');
      rethrow;
    }
  }

  /// Get portfolio holdings
  Stream<List<AssetHolding>> getPortfolioHoldings(String portfolioId) {
    return _firestore
        .collection(_holdingsCollection)
        .where('portfolioId', isEqualTo: portfolioId)
        .orderBy('totalValue', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssetHolding.fromDocument(doc))
            .toList());
  }

  /// Update holding
  Future<void> updateHolding(AssetHolding holding) async {
    try {
      await _firestore
          .collection(_holdingsCollection)
          .doc(holding.holdingId)
          .update(holding.toMap());

      // Update portfolio totals
      await _updatePortfolioTotals(holding.portfolioId);
    } catch (e) {
      print('Error updating holding: $e');
      rethrow;
    }
  }

  /// Delete holding
  Future<void> deleteHolding(String holdingId, String portfolioId) async {
    try {
      await _firestore.collection(_holdingsCollection).doc(holdingId).delete();

      // Update portfolio totals
      await _updatePortfolioTotals(portfolioId);
    } catch (e) {
      print('Error deleting holding: $e');
      rethrow;
    }
  }

  /// Update portfolio totals after holdings change
  Future<void> _updatePortfolioTotals(String portfolioId) async {
    try {
      final holdings = await _firestore
          .collection(_holdingsCollection)
          .where('portfolioId', isEqualTo: portfolioId)
          .get();

      double totalValue = 0;
      double totalCost = 0;

      for (var doc in holdings.docs) {
        final holding = AssetHolding.fromDocument(doc);
        totalValue += holding.totalValue;
        totalCost += holding.totalCost;
      }

      final totalReturn = totalValue - totalCost;
      final returnRate = totalCost > 0 ? (totalReturn / totalCost) * 100 : 0;

      await _firestore.collection(_portfoliosCollection).doc(portfolioId).update({
        'totalValue': totalValue,
        'totalCost': totalCost,
        'totalReturn': totalReturn,
        'returnRate': returnRate,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating portfolio totals: $e');
    }
  }

  // ========== TRADE HISTORY OPERATIONS ==========

  /// Add trade
  Future<String> addTrade(TradeHistory trade) async {
    try {
      final docRef = _firestore.collection(_tradesCollection).doc();
      final tradeWithId = trade.copyWith(tradeId: docRef.id);
      await docRef.set(tradeWithId.toMap());

      // Update holdings based on trade
      await _processTradeForHoldings(tradeWithId);

      return docRef.id;
    } catch (e) {
      print('Error adding trade: $e');
      rethrow;
    }
  }

  /// Get portfolio trade history
  Stream<List<TradeHistory>> getPortfolioTrades(String portfolioId) {
    return _firestore
        .collection(_tradesCollection)
        .where('portfolioId', isEqualTo: portfolioId)
        .orderBy('tradeDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TradeHistory.fromDocument(doc))
            .toList());
  }

  /// Get user's all trades
  Stream<List<TradeHistory>> getUserTrades(String userId, {int limit = 50}) {
    return _firestore
        .collection(_tradesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('tradeDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TradeHistory.fromDocument(doc))
            .toList());
  }

  /// Process trade and update holdings
  Future<void> _processTradeForHoldings(TradeHistory trade) async {
    try {
      // Find existing holding for this asset
      final existingHoldings = await _firestore
          .collection(_holdingsCollection)
          .where('portfolioId', isEqualTo: trade.portfolioId)
          .where('symbol', isEqualTo: trade.assetSymbol)
          .get();

      if (trade.tradeType == TradeType.buy) {
        if (existingHoldings.docs.isEmpty) {
          // Create new holding
          final newHolding = AssetHolding(
            holdingId: '',
            portfolioId: trade.portfolioId,
            assetType: trade.assetType,
            symbol: trade.assetSymbol,
            assetName: trade.assetName,
            quantity: trade.quantity,
            averagePrice: trade.price,
            currentPrice: trade.price,
            totalValue: trade.quantity * trade.price,
            totalCost: trade.totalAmount + trade.fee,
            currency: trade.currency,
            purchaseDate: trade.tradeDate,
            updatedAt: DateTime.now(),
          );
          await addHolding(newHolding);
        } else {
          // Update existing holding
          final holding = AssetHolding.fromDocument(existingHoldings.docs.first);
          final newQuantity = holding.quantity + trade.quantity;
          final newTotalCost = holding.totalCost + trade.totalAmount + trade.fee;
          final newAveragePrice = newTotalCost / newQuantity;

          final updatedHolding = holding.copyWith(
            quantity: newQuantity,
            averagePrice: newAveragePrice,
            totalCost: newTotalCost,
            totalValue: newQuantity * holding.currentPrice,
            updatedAt: DateTime.now(),
          );
          await updateHolding(updatedHolding);
        }
      } else if (trade.tradeType == TradeType.sell) {
        if (existingHoldings.docs.isNotEmpty) {
          final holding = AssetHolding.fromDocument(existingHoldings.docs.first);
          final newQuantity = holding.quantity - trade.quantity;

          if (newQuantity <= 0) {
            // Delete holding if all sold
            await deleteHolding(holding.holdingId, holding.portfolioId);
          } else {
            // Update holding with reduced quantity
            final proportionSold = trade.quantity / holding.quantity;
            final newTotalCost = holding.totalCost * (1 - proportionSold);

            final updatedHolding = holding.copyWith(
              quantity: newQuantity,
              totalCost: newTotalCost,
              totalValue: newQuantity * holding.currentPrice,
              updatedAt: DateTime.now(),
            );
            await updateHolding(updatedHolding);
          }
        }
      }
    } catch (e) {
      print('Error processing trade for holdings: $e');
    }
  }

  // ========== INVESTMENT POST OPERATIONS ==========

  /// Create investment post
  Future<String> createInvestmentPost(InvestmentPost post) async {
    try {
      final docRef = _firestore.collection(_investmentPostsCollection).doc();
      final postWithId = post.copyWith(postId: docRef.id);
      await docRef.set(postWithId.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating investment post: $e');
      rethrow;
    }
  }

  /// Get investment feed
  Stream<List<InvestmentPost>> getInvestmentFeed({int limit = 20}) {
    return _firestore
        .collection(_investmentPostsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvestmentPost.fromDocument(doc))
            .toList());
  }

  /// Get posts by type
  Stream<List<InvestmentPost>> getPostsByType(InvestmentPostType type, {int limit = 20}) {
    return _firestore
        .collection(_investmentPostsCollection)
        .where('postType', isEqualTo: type.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvestmentPost.fromDocument(doc))
            .toList());
  }

  /// Get posts by asset
  Stream<List<InvestmentPost>> getPostsByAsset(String symbol, {int limit = 20}) {
    return _firestore
        .collection(_investmentPostsCollection)
        .where('relatedAssets', arrayContains: symbol)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvestmentPost.fromDocument(doc))
            .toList());
  }

  /// Get user's investment posts
  Stream<List<InvestmentPost>> getUserInvestmentPosts(String userId) {
    return _firestore
        .collection(_investmentPostsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvestmentPost.fromDocument(doc))
            .toList());
  }

  /// Get single investment post by ID
  Stream<InvestmentPost?> getInvestmentPostById(String postId) {
    return _firestore
        .collection(_investmentPostsCollection)
        .doc(postId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return InvestmentPost.fromDocument(snapshot);
      }
      return null;
    });
  }

  /// Like investment post (with transaction for concurrency control)
  Future<void> likeInvestmentPost(String postId, String userId) async {
    try {
      // Track user's like to prevent duplicates
      final likeDoc = _firestore
          .collection('post_likes')
          .doc('${postId}_$userId');

      final likeSnapshot = await likeDoc.get();

      if (likeSnapshot.exists) {
        // Unlike
        await _firestore.runTransaction((transaction) async {
          final postRef = _firestore.collection(_investmentPostsCollection).doc(postId);
          final postSnapshot = await transaction.get(postRef);

          if (postSnapshot.exists) {
            transaction.update(postRef, {
              'likes': FieldValue.increment(-1),
            });
            transaction.delete(likeDoc);
          }
        });
      } else {
        // Like
        await _firestore.runTransaction((transaction) async {
          final postRef = _firestore.collection(_investmentPostsCollection).doc(postId);
          final postSnapshot = await transaction.get(postRef);

          if (postSnapshot.exists) {
            transaction.update(postRef, {
              'likes': FieldValue.increment(1),
            });
            transaction.set(likeDoc, {
              'postId': postId,
              'userId': userId,
              'likedAt': Timestamp.now(),
            });
          }
        });
      }
    } catch (e) {
      print('Error liking investment post: $e');
      rethrow;
    }
  }

  /// Check if user liked post
  Future<bool> hasLikedPost(String postId, String userId) async {
    try {
      final doc = await _firestore
          .collection('post_likes')
          .doc('${postId}_$userId')
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  /// Vote bullish/bearish on post (with transaction for concurrency control)
  Future<void> voteOnPost(String postId, String userId, bool isBullish) async {
    try {
      final voteDoc = _firestore
          .collection('post_votes')
          .doc('${postId}_$userId');

      await _firestore.runTransaction((transaction) async {
        final voteSnapshot = await transaction.get(voteDoc);
        final postRef = _firestore.collection(_investmentPostsCollection).doc(postId);
        final postSnapshot = await transaction.get(postRef);

        if (!postSnapshot.exists) return;

        if (voteSnapshot.exists) {
          // User already voted, change vote
          final previousVote = voteSnapshot.data()?['isBullish'] as bool;

          if (previousVote == isBullish) {
            // Same vote, remove it
            transaction.update(postRef, {
              isBullish ? 'bullishCount' : 'bearishCount': FieldValue.increment(-1),
            });
            transaction.delete(voteDoc);
          } else {
            // Different vote, switch
            transaction.update(postRef, {
              'bullishCount': FieldValue.increment(isBullish ? 1 : -1),
              'bearishCount': FieldValue.increment(isBullish ? -1 : 1),
            });
            transaction.update(voteDoc, {
              'isBullish': isBullish,
              'votedAt': Timestamp.now(),
            });
          }
        } else {
          // New vote
          transaction.update(postRef, {
            isBullish ? 'bullishCount' : 'bearishCount': FieldValue.increment(1),
          });
          transaction.set(voteDoc, {
            'postId': postId,
            'userId': userId,
            'isBullish': isBullish,
            'votedAt': Timestamp.now(),
          });
        }
      });
    } catch (e) {
      print('Error voting on post: $e');
      rethrow;
    }
  }

  /// Get user's vote on post
  Future<bool?> getUserVote(String postId, String userId) async {
    try {
      final doc = await _firestore
          .collection('post_votes')
          .doc('${postId}_$userId')
          .get();

      if (doc.exists) {
        return doc.data()?['isBullish'] as bool?;
      }
      return null;
    } catch (e) {
      print('Error getting user vote: $e');
      return null;
    }
  }

  // ========== INVESTMENT IDEA OPERATIONS ==========

  /// Create investment idea
  Future<String> createInvestmentIdea(InvestmentIdea idea) async {
    try {
      final docRef = _firestore.collection(_ideasCollection).doc();
      final ideaWithId = idea.copyWith(ideaId: docRef.id);
      await docRef.set(ideaWithId.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating investment idea: $e');
      rethrow;
    }
  }

  /// Get all investment ideas
  Stream<List<InvestmentIdea>> getInvestmentIdeas({int limit = 20}) {
    return _firestore
        .collection(_ideasCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvestmentIdea.fromDocument(doc))
            .toList());
  }

  /// Get active ideas
  Stream<List<InvestmentIdea>> getActiveIdeas({int limit = 20}) {
    return _firestore
        .collection(_ideasCollection)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvestmentIdea.fromDocument(doc))
            .toList());
  }

  /// Get user's investment ideas
  Stream<List<InvestmentIdea>> getUserIdeas(String userId) {
    return _firestore
        .collection(_ideasCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvestmentIdea.fromDocument(doc))
            .toList());
  }

  /// Update investment idea
  Future<void> updateInvestmentIdea(InvestmentIdea idea) async {
    try {
      await _firestore
          .collection(_ideasCollection)
          .doc(idea.ideaId)
          .update(idea.toMap());
    } catch (e) {
      print('Error updating investment idea: $e');
      rethrow;
    }
  }

  /// Follow investment idea
  Future<void> followIdea(String ideaId, String userId) async {
    try {
      await _firestore.collection(_ideasCollection).doc(ideaId).update({
        'followers': FieldValue.increment(1),
      });

      // Could also create a follower relationship document
      await _firestore.collection('idea_followers').doc('${ideaId}_$userId').set({
        'ideaId': ideaId,
        'userId': userId,
        'followedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error following idea: $e');
    }
  }

  // ========== WATCHLIST OPERATIONS ==========

  /// Add to watchlist
  Future<String> addToWatchlist(WatchList watchlistItem) async {
    try {
      final docRef = _firestore.collection(_watchlistsCollection).doc();
      final itemWithId = watchlistItem.copyWith(watchlistId: docRef.id);
      await docRef.set(itemWithId.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding to watchlist: $e');
      rethrow;
    }
  }

  /// Get user's watchlist
  Stream<List<WatchList>> getUserWatchlist(String userId) {
    return _firestore
        .collection(_watchlistsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WatchList.fromDocument(doc))
            .toList());
  }

  /// Remove from watchlist
  Future<void> removeFromWatchlist(String watchlistId) async {
    try {
      await _firestore.collection(_watchlistsCollection).doc(watchlistId).delete();
    } catch (e) {
      print('Error removing from watchlist: $e');
      rethrow;
    }
  }

  /// Update watchlist item (e.g., alert settings)
  Future<void> updateWatchlistItem(WatchList item) async {
    try {
      await _firestore
          .collection(_watchlistsCollection)
          .doc(item.watchlistId)
          .update(item.toMap());
    } catch (e) {
      print('Error updating watchlist item: $e');
      rethrow;
    }
  }

  /// Check if asset is in user's watchlist
  Future<bool> isInWatchlist(String userId, String symbol) async {
    try {
      final query = await _firestore
          .collection(_watchlistsCollection)
          .where('userId', isEqualTo: userId)
          .where('assetSymbol', isEqualTo: symbol)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking watchlist: $e');
      return false;
    }
  }

  // ========== LEADERBOARD OPERATIONS ==========

  /// Get top performers leaderboard
  /// Returns portfolios sorted by return percentage
  Stream<List<Map<String, dynamic>>> getTopPerformers({int limit = 50}) {
    return _firestore
        .collection(_portfoliosCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('returnPercentage', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> leaderboard = [];

      for (var doc in snapshot.docs) {
        final portfolio = InvestmentPortfolio.fromDocument(doc);

        // Get user details
        final userDoc = await _firestore
            .collection('users')
            .doc(portfolio.userId)
            .get();

        final userData = userDoc.data();

        leaderboard.add({
          'portfolio': portfolio,
          'username': userData?['username'] ?? 'Unknown',
          'userPhotoUrl': userData?['photoUrl'] ?? '',
          'followers': userData?['followers'] ?? 0,
        });
      }

      return leaderboard;
    });
  }

  /// Get user's rank in leaderboard
  Future<int?> getUserRank(String userId) async {
    try {
      // Get user's best portfolio
      final userPortfolios = await _firestore
          .collection(_portfoliosCollection)
          .where('userId', isEqualTo: userId)
          .where('isPublic', isEqualTo: true)
          .orderBy('returnPercentage', descending: true)
          .limit(1)
          .get();

      if (userPortfolios.docs.isEmpty) {
        return null;
      }

      final userBestReturn = userPortfolios.docs.first.data()['returnPercentage'] ?? 0.0;

      // Count portfolios with higher return
      final higherPortfolios = await _firestore
          .collection(_portfoliosCollection)
          .where('isPublic', isEqualTo: true)
          .where('returnPercentage', isGreaterThan: userBestReturn)
          .get();

      return higherPortfolios.docs.length + 1;
    } catch (e) {
      print('Error getting user rank: $e');
      return null;
    }
  }

  /// Get weekly top performers (portfolios updated in last 7 days)
  Stream<List<Map<String, dynamic>>> getWeeklyTopPerformers({int limit = 50}) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    return _firestore
        .collection(_portfoliosCollection)
        .where('isPublic', isEqualTo: true)
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(weekAgo))
        .orderBy('updatedAt', descending: false)
        .orderBy('returnPercentage', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> leaderboard = [];

      for (var doc in snapshot.docs) {
        final portfolio = InvestmentPortfolio.fromDocument(doc);

        final userDoc = await _firestore
            .collection('users')
            .doc(portfolio.userId)
            .get();

        final userData = userDoc.data();

        leaderboard.add({
          'portfolio': portfolio,
          'username': userData?['username'] ?? 'Unknown',
          'userPhotoUrl': userData?['photoUrl'] ?? '',
          'followers': userData?['followers'] ?? 0,
        });
      }

      return leaderboard;
    });
  }

  /// Get top investors by follower count
  Stream<List<Map<String, dynamic>>> getTopInvestorsByFollowers({int limit = 50}) {
    return _firestore
        .collection('users')
        .where('hasPublicPortfolio', isEqualTo: true)
        .orderBy('followers', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> topInvestors = [];

      for (var userDoc in snapshot.docs) {
        final userData = userDoc.data();

        // Get user's best portfolio
        final portfolios = await _firestore
            .collection(_portfoliosCollection)
            .where('userId', isEqualTo: userDoc.id)
            .where('isPublic', isEqualTo: true)
            .orderBy('returnPercentage', descending: true)
            .limit(1)
            .get();

        if (portfolios.docs.isNotEmpty) {
          final portfolio = InvestmentPortfolio.fromDocument(portfolios.docs.first);

          topInvestors.add({
            'userId': userDoc.id,
            'username': userData['username'] ?? 'Unknown',
            'userPhotoUrl': userData['photoUrl'] ?? '',
            'followers': userData['followers'] ?? 0,
            'portfolio': portfolio,
          });
        }
      }

      return topInvestors;
    });
  }
}
