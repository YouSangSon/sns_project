import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Vault for storing sensitive API keys and secrets
class SecureVault {
  static final SecureVault _instance = SecureVault._internal();
  factory SecureVault() => _instance;

  SecureVault._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Key constants
  static const String _alphaVantageApiKey = 'alpha_vantage_api_key';
  static const String _coinGeckoApiKey = 'coingecko_api_key';
  static const String _finnhubApiKey = 'finnhub_api_key';
  static const String _polygonApiKey = 'polygon_api_key';
  static const String _newsApiKey = 'news_api_key';
  static const String _firebaseApiKey = 'firebase_api_key';
  static const String _supabaseKey = 'supabase_key';
  static const String _stripeKey = 'stripe_key';

  // ========== Alpha Vantage (Stock Data) ==========
  Future<void> setAlphaVantageApiKey(String key) async {
    await _storage.write(key: _alphaVantageApiKey, value: key);
  }

  Future<String?> getAlphaVantageApiKey() async {
    return await _storage.read(key: _alphaVantageApiKey);
  }

  // ========== CoinGecko (Crypto Data) ==========
  Future<void> setCoinGeckoApiKey(String key) async {
    await _storage.write(key: _coinGeckoApiKey, value: key);
  }

  Future<String?> getCoinGeckoApiKey() async {
    return await _storage.read(key: _coinGeckoApiKey);
  }

  // ========== Finnhub (Stock Data Alternative) ==========
  Future<void> setFinnhubApiKey(String key) async {
    await _storage.write(key: _finnhubApiKey, value: key);
  }

  Future<String?> getFinnhubApiKey() async {
    return await _storage.read(key: _finnhubApiKey);
  }

  // ========== Polygon.io (Stock & Crypto Data) ==========
  Future<void> setPolygonApiKey(String key) async {
    await _storage.write(key: _polygonApiKey, value: key);
  }

  Future<String?> getPolygonApiKey() async {
    return await _storage.read(key: _polygonApiKey);
  }

  // ========== News API ==========
  Future<void> setNewsApiKey(String key) async {
    await _storage.write(key: _newsApiKey, value: key);
  }

  Future<String?> getNewsApiKey() async {
    return await _storage.read(key: _newsApiKey);
  }

  // ========== Firebase API Key ==========
  Future<void> setFirebaseApiKey(String key) async {
    await _storage.write(key: _firebaseApiKey, value: key);
  }

  Future<String?> getFirebaseApiKey() async {
    return await _storage.read(key: _firebaseApiKey);
  }

  // ========== Supabase Key ==========
  Future<void> setSupabaseKey(String key) async {
    await _storage.write(key: _supabaseKey, value: key);
  }

  Future<String?> getSupabaseKey() async {
    return await _storage.read(key: _supabaseKey);
  }

  // ========== Stripe Key ==========
  Future<void> setStripeKey(String key) async {
    await _storage.write(key: _stripeKey, value: key);
  }

  Future<String?> getStripeKey() async {
    return await _storage.read(key: _stripeKey);
  }

  // ========== Generic Key Storage ==========
  Future<void> setKey(String keyName, String value) async {
    await _storage.write(key: keyName, value: value);
  }

  Future<String?> getKey(String keyName) async {
    return await _storage.read(key: keyName);
  }

  Future<void> deleteKey(String keyName) async {
    await _storage.delete(key: keyName);
  }

  // ========== Clear All Keys (Use with caution) ==========
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ========== Check if key exists ==========
  Future<bool> hasKey(String keyName) async {
    final value = await _storage.read(key: keyName);
    return value != null;
  }

  // ========== Initialization Helper ==========
  /// Initialize all API keys from environment or config
  /// This should be called once during app startup
  Future<void> initializeFromEnvironment({
    String? alphaVantageKey,
    String? coinGeckoKey,
    String? finnhubKey,
    String? polygonKey,
    String? newsApiKey,
  }) async {
    if (alphaVantageKey != null) {
      await setAlphaVantageApiKey(alphaVantageKey);
    }
    if (coinGeckoKey != null) {
      await setCoinGeckoApiKey(coinGeckoKey);
    }
    if (finnhubKey != null) {
      await setFinnhubApiKey(finnhubKey);
    }
    if (polygonKey != null) {
      await setPolygonApiKey(polygonKey);
    }
    if (newsApiKey != null) {
      await setNewsApiKey(newsApiKey);
    }
  }

  // ========== Debug: Get all keys (for development only) ==========
  Future<Map<String, String>> getAllKeys() async {
    final keys = await _storage.readAll();
    return keys;
  }
}
