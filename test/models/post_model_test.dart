import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sns_app/models/post_model.dart';

void main() {
  group('PostModel', () {
    test('should create PostModel from map', () {
      // Arrange
      final map = {
        'postId': 'post123',
        'userId': 'user123',
        'username': 'testuser',
        'userPhotoUrl': 'https://example.com/photo.jpg',
        'imageUrls': ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        'caption': 'Test caption #hashtag',
        'location': 'Test Location',
        'hashtags': ['hashtag'],
        'likes': 10,
        'comments': 5,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      // Act
      final post = PostModel.fromMap(map);

      // Assert
      expect(post.postId, 'post123');
      expect(post.userId, 'user123');
      expect(post.username, 'testuser');
      expect(post.imageUrls.length, 2);
      expect(post.caption, 'Test caption #hashtag');
      expect(post.location, 'Test Location');
      expect(post.hashtags, ['hashtag']);
      expect(post.likes, 10);
      expect(post.comments, 5);
    });

    test('should convert PostModel to map', () {
      // Arrange
      final post = PostModel(
        postId: 'post123',
        userId: 'user123',
        username: 'testuser',
        userPhotoUrl: 'https://example.com/photo.jpg',
        imageUrls: ['https://example.com/image1.jpg'],
        caption: 'Test caption',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final map = post.toMap();

      // Assert
      expect(map['postId'], 'post123');
      expect(map['userId'], 'user123');
      expect(map['username'], 'testuser');
      expect(map['imageUrls'], isA<List>());
      expect(map['caption'], 'Test caption');
    });

    test('should extract hashtags from caption', () {
      // Arrange
      const caption = 'Hello #world #flutter #dart';

      // Act
      final hashtags = PostModel.extractHashtags(caption);

      // Assert
      expect(hashtags.length, 3);
      expect(hashtags, contains('world'));
      expect(hashtags, contains('flutter'));
      expect(hashtags, contains('dart'));
    });

    test('should handle empty hashtags', () {
      // Arrange
      const caption = 'Hello world without hashtags';

      // Act
      final hashtags = PostModel.extractHashtags(caption);

      // Assert
      expect(hashtags.isEmpty, true);
    });

    test('should copy PostModel with new values', () {
      // Arrange
      final original = PostModel(
        postId: 'post123',
        userId: 'user123',
        username: 'testuser',
        userPhotoUrl: 'https://example.com/photo.jpg',
        imageUrls: ['https://example.com/image1.jpg'],
        caption: 'Original caption',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final copied = original.copyWith(
        caption: 'Updated caption',
        likes: 100,
      );

      // Assert
      expect(copied.postId, original.postId);
      expect(copied.caption, 'Updated caption');
      expect(copied.likes, 100);
    });
  });
}
