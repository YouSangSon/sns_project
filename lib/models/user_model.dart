import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String displayName;
  final String photoUrl;
  final String bio;
  final int followers;
  final int following;
  final int posts;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    this.photoUrl = '',
    this.bio = '',
    this.followers = 0,
    this.following = 0,
    this.posts = 0,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'followers': followers,
      'following': following,
      'posts': posts,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      bio: map['bio'] ?? '',
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      posts: map['posts'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create from DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  // CopyWith method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? displayName,
    String? photoUrl,
    String? bio,
    int? followers,
    int? following,
    int? posts,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      posts: posts ?? this.posts,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
