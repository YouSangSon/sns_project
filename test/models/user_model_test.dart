import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sns_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel from map', () {
      // Arrange
      final map = {
        'uid': 'user123',
        'email': 'test@example.com',
        'username': 'testuser',
        'displayName': 'Test User',
        'bio': 'Test bio',
        'photoUrl': 'https://example.com/photo.jpg',
        'followersCount': 100,
        'followingCount': 50,
        'postsCount': 25,
        'createdAt': Timestamp.now(),
      };

      // Act
      final user = UserModel.fromMap(map);

      // Assert
      expect(user.uid, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.username, 'testuser');
      expect(user.displayName, 'Test User');
      expect(user.bio, 'Test bio');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
      expect(user.followersCount, 100);
      expect(user.followingCount, 50);
      expect(user.postsCount, 25);
    });

    test('should convert UserModel to map', () {
      // Arrange
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        bio: 'Test bio',
        photoUrl: 'https://example.com/photo.jpg',
        followersCount: 100,
        followingCount: 50,
        postsCount: 25,
        createdAt: DateTime.now(),
      );

      // Act
      final map = user.toMap();

      // Assert
      expect(map['uid'], 'user123');
      expect(map['email'], 'test@example.com');
      expect(map['username'], 'testuser');
      expect(map['displayName'], 'Test User');
      expect(map['bio'], 'Test bio');
      expect(map['photoUrl'], 'https://example.com/photo.jpg');
      expect(map['followersCount'], 100);
      expect(map['followingCount'], 50);
      expect(map['postsCount'], 25);
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('should create UserModel with default values', () {
      // Act
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        createdAt: DateTime.now(),
      );

      // Assert
      expect(user.bio, '');
      expect(user.photoUrl, '');
      expect(user.followersCount, 0);
      expect(user.followingCount, 0);
      expect(user.postsCount, 0);
    });

    test('should copy UserModel with new values', () {
      // Arrange
      final original = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        createdAt: DateTime.now(),
      );

      // Act
      final copied = original.copyWith(
        displayName: 'Updated User',
        bio: 'Updated bio',
      );

      // Assert
      expect(copied.uid, original.uid);
      expect(copied.email, original.email);
      expect(copied.username, original.username);
      expect(copied.displayName, 'Updated User');
      expect(copied.bio, 'Updated bio');
    });
  });
}
