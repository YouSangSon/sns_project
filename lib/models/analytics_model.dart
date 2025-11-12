import 'package:cloud_firestore/cloud_firestore.dart';

class UserAnalytics {
  final String userId;
  final int totalPosts;
  final int totalLikes;
  final int totalComments;
  final int totalViews;
  final int followersCount;
  final int followingCount;
  final int profileViews;
  final Map<String, int> dailyStats; // date -> engagement count
  final Map<String, int> topHashtags; // hashtag -> usage count
  final DateTime updatedAt;

  UserAnalytics({
    required this.userId,
    this.totalPosts = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalViews = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.profileViews = 0,
    this.dailyStats = const {},
    this.topHashtags = const {},
    required this.updatedAt,
  });

  factory UserAnalytics.fromMap(Map<String, dynamic> map) {
    return UserAnalytics(
      userId: map['userId'] ?? '',
      totalPosts: map['totalPosts'] ?? 0,
      totalLikes: map['totalLikes'] ?? 0,
      totalComments: map['totalComments'] ?? 0,
      totalViews: map['totalViews'] ?? 0,
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      profileViews: map['profileViews'] ?? 0,
      dailyStats: Map<String, int>.from(map['dailyStats'] ?? {}),
      topHashtags: Map<String, int>.from(map['topHashtags'] ?? {}),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPosts': totalPosts,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'totalViews': totalViews,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'profileViews': profileViews,
      'dailyStats': dailyStats,
      'topHashtags': topHashtags,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Calculate engagement rate
  double get engagementRate {
    if (followersCount == 0) return 0.0;
    final totalEngagement = totalLikes + totalComments;
    return (totalEngagement / (followersCount * totalPosts)) * 100;
  }

  // Get average likes per post
  double get averageLikesPerPost {
    if (totalPosts == 0) return 0.0;
    return totalLikes / totalPosts;
  }

  // Get average comments per post
  double get averageCommentsPerPost {
    if (totalPosts == 0) return 0.0;
    return totalComments / totalPosts;
  }
}

class PostAnalytics {
  final String postId;
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final int views;
  final Map<String, int> dailyViews; // date -> view count
  final Map<String, int> demographicData; // age/country -> count
  final DateTime createdAt;
  final DateTime updatedAt;

  PostAnalytics({
    required this.postId,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.views = 0,
    this.dailyViews = const {},
    this.demographicData = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostAnalytics.fromMap(Map<String, dynamic> map) {
    return PostAnalytics(
      postId: map['postId'] ?? '',
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      shares: map['shares'] ?? 0,
      saves: map['saves'] ?? 0,
      views: map['views'] ?? 0,
      dailyViews: Map<String, int>.from(map['dailyViews'] ?? {}),
      demographicData: Map<String, int>.from(map['demographicData'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'saves': saves,
      'views': views,
      'dailyViews': dailyViews,
      'demographicData': demographicData,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Get total engagement
  int get totalEngagement => likes + comments + shares + saves;

  // Get engagement rate
  double get engagementRate {
    if (views == 0) return 0.0;
    return (totalEngagement / views) * 100;
  }
}

class GrowthMetrics {
  final DateTime date;
  final int followersGained;
  final int followersLost;
  final int postsCreated;
  final int totalLikes;
  final int totalComments;
  final int profileViews;

  GrowthMetrics({
    required this.date,
    this.followersGained = 0,
    this.followersLost = 0,
    this.postsCreated = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.profileViews = 0,
  });

  int get netFollowerGrowth => followersGained - followersLost;

  factory GrowthMetrics.fromMap(Map<String, dynamic> map) {
    return GrowthMetrics(
      date: (map['date'] as Timestamp).toDate(),
      followersGained: map['followersGained'] ?? 0,
      followersLost: map['followersLost'] ?? 0,
      postsCreated: map['postsCreated'] ?? 0,
      totalLikes: map['totalLikes'] ?? 0,
      totalComments: map['totalComments'] ?? 0,
      profileViews: map['profileViews'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'followersGained': followersGained,
      'followersLost': followersLost,
      'postsCreated': postsCreated,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'profileViews': profileViews,
    };
  }
}
