import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sns_app/features/auth/data/models/user_model.dart';
import 'package:sns_app/features/auth/domain/entities/user_entity.dart';

import '../../../../helpers/test_data.dart';

void main() {
  group('UserModel', () {
    final userModel = UserModel(
      id: TestData.testUserId,
      email: TestData.testEmail,
      username: TestData.testUsername,
      displayName: TestData.testDisplayName,
      bio: TestData.testBio,
      profileImageUrl: TestData.testProfileImage,
      followersCount: 100,
      followingCount: 50,
      postsCount: 25,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

    test('fromJson으로 올바르게 파싱되어야 한다', () {
      // Arrange
      final jsonMap = TestData.mockUserJson;

      // Act
      final result = UserModel.fromJson(jsonMap);

      // Assert
      expect(result.id, TestData.testUserId);
      expect(result.email, TestData.testEmail);
      expect(result.username, TestData.testUsername);
      expect(result.displayName, TestData.testDisplayName);
      expect(result.bio, TestData.testBio);
      expect(result.profileImageUrl, TestData.testProfileImage);
      expect(result.followersCount, 100);
      expect(result.followingCount, 50);
      expect(result.postsCount, 25);
    });

    test('toJson으로 올바르게 직렬화되어야 한다', () {
      // Act
      final jsonMap = userModel.toJson();

      // Assert
      expect(jsonMap['id'], TestData.testUserId);
      expect(jsonMap['email'], TestData.testEmail);
      expect(jsonMap['user_name'], TestData.testUsername);
      expect(jsonMap['display_name'], TestData.testDisplayName);
      expect(jsonMap['bio'], TestData.testBio);
      expect(jsonMap['profile_image_url'], TestData.testProfileImage);
      expect(jsonMap['followers_count'], 100);
      expect(jsonMap['following_count'], 50);
      expect(jsonMap['posts_count'], 25);
    });

    test('toEntity로 UserEntity로 변환되어야 한다', () {
      // Act
      final entity = userModel.toEntity();

      // Assert
      expect(entity, isA<UserEntity>());
      expect(entity.id, userModel.id);
      expect(entity.email, userModel.email);
      expect(entity.username, userModel.username);
      expect(entity.displayName, userModel.displayName);
    });

    test('JSON 직렬화/역직렬화가 일관성 있게 동작해야 한다', () {
      // Arrange
      final jsonString = jsonEncode(userModel.toJson());

      // Act
      final decoded = UserModel.fromJson(jsonDecode(jsonString));

      // Assert
      expect(decoded.id, userModel.id);
      expect(decoded.email, userModel.email);
      expect(decoded.username, userModel.username);
    });
  });
}
