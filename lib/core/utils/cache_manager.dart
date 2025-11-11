import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Generic cache manager for app data
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get cached data
  Future<T?> get<T>(String key) async {
    try {
      final data = _prefs?.getString(key);
      if (data == null) return null;

      final decoded = jsonDecode(data);

      // Check expiration
      if (decoded['expiry'] != null) {
        final expiry = DateTime.parse(decoded['expiry']);
        if (DateTime.now().isAfter(expiry)) {
          await remove(key);
          return null;
        }
      }

      return decoded['data'] as T;
    } catch (e) {
      print('Error getting cached data: $e');
      return null;
    }
  }

  /// Set cache data with optional expiration
  Future<bool> set<T>(
    String key,
    T data, {
    Duration? expiry,
  }) async {
    try {
      final cacheData = {
        'data': data,
        'expiry': expiry != null
            ? DateTime.now().add(expiry).toIso8601String()
            : null,
      };

      return await _prefs?.setString(key, jsonEncode(cacheData)) ?? false;
    } catch (e) {
      print('Error setting cache data: $e');
      return false;
    }
  }

  /// Remove cached data
  Future<bool> remove(String key) async {
    try {
      return await _prefs?.remove(key) ?? false;
    } catch (e) {
      print('Error removing cache data: $e');
      return false;
    }
  }

  /// Clear all cache
  Future<bool> clearAll() async {
    try {
      return await _prefs?.clear() ?? false;
    } catch (e) {
      print('Error clearing cache: $e');
      return false;
    }
  }

  /// Check if key exists
  bool has(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// Get all keys
  Set<String> get keys {
    return _prefs?.getKeys() ?? {};
  }
}

/// In-memory cache for frequently accessed data
class MemoryCache<K, V> {
  final Map<K, _CacheEntry<V>> _cache = {};
  final int maxSize;
  final Duration? defaultExpiry;

  MemoryCache({
    this.maxSize = 100,
    this.defaultExpiry,
  });

  /// Get value from cache
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check expiration
    if (entry.expiry != null && DateTime.now().isAfter(entry.expiry!)) {
      _cache.remove(key);
      return null;
    }

    // Update access time for LRU
    entry.lastAccessed = DateTime.now();
    return entry.value;
  }

  /// Set value in cache
  void set(K key, V value, {Duration? expiry}) {
    // Remove oldest entry if cache is full
    if (_cache.length >= maxSize && !_cache.containsKey(key)) {
      _removeOldest();
    }

    final expiryTime = expiry ?? defaultExpiry;
    _cache[key] = _CacheEntry(
      value: value,
      expiry: expiryTime != null ? DateTime.now().add(expiryTime) : null,
      lastAccessed: DateTime.now(),
    );
  }

  /// Remove value from cache
  void remove(K key) {
    _cache.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
  }

  /// Check if key exists
  bool has(K key) {
    final entry = _cache[key];
    if (entry == null) return false;

    // Check expiration
    if (entry.expiry != null && DateTime.now().isAfter(entry.expiry!)) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Get all keys
  Iterable<K> get keys => _cache.keys;

  /// Get cache size
  int get size => _cache.length;

  /// Remove oldest entry (LRU)
  void _removeOldest() {
    if (_cache.isEmpty) return;

    K? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null ||
          entry.value.lastAccessed.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.lastAccessed;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }
}

class _CacheEntry<V> {
  final V value;
  final DateTime? expiry;
  DateTime lastAccessed;

  _CacheEntry({
    required this.value,
    this.expiry,
    required this.lastAccessed,
  });
}

/// Cache keys constants
class CacheKeys {
  static const String userProfile = 'user_profile_';
  static const String posts = 'posts_';
  static const String feed = 'feed';
  static const String stories = 'stories';
  static const String notifications = 'notifications';
  static const String messages = 'messages_';
  static const String reels = 'reels';
  static const String liveStreams = 'live_streams';
  static const String products = 'products';

  static String userProfileKey(String userId) => '$userProfile$userId';
  static String postsKey(String userId) => '$posts$userId';
  static String messagesKey(String chatId) => '$messages$chatId';
}
