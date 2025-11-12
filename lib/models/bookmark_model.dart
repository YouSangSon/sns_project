import 'package:cloud_firestore/cloud_firestore.dart';

enum BookmarkType {
  post,
  investmentPost,
  reel,
}

extension BookmarkTypeExtension on BookmarkType {
  String get name {
    switch (this) {
      case BookmarkType.post:
        return 'post';
      case BookmarkType.investmentPost:
        return 'investment_post';
      case BookmarkType.reel:
        return 'reel';
    }
  }

  static BookmarkType fromString(String value) {
    switch (value) {
      case 'post':
        return BookmarkType.post;
      case 'investment_post':
        return BookmarkType.investmentPost;
      case 'reel':
        return BookmarkType.reel;
      default:
        return BookmarkType.post;
    }
  }
}

class BookmarkModel {
  final String bookmarkId;
  final String userId;
  final String contentId; // postId, investmentPostId, reelId
  final BookmarkType type;
  final DateTime createdAt;

  // Cached content info for display
  final String? contentPreview;
  final String? contentImageUrl;
  final String? authorUsername;
  final String? authorPhotoUrl;

  BookmarkModel({
    required this.bookmarkId,
    required this.userId,
    required this.contentId,
    required this.type,
    required this.createdAt,
    this.contentPreview,
    this.contentImageUrl,
    this.authorUsername,
    this.authorPhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookmarkId': bookmarkId,
      'userId': userId,
      'contentId': contentId,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'contentPreview': contentPreview,
      'contentImageUrl': contentImageUrl,
      'authorUsername': authorUsername,
      'authorPhotoUrl': authorPhotoUrl,
    };
  }

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      bookmarkId: map['bookmarkId'] ?? '',
      userId: map['userId'] ?? '',
      contentId: map['contentId'] ?? '',
      type: BookmarkTypeExtension.fromString(map['type'] ?? 'post'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      contentPreview: map['contentPreview'],
      contentImageUrl: map['contentImageUrl'],
      authorUsername: map['authorUsername'],
      authorPhotoUrl: map['authorPhotoUrl'],
    );
  }

  factory BookmarkModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookmarkModel.fromMap({
      ...data,
      'bookmarkId': doc.id,
    });
  }

  BookmarkModel copyWith({
    String? bookmarkId,
    String? userId,
    String? contentId,
    BookmarkType? type,
    DateTime? createdAt,
    String? contentPreview,
    String? contentImageUrl,
    String? authorUsername,
    String? authorPhotoUrl,
  }) {
    return BookmarkModel(
      bookmarkId: bookmarkId ?? this.bookmarkId,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      contentPreview: contentPreview ?? this.contentPreview,
      contentImageUrl: contentImageUrl ?? this.contentImageUrl,
      authorUsername: authorUsername ?? this.authorUsername,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
    );
  }
}
