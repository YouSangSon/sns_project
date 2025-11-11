import 'package:flutter_test/flutter_test.dart';
import 'package:sns_app/core/utils/cache_manager.dart';

void main() {
  group('MemoryCache', () {
    late MemoryCache<String, int> cache;

    setUp(() {
      cache = MemoryCache<String, int>(maxSize: 3);
    });

    test('should store and retrieve values', () {
      // Arrange & Act
      cache.set('key1', 100);

      // Assert
      expect(cache.get('key1'), 100);
      expect(cache.has('key1'), true);
    });

    test('should return null for non-existent keys', () {
      // Act
      final value = cache.get('nonexistent');

      // Assert
      expect(value, null);
      expect(cache.has('nonexistent'), false);
    });

    test('should update existing values', () {
      // Arrange
      cache.set('key1', 100);

      // Act
      cache.set('key1', 200);

      // Assert
      expect(cache.get('key1'), 200);
    });

    test('should remove values', () {
      // Arrange
      cache.set('key1', 100);

      // Act
      cache.remove('key1');

      // Assert
      expect(cache.get('key1'), null);
      expect(cache.has('key1'), false);
    });

    test('should clear all values', () {
      // Arrange
      cache.set('key1', 100);
      cache.set('key2', 200);
      cache.set('key3', 300);

      // Act
      cache.clear();

      // Assert
      expect(cache.get('key1'), null);
      expect(cache.get('key2'), null);
      expect(cache.get('key3'), null);
      expect(cache.size, 0);
    });

    test('should respect max size and evict oldest entry', () {
      // Arrange & Act
      cache.set('key1', 100);
      cache.set('key2', 200);
      cache.set('key3', 300);

      // Cache is full, adding new entry should evict oldest
      cache.set('key4', 400);

      // Assert
      expect(cache.size, 3);
      expect(cache.has('key1'), false); // Oldest should be evicted
      expect(cache.has('key2'), true);
      expect(cache.has('key3'), true);
      expect(cache.has('key4'), true);
    });

    test('should handle expiration', () async {
      // Arrange
      cache.set('key1', 100, expiry: const Duration(milliseconds: 100));

      // Assert - should exist initially
      expect(cache.has('key1'), true);
      expect(cache.get('key1'), 100);

      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 150));

      // Assert - should be expired
      expect(cache.has('key1'), false);
      expect(cache.get('key1'), null);
    });

    test('should provide all keys', () {
      // Arrange
      cache.set('key1', 100);
      cache.set('key2', 200);
      cache.set('key3', 300);

      // Act
      final keys = cache.keys.toList();

      // Assert
      expect(keys.length, 3);
      expect(keys, contains('key1'));
      expect(keys, contains('key2'));
      expect(keys, contains('key3'));
    });

    test('should update access time on get (LRU)', () {
      // Arrange
      cache.set('key1', 100);
      cache.set('key2', 200);
      cache.set('key3', 300);

      // Access key1 to make it most recently used
      cache.get('key1');

      // Add new item, should evict key2 (oldest)
      cache.set('key4', 400);

      // Assert
      expect(cache.has('key1'), true); // Was accessed, should remain
      expect(cache.has('key2'), false); // Oldest, should be evicted
      expect(cache.has('key3'), true);
      expect(cache.has('key4'), true);
    });

    test('should work with different value types', () {
      // Arrange
      final stringCache = MemoryCache<String, String>();
      final listCache = MemoryCache<String, List<int>>();
      final mapCache = MemoryCache<String, Map<String, dynamic>>();

      // Act & Assert
      stringCache.set('key', 'value');
      expect(stringCache.get('key'), 'value');

      listCache.set('key', [1, 2, 3]);
      expect(listCache.get('key'), [1, 2, 3]);

      mapCache.set('key', {'nested': 'value'});
      expect(mapCache.get('key'), {'nested': 'value'});
    });
  });

  group('CacheKeys', () {
    test('should generate correct user profile key', () {
      // Act
      final key = CacheKeys.userProfileKey('user123');

      // Assert
      expect(key, 'user_profile_user123');
    });

    test('should generate correct posts key', () {
      // Act
      final key = CacheKeys.postsKey('user456');

      // Assert
      expect(key, 'posts_user456');
    });

    test('should generate correct messages key', () {
      // Act
      final key = CacheKeys.messagesKey('chat789');

      // Assert
      expect(key, 'messages_chat789');
    });
  });
}
