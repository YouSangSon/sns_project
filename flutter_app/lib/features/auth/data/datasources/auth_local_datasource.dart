import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// 인증 로컬 데이터소스 인터페이스
abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> saveUser(UserModel user);

  Future<UserModel?> getUser();

  Future<void> clearAll();
}

/// 인증 로컬 데이터소스 구현
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: AppConfig.accessTokenKey, value: accessToken),
        _storage.write(key: AppConfig.refreshTokenKey, value: refreshToken),
      ]);
    } catch (e) {
      throw CacheException('토큰 저장 실패: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConfig.accessTokenKey);
    } catch (e) {
      throw CacheException('토큰 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConfig.refreshTokenKey);
    } catch (e) {
      throw CacheException('토큰 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await _storage.write(key: AppConfig.userDataKey, value: jsonString);
    } catch (e) {
      throw CacheException('사용자 정보 저장 실패: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final jsonString = await _storage.read(key: AppConfig.userDataKey);
      if (jsonString == null) return null;
      return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _storage.delete(key: AppConfig.accessTokenKey),
        _storage.delete(key: AppConfig.refreshTokenKey),
        _storage.delete(key: AppConfig.userDataKey),
      ]);
    } catch (e) {
      throw CacheException('캐시 삭제 실패: ${e.toString()}');
    }
  }
}
