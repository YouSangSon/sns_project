import 'package:cloud_firestore/cloud_firestore.dart';
import 'asset_holding.dart';

/// Investment Post Type
enum InvestmentPostType {
  idea, // 투자 아이디어
  performance, // 수익률 성과 공유
  trade, // 거래 내역 공유
  analysis, // 시장 분석
  question, // 질문
  news, // 뉴스/정보 공유
  portfolio, // 포트폴리오 공유
}

extension InvestmentPostTypeExtension on InvestmentPostType {
  String get name {
    switch (this) {
      case InvestmentPostType.idea:
        return 'Idea';
      case InvestmentPostType.performance:
        return 'Performance';
      case InvestmentPostType.trade:
        return 'Trade';
      case InvestmentPostType.analysis:
        return 'Analysis';
      case InvestmentPostType.question:
        return 'Question';
      case InvestmentPostType.news:
        return 'News';
      case InvestmentPostType.portfolio:
        return 'Portfolio';
    }
  }

  String get koreanName {
    switch (this) {
      case InvestmentPostType.idea:
        return '투자 아이디어';
      case InvestmentPostType.performance:
        return '수익 인증';
      case InvestmentPostType.trade:
        return '매매 내역';
      case InvestmentPostType.analysis:
        return '시장 분석';
      case InvestmentPostType.question:
        return '질문';
      case InvestmentPostType.news:
        return '뉴스';
      case InvestmentPostType.portfolio:
        return '포트폴리오';
    }
  }

  static InvestmentPostType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'idea':
        return InvestmentPostType.idea;
      case 'performance':
        return InvestmentPostType.performance;
      case 'trade':
        return InvestmentPostType.trade;
      case 'analysis':
        return InvestmentPostType.analysis;
      case 'question':
        return InvestmentPostType.question;
      case 'news':
        return InvestmentPostType.news;
      case 'portfolio':
        return InvestmentPostType.portfolio;
      default:
        return InvestmentPostType.idea;
    }
  }
}

/// Market Sentiment
enum MarketSentiment {
  bullish, // 강세 (낙관적)
  bearish, // 약세 (비관적)
  neutral, // 중립
}

extension MarketSentimentExtension on MarketSentiment {
  String get emoji {
    switch (this) {
      case MarketSentiment.bullish:
        return '🐂';
      case MarketSentiment.bearish:
        return '🐻';
      case MarketSentiment.neutral:
        return '😐';
    }
  }

  String get name {
    switch (this) {
      case MarketSentiment.bullish:
        return 'Bullish';
      case MarketSentiment.bearish:
        return 'Bearish';
      case MarketSentiment.neutral:
        return 'Neutral';
    }
  }

  String get koreanName {
    switch (this) {
      case MarketSentiment.bullish:
        return '강세';
      case MarketSentiment.bearish:
        return '약세';
      case MarketSentiment.neutral:
        return '중립';
    }
  }

  static MarketSentiment fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bullish':
        return MarketSentiment.bullish;
      case 'bearish':
        return MarketSentiment.bearish;
      default:
        return MarketSentiment.neutral;
    }
  }
}

/// Investment Post Model
class InvestmentPost {
  final String postId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final InvestmentPostType postType;
  final String content;
  final List<String> relatedAssets; // Asset symbols mentioned
  final String? attachedPortfolioId; // Reference to portfolio if sharing performance
  final Map<String, dynamic>? performanceData; // Return %, gain/loss, etc.
  final List<String> imageUrls; // Screenshots, charts
  final MarketSentiment? sentiment;
  final double? targetPrice; // For investment ideas
  final String? timeHorizon; // short/medium/long term
  final List<String> hashtags;
  final int likes;
  final int comments;
  final int bookmarks;
  final int bullishCount; // Users who agree (bullish)
  final int bearishCount; // Users who disagree (bearish)
  final DateTime createdAt;
  final DateTime updatedAt;

  InvestmentPost({
    required this.postId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.postType,
    required this.content,
    this.relatedAssets = const [],
    this.attachedPortfolioId,
    this.performanceData,
    this.imageUrls = const [],
    this.sentiment,
    this.targetPrice,
    this.timeHorizon,
    this.hashtags = const [],
    this.likes = 0,
    this.comments = 0,
    this.bookmarks = 0,
    this.bullishCount = 0,
    this.bearishCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate sentiment ratio
  double get bullishRatio {
    final total = bullishCount + bearishCount;
    return total > 0 ? (bullishCount / total) * 100 : 0;
  }

  double get bearishRatio {
    final total = bullishCount + bearishCount;
    return total > 0 ? (bearishCount / total) * 100 : 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'postType': postType.toString().split('.').last,
      'content': content,
      'relatedAssets': relatedAssets,
      'attachedPortfolioId': attachedPortfolioId,
      'performanceData': performanceData,
      'imageUrls': imageUrls,
      'sentiment': sentiment?.toString().split('.').last,
      'targetPrice': targetPrice,
      'timeHorizon': timeHorizon,
      'hashtags': hashtags,
      'likes': likes,
      'comments': comments,
      'bookmarks': bookmarks,
      'bullishCount': bullishCount,
      'bearishCount': bearishCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory InvestmentPost.fromMap(Map<String, dynamic> map) {
    return InvestmentPost(
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      postType: InvestmentPostTypeExtension.fromString(map['postType'] ?? 'idea'),
      content: map['content'] ?? '',
      relatedAssets: List<String>.from(map['relatedAssets'] ?? []),
      attachedPortfolioId: map['attachedPortfolioId'],
      performanceData: map['performanceData'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      sentiment: map['sentiment'] != null
          ? MarketSentimentExtension.fromString(map['sentiment'])
          : null,
      targetPrice: map['targetPrice']?.toDouble(),
      timeHorizon: map['timeHorizon'],
      hashtags: List<String>.from(map['hashtags'] ?? []),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      bookmarks: map['bookmarks'] ?? 0,
      bullishCount: map['bullishCount'] ?? 0,
      bearishCount: map['bearishCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory InvestmentPost.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvestmentPost.fromMap({
      ...data,
      'postId': doc.id,
    });
  }

  InvestmentPost copyWith({
    String? postId,
    String? userId,
    String? username,
    String? userPhotoUrl,
    InvestmentPostType? postType,
    String? content,
    List<String>? relatedAssets,
    String? attachedPortfolioId,
    Map<String, dynamic>? performanceData,
    List<String>? imageUrls,
    MarketSentiment? sentiment,
    double? targetPrice,
    String? timeHorizon,
    List<String>? hashtags,
    int? likes,
    int? comments,
    int? bookmarks,
    int? bullishCount,
    int? bearishCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentPost(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      postType: postType ?? this.postType,
      content: content ?? this.content,
      relatedAssets: relatedAssets ?? this.relatedAssets,
      attachedPortfolioId: attachedPortfolioId ?? this.attachedPortfolioId,
      performanceData: performanceData ?? this.performanceData,
      imageUrls: imageUrls ?? this.imageUrls,
      sentiment: sentiment ?? this.sentiment,
      targetPrice: targetPrice ?? this.targetPrice,
      timeHorizon: timeHorizon ?? this.timeHorizon,
      hashtags: hashtags ?? this.hashtags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      bookmarks: bookmarks ?? this.bookmarks,
      bullishCount: bullishCount ?? this.bullishCount,
      bearishCount: bearishCount ?? this.bearishCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
