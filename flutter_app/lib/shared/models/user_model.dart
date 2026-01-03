import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String userId;
  final String username;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.userId,
    required this.username,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? json['uid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'],
      bio: json['bio'],
      followerCount: json['followerCount'] ?? json['followers'] ?? 0,
      followingCount: json['followingCount'] ?? json['following'] ?? 0,
      postCount: json['postCount'] ?? json['posts'] ?? 0,
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
      'userId': userId,
      'username': username,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? userId,
    String? username,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    int? followerCount,
    int? followingCount,
    int? postCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount ?? this.postCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Dev user for testing
  static User get devUser => User(
        userId: 'dev-user-001',
        username: 'devuser',
        email: 'dev@example.com',
        displayName: 'Dev User',
        photoUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=dev',
        bio: '개발 환경 테스트 유저입니다',
        followerCount: 150,
        followingCount: 200,
        postCount: 42,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime.now(),
      );

  @override
  List<Object?> get props => [
        userId,
        username,
        email,
        displayName,
        photoUrl,
        bio,
        followerCount,
        followingCount,
        postCount,
        createdAt,
        updatedAt,
      ];
}
