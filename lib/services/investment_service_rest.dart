import 'package:dio/dio.dart';
import '../models/investment/investment_portfolio.dart';
import '../models/investment/asset_holding.dart';
import '../models/investment/trade_history.dart';
import '../models/investment/investment_post.dart';
import '../models/investment/investment_idea.dart';
import '../models/investment/watchlist.dart';
import 'api_service.dart';

/// Investment Service (REST API) - Handles all investment-related operations via REST API
///
/// This is the REST API version that replaces direct Firestore access.
/// Compare with investment_service.dart (Firestore version)
class InvestmentServiceRest {
  final ApiService _api = ApiService();

  // ========== PORTFOLIO OPERATIONS ==========

  /// Create a new portfolio
  Future<String> createPortfolio(InvestmentPortfolio portfolio) async {
    try {
      final response = await _api.post(
        '/portfolios',
        data: {
          'name': portfolio.name,
          'description': portfolio.description,
          'isPublic': portfolio.isPublic,
        },
      );

      final portfolioId = response.data['portfolioId'] as String;
      return portfolioId;
    } catch (e) {
      print('Error creating portfolio: $e');
      rethrow;
    }
  }

  /// Get user's portfolios
  Future<List<InvestmentPortfolio>> getUserPortfolios(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/portfolios',
        queryParameters: {
          'userId': userId,
          'limit': limit,
          'offset': offset,
        },
      );

      final portfolios = (response.data['portfolios'] as List)
          .map((json) => InvestmentPortfolio.fromMap(json))
          .toList();

      return portfolios;
    } catch (e) {
      print('Error getting user portfolios: $e');
      return [];
    }
  }

  /// Get single portfolio
  Future<InvestmentPortfolio?> getPortfolio(String portfolioId) async {
    try {
      final response = await _api.get('/portfolios/$portfolioId');

      return InvestmentPortfolio.fromMap(response.data);
    } catch (e) {
      print('Error getting portfolio: $e');
      return null;
    }
  }

  /// Update portfolio
  Future<void> updatePortfolio(InvestmentPortfolio portfolio) async {
    try {
      await _api.put(
        '/portfolios/${portfolio.portfolioId}',
        data: {
          'name': portfolio.name,
          'description': portfolio.description,
          'isPublic': portfolio.isPublic,
        },
      );
    } catch (e) {
      print('Error updating portfolio: $e');
      rethrow;
    }
  }

  /// Delete portfolio
  Future<void> deletePortfolio(String portfolioId) async {
    try {
      await _api.delete('/portfolios/$portfolioId');
    } catch (e) {
      print('Error deleting portfolio: $e');
      rethrow;
    }
  }

  /// Get public portfolios (for explore/feed)
  Future<List<InvestmentPortfolio>> getPublicPortfolios({
    String sortBy = 'return',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/portfolios/public',
        queryParameters: {
          'sortBy': sortBy,
          'limit': limit,
          'offset': offset,
        },
      );

      final portfolios = (response.data['portfolios'] as List)
          .map((json) => InvestmentPortfolio.fromMap(json))
          .toList();

      return portfolios;
    } catch (e) {
      print('Error getting public portfolios: $e');
      return [];
    }
  }

  // ========== ASSET HOLDINGS OPERATIONS ==========

  /// Add holding to portfolio
  Future<String> addHolding(AssetHolding holding) async {
    try {
      final response = await _api.post(
        '/portfolios/${holding.portfolioId}/holdings',
        data: {
          'assetSymbol': holding.assetSymbol,
          'assetName': holding.assetName,
          'assetType': holding.assetType.toString().split('.').last,
          'quantity': holding.quantity,
          'averagePrice': holding.averagePrice,
        },
      );

      final holdingId = response.data['holdingId'] as String;
      return holdingId;
    } catch (e) {
      print('Error adding holding: $e');
      rethrow;
    }
  }

  /// Get portfolio holdings
  Future<List<AssetHolding>> getPortfolioHoldings(String portfolioId) async {
    try {
      final response = await _api.get('/portfolios/$portfolioId/holdings');

      final holdings = (response.data['holdings'] as List)
          .map((json) => AssetHolding.fromMap(json))
          .toList();

      return holdings;
    } catch (e) {
      print('Error getting portfolio holdings: $e');
      return [];
    }
  }

  /// Update holding
  Future<void> updateHolding(AssetHolding holding) async {
    try {
      await _api.put(
        '/holdings/${holding.holdingId}',
        data: {
          'quantity': holding.quantity,
          'averagePrice': holding.averagePrice,
        },
      );
    } catch (e) {
      print('Error updating holding: $e');
      rethrow;
    }
  }

  /// Delete holding
  Future<void> deleteHolding(String holdingId) async {
    try {
      await _api.delete('/holdings/$holdingId');
    } catch (e) {
      print('Error deleting holding: $e');
      rethrow;
    }
  }

  // ========== TRADE HISTORY OPERATIONS ==========

  /// Add trade
  Future<String> addTrade(TradeHistory trade) async {
    try {
      final response = await _api.post(
        '/portfolios/${trade.portfolioId}/trades',
        data: {
          'assetSymbol': trade.assetSymbol,
          'assetName': trade.assetName,
          'assetType': trade.assetType.toString().split('.').last,
          'tradeType': trade.tradeType.toString().split('.').last,
          'quantity': trade.quantity,
          'price': trade.price,
          'fee': trade.fee,
          'notes': trade.notes,
        },
      );

      final tradeId = response.data['tradeId'] as String;
      return tradeId;
    } catch (e) {
      print('Error adding trade: $e');
      rethrow;
    }
  }

  /// Get portfolio trade history
  Future<List<TradeHistory>> getPortfolioTrades(
    String portfolioId, {
    int limit = 50,
    int offset = 0,
    String? assetSymbol,
    String? tradeType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (assetSymbol != null) queryParams['assetSymbol'] = assetSymbol;
      if (tradeType != null) queryParams['tradeType'] = tradeType;

      final response = await _api.get(
        '/portfolios/$portfolioId/trades',
        queryParameters: queryParams,
      );

      final trades = (response.data['trades'] as List)
          .map((json) => TradeHistory.fromMap(json))
          .toList();

      return trades;
    } catch (e) {
      print('Error getting portfolio trades: $e');
      return [];
    }
  }

  /// Get user's all trades
  Future<List<TradeHistory>> getUserTrades(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/users/$userId/trades',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final trades = (response.data['trades'] as List)
          .map((json) => TradeHistory.fromMap(json))
          .toList();

      return trades;
    } catch (e) {
      print('Error getting user trades: $e');
      return [];
    }
  }

  // ========== INVESTMENT POST OPERATIONS ==========

  /// Create investment post
  Future<String> createInvestmentPost(InvestmentPost post) async {
    try {
      final response = await _api.post(
        '/investment-posts',
        data: {
          'portfolioId': post.portfolioId,
          'title': post.title,
          'content': post.content,
          'imageUrls': post.imageUrls,
          'tags': post.tags,
          'relatedAssets': post.relatedAssets
              ?.map((asset) => {
                    'symbol': asset.symbol,
                    'name': asset.assetName,
                    'type': asset.assetType.toString().split('.').last,
                  })
              .toList(),
        },
      );

      final postId = response.data['postId'] as String;
      return postId;
    } catch (e) {
      print('Error creating investment post: $e');
      rethrow;
    }
  }

  /// Get investment feed
  Future<List<InvestmentPost>> getInvestmentFeed({
    int limit = 20,
    int offset = 0,
    String sortBy = 'recent',
  }) async {
    try {
      final response = await _api.get(
        '/investment-posts',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'sortBy': sortBy,
        },
      );

      final posts = (response.data['posts'] as List)
          .map((json) => InvestmentPost.fromMap(json))
          .toList();

      return posts;
    } catch (e) {
      print('Error getting investment feed: $e');
      return [];
    }
  }

  /// Get posts by type
  Future<List<InvestmentPost>> getPostsByType(
    InvestmentPostType type, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/investment-posts',
        queryParameters: {
          'type': type.toString().split('.').last,
          'limit': limit,
          'offset': offset,
        },
      );

      final posts = (response.data['posts'] as List)
          .map((json) => InvestmentPost.fromMap(json))
          .toList();

      return posts;
    } catch (e) {
      print('Error getting posts by type: $e');
      return [];
    }
  }

  /// Get posts by asset
  Future<List<InvestmentPost>> getPostsByAsset(
    String symbol, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/investment-posts',
        queryParameters: {
          'assetSymbol': symbol,
          'limit': limit,
          'offset': offset,
        },
      );

      final posts = (response.data['posts'] as List)
          .map((json) => InvestmentPost.fromMap(json))
          .toList();

      return posts;
    } catch (e) {
      print('Error getting posts by asset: $e');
      return [];
    }
  }

  /// Get user's investment posts
  Future<List<InvestmentPost>> getUserInvestmentPosts(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/users/$userId/investment-posts',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final posts = (response.data['posts'] as List)
          .map((json) => InvestmentPost.fromMap(json))
          .toList();

      return posts;
    } catch (e) {
      print('Error getting user investment posts: $e');
      return [];
    }
  }

  /// Get single investment post by ID
  Future<InvestmentPost?> getInvestmentPostById(String postId) async {
    try {
      final response = await _api.get('/investment-posts/$postId');

      return InvestmentPost.fromMap(response.data);
    } catch (e) {
      print('Error getting investment post: $e');
      return null;
    }
  }

  /// Like investment post
  Future<void> likeInvestmentPost(String postId) async {
    try {
      await _api.post('/posts/$postId/like');
    } catch (e) {
      print('Error liking investment post: $e');
      rethrow;
    }
  }

  /// Unlike investment post
  Future<void> unlikeInvestmentPost(String postId) async {
    try {
      await _api.delete('/posts/$postId/like');
    } catch (e) {
      print('Error unliking investment post: $e');
      rethrow;
    }
  }

  /// Check if user liked post
  Future<bool> hasLikedPost(String postId) async {
    try {
      final response = await _api.get('/posts/$postId/like-status');
      return response.data['isLiked'] as bool;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  /// Vote bullish/bearish on post
  Future<void> voteOnPost(String postId, bool isBullish) async {
    try {
      await _api.post(
        '/investment-posts/$postId/vote',
        data: {
          'isBullish': isBullish,
        },
      );
    } catch (e) {
      print('Error voting on post: $e');
      rethrow;
    }
  }

  /// Get user's vote on post
  Future<bool?> getUserVote(String postId) async {
    try {
      final response = await _api.get('/investment-posts/$postId/vote-status');
      return response.data['isBullish'] as bool?;
    } catch (e) {
      print('Error getting user vote: $e');
      return null;
    }
  }

  // ========== INVESTMENT IDEA OPERATIONS ==========

  /// Create investment idea
  Future<String> createInvestmentIdea(InvestmentIdea idea) async {
    try {
      final response = await _api.post(
        '/investment-ideas',
        data: idea.toMap(),
      );

      final ideaId = response.data['ideaId'] as String;
      return ideaId;
    } catch (e) {
      print('Error creating investment idea: $e');
      rethrow;
    }
  }

  /// Get all investment ideas
  Future<List<InvestmentIdea>> getInvestmentIdeas({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/investment-ideas',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final ideas = (response.data['ideas'] as List)
          .map((json) => InvestmentIdea.fromMap(json))
          .toList();

      return ideas;
    } catch (e) {
      print('Error getting investment ideas: $e');
      return [];
    }
  }

  /// Get active ideas
  Future<List<InvestmentIdea>> getActiveIdeas({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/investment-ideas',
        queryParameters: {
          'status': 'active',
          'limit': limit,
          'offset': offset,
        },
      );

      final ideas = (response.data['ideas'] as List)
          .map((json) => InvestmentIdea.fromMap(json))
          .toList();

      return ideas;
    } catch (e) {
      print('Error getting active ideas: $e');
      return [];
    }
  }

  /// Get user's investment ideas
  Future<List<InvestmentIdea>> getUserIdeas(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/users/$userId/investment-ideas',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final ideas = (response.data['ideas'] as List)
          .map((json) => InvestmentIdea.fromMap(json))
          .toList();

      return ideas;
    } catch (e) {
      print('Error getting user ideas: $e');
      return [];
    }
  }

  /// Update investment idea
  Future<void> updateInvestmentIdea(InvestmentIdea idea) async {
    try {
      await _api.put(
        '/investment-ideas/${idea.ideaId}',
        data: idea.toMap(),
      );
    } catch (e) {
      print('Error updating investment idea: $e');
      rethrow;
    }
  }

  /// Follow investment idea
  Future<void> followIdea(String ideaId) async {
    try {
      await _api.post('/investment-ideas/$ideaId/follow');
    } catch (e) {
      print('Error following idea: $e');
      rethrow;
    }
  }

  /// Unfollow investment idea
  Future<void> unfollowIdea(String ideaId) async {
    try {
      await _api.delete('/investment-ideas/$ideaId/follow');
    } catch (e) {
      print('Error unfollowing idea: $e');
      rethrow;
    }
  }

  // ========== WATCHLIST OPERATIONS ==========

  /// Add to watchlist
  Future<String> addToWatchlist(WatchList watchlistItem) async {
    try {
      final response = await _api.post(
        '/watchlist',
        data: {
          'assetSymbol': watchlistItem.assetSymbol,
          'assetName': watchlistItem.assetName,
          'assetType': watchlistItem.assetType.toString().split('.').last,
          'addedPrice': watchlistItem.addedPrice,
          'alertEnabled': watchlistItem.alertEnabled,
          'alertCondition': watchlistItem.alertCondition?.toString().split('.').last,
          'targetPrice': watchlistItem.targetPrice,
        },
      );

      final watchlistId = response.data['watchlistId'] as String;
      return watchlistId;
    } catch (e) {
      print('Error adding to watchlist: $e');
      rethrow;
    }
  }

  /// Get user's watchlist
  Future<List<WatchList>> getUserWatchlist({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/watchlist',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final items = (response.data['items'] as List)
          .map((json) => WatchList.fromMap(json))
          .toList();

      return items;
    } catch (e) {
      print('Error getting watchlist: $e');
      return [];
    }
  }

  /// Remove from watchlist
  Future<void> removeFromWatchlist(String watchlistId) async {
    try {
      await _api.delete('/watchlist/$watchlistId');
    } catch (e) {
      print('Error removing from watchlist: $e');
      rethrow;
    }
  }

  /// Update watchlist item (e.g., alert settings)
  Future<void> updateWatchlistItem(WatchList item) async {
    try {
      await _api.put(
        '/watchlist/${item.watchlistId}',
        data: {
          'alertEnabled': item.alertEnabled,
          'alertCondition': item.alertCondition?.toString().split('.').last,
          'targetPrice': item.targetPrice,
        },
      );
    } catch (e) {
      print('Error updating watchlist item: $e');
      rethrow;
    }
  }

  /// Check if asset is in user's watchlist
  Future<bool> isInWatchlist(String symbol) async {
    try {
      final response = await _api.get(
        '/watchlist/check',
        queryParameters: {
          'symbol': symbol,
        },
      );

      return response.data['isInWatchlist'] as bool;
    } catch (e) {
      print('Error checking watchlist: $e');
      return false;
    }
  }

  // ========== LEADERBOARD OPERATIONS ==========

  /// Get top performers leaderboard
  Future<List<Map<String, dynamic>>> getTopPerformers({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/leaderboard/top-performers',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      return List<Map<String, dynamic>>.from(response.data['leaderboard']);
    } catch (e) {
      print('Error getting top performers: $e');
      return [];
    }
  }

  /// Get user's rank in leaderboard
  Future<int?> getUserRank(String userId) async {
    try {
      final response = await _api.get('/leaderboard/rank/$userId');

      return response.data['rank'] as int?;
    } catch (e) {
      print('Error getting user rank: $e');
      return null;
    }
  }

  /// Get weekly top performers
  Future<List<Map<String, dynamic>>> getWeeklyTopPerformers({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/leaderboard/weekly',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      return List<Map<String, dynamic>>.from(response.data['leaderboard']);
    } catch (e) {
      print('Error getting weekly top performers: $e');
      return [];
    }
  }

  /// Get top investors by follower count
  Future<List<Map<String, dynamic>>> getTopInvestorsByFollowers({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _api.get(
        '/leaderboard/top-investors',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      return List<Map<String, dynamic>>.from(response.data['topInvestors']);
    } catch (e) {
      print('Error getting top investors: $e');
      return [];
    }
  }
}
