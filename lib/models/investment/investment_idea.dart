import 'package:cloud_firestore/cloud_firestore.dart';
import 'asset_holding.dart';

/// Investment Idea Status
enum IdeaStatus {
  active, // Currently tracking
  successful, // Target reached
  failed, // Stop loss hit or thesis invalidated
  closed, // Manually closed
}

extension IdeaStatusExtension on IdeaStatus {
  String get name {
    switch (this) {
      case IdeaStatus.active:
        return 'Active';
      case IdeaStatus.successful:
        return 'Successful';
      case IdeaStatus.failed:
        return 'Failed';
      case IdeaStatus.closed:
        return 'Closed';
    }
  }

  String get koreanName {
    switch (this) {
      case IdeaStatus.active:
        return '진행중';
      case IdeaStatus.successful:
        return '성공';
      case IdeaStatus.failed:
        return '실패';
      case IdeaStatus.closed:
        return '종료';
    }
  }

  static IdeaStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return IdeaStatus.active;
      case 'successful':
        return IdeaStatus.successful;
      case 'failed':
        return IdeaStatus.failed;
      case 'closed':
        return IdeaStatus.closed;
      default:
        return IdeaStatus.active;
    }
  }
}

/// Time Horizon for investment
enum TimeHorizon {
  shortTerm, // < 3 months
  mediumTerm, // 3-12 months
  longTerm, // > 12 months
}

extension TimeHorizonExtension on TimeHorizon {
  String get name {
    switch (this) {
      case TimeHorizon.shortTerm:
        return 'Short Term';
      case TimeHorizon.mediumTerm:
        return 'Medium Term';
      case TimeHorizon.longTerm:
        return 'Long Term';
    }
  }

  String get koreanName {
    switch (this) {
      case TimeHorizon.shortTerm:
        return '단기';
      case TimeHorizon.mediumTerm:
        return '중기';
      case TimeHorizon.longTerm:
        return '장기';
    }
  }

  static TimeHorizon fromString(String value) {
    switch (value.toLowerCase()) {
      case 'shortterm':
      case 'short_term':
        return TimeHorizon.shortTerm;
      case 'mediumterm':
      case 'medium_term':
        return TimeHorizon.mediumTerm;
      case 'longterm':
      case 'long_term':
        return TimeHorizon.longTerm;
      default:
        return TimeHorizon.mediumTerm;
    }
  }
}

/// Investment Idea Model - Share investment thesis and track results
class InvestmentIdea {
  final String ideaId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String assetSymbol;
  final String assetName;
  final AssetType assetType;
  final double entryPrice; // Suggested entry price
  final double? currentPrice; // Current market price
  final double targetPrice; // Price target
  final double? stopLoss; // Stop loss price
  final String thesis; // Investment thesis/reasoning
  final List<String> catalysts; // Key catalysts/events
  final List<String> riskFactors; // Risk factors
  final TimeHorizon timeHorizon;
  final IdeaStatus status;
  final DateTime? achievedDate; // When target was reached
  final double? actualReturn; // Actual return if traded
  final int likes;
  final int followers; // Users following this idea
  final int commentsCount;
  final List<String> imageUrls; // Charts, analysis images
  final DateTime createdAt;
  final DateTime updatedAt;

  InvestmentIdea({
    required this.ideaId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.assetSymbol,
    required this.assetName,
    required this.assetType,
    required this.entryPrice,
    this.currentPrice,
    required this.targetPrice,
    this.stopLoss,
    required this.thesis,
    this.catalysts = const [],
    this.riskFactors = const [],
    required this.timeHorizon,
    this.status = IdeaStatus.active,
    this.achievedDate,
    this.actualReturn,
    this.likes = 0,
    this.followers = 0,
    this.commentsCount = 0,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate potential return
  double get potentialReturn {
    if (entryPrice > 0) {
      return ((targetPrice - entryPrice) / entryPrice) * 100;
    }
    return 0;
  }

  // Calculate current return (if currentPrice is available)
  double? get currentReturn {
    if (currentPrice != null && entryPrice > 0) {
      return ((currentPrice! - entryPrice) / entryPrice) * 100;
    }
    return null;
  }

  // Calculate risk/reward ratio
  double? get riskRewardRatio {
    if (stopLoss != null && entryPrice > 0) {
      final risk = entryPrice - stopLoss!;
      final reward = targetPrice - entryPrice;
      if (risk > 0) {
        return reward / risk;
      }
    }
    return null;
  }

  bool get isActive => status == IdeaStatus.active;
  bool get isSuccessful => status == IdeaStatus.successful;
  bool get isFailed => status == IdeaStatus.failed;

  Map<String, dynamic> toMap() {
    return {
      'ideaId': ideaId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'assetSymbol': assetSymbol,
      'assetName': assetName,
      'assetType': assetType.toString().split('.').last,
      'entryPrice': entryPrice,
      'currentPrice': currentPrice,
      'targetPrice': targetPrice,
      'stopLoss': stopLoss,
      'thesis': thesis,
      'catalysts': catalysts,
      'riskFactors': riskFactors,
      'timeHorizon': timeHorizon.toString().split('.').last,
      'status': status.toString().split('.').last,
      'achievedDate': achievedDate != null ? Timestamp.fromDate(achievedDate!) : null,
      'actualReturn': actualReturn,
      'likes': likes,
      'followers': followers,
      'commentsCount': commentsCount,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory InvestmentIdea.fromMap(Map<String, dynamic> map) {
    return InvestmentIdea(
      ideaId: map['ideaId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      assetSymbol: map['assetSymbol'] ?? '',
      assetName: map['assetName'] ?? '',
      assetType: AssetTypeExtension.fromString(map['assetType'] ?? 'other'),
      entryPrice: (map['entryPrice'] ?? 0).toDouble(),
      currentPrice: map['currentPrice']?.toDouble(),
      targetPrice: (map['targetPrice'] ?? 0).toDouble(),
      stopLoss: map['stopLoss']?.toDouble(),
      thesis: map['thesis'] ?? '',
      catalysts: List<String>.from(map['catalysts'] ?? []),
      riskFactors: List<String>.from(map['riskFactors'] ?? []),
      timeHorizon: TimeHorizonExtension.fromString(map['timeHorizon'] ?? 'mediumterm'),
      status: IdeaStatusExtension.fromString(map['status'] ?? 'active'),
      achievedDate: map['achievedDate'] != null
          ? (map['achievedDate'] as Timestamp).toDate()
          : null,
      actualReturn: map['actualReturn']?.toDouble(),
      likes: map['likes'] ?? 0,
      followers: map['followers'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory InvestmentIdea.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvestmentIdea.fromMap({
      ...data,
      'ideaId': doc.id,
    });
  }

  InvestmentIdea copyWith({
    String? ideaId,
    String? userId,
    String? username,
    String? userPhotoUrl,
    String? assetSymbol,
    String? assetName,
    AssetType? assetType,
    double? entryPrice,
    double? currentPrice,
    double? targetPrice,
    double? stopLoss,
    String? thesis,
    List<String>? catalysts,
    List<String>? riskFactors,
    TimeHorizon? timeHorizon,
    IdeaStatus? status,
    DateTime? achievedDate,
    double? actualReturn,
    int? likes,
    int? followers,
    int? commentsCount,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentIdea(
      ideaId: ideaId ?? this.ideaId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      assetSymbol: assetSymbol ?? this.assetSymbol,
      assetName: assetName ?? this.assetName,
      assetType: assetType ?? this.assetType,
      entryPrice: entryPrice ?? this.entryPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      targetPrice: targetPrice ?? this.targetPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      thesis: thesis ?? this.thesis,
      catalysts: catalysts ?? this.catalysts,
      riskFactors: riskFactors ?? this.riskFactors,
      timeHorizon: timeHorizon ?? this.timeHorizon,
      status: status ?? this.status,
      achievedDate: achievedDate ?? this.achievedDate,
      actualReturn: actualReturn ?? this.actualReturn,
      likes: likes ?? this.likes,
      followers: followers ?? this.followers,
      commentsCount: commentsCount ?? this.commentsCount,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
