import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_provider.freezed.dart';

/// 인증 상태
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

/// 인증 Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _repository;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository repository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _repository = repository,
        super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  /// 초기 인증 상태 확인
  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      final result = await _repository.getCurrentUser();
      result.fold(
        (failure) => state = const AuthState.unauthenticated(),
        (user) => state = AuthState.authenticated(user),
      );
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  /// 로그인
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) => state = AuthState.error(failure.errorMessage),
      (data) => state = AuthState.authenticated(data.$1),
    );
  }

  /// 회원가입
  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String name,
  }) async {
    state = const AuthState.loading();

    final result = await _registerUseCase(
      email: email,
      password: password,
      username: username,
      name: name,
    );

    result.fold(
      (failure) => state = AuthState.error(failure.errorMessage),
      (data) => state = AuthState.authenticated(data.$1),
    );
  }

  /// 로그아웃
  Future<void> logout() async {
    state = const AuthState.loading();
    await _logoutUseCase();
    state = const AuthState.unauthenticated();
  }

  /// 사용자 정보 새로고침
  Future<void> refreshUser() async {
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) {},
      (user) => state = AuthState.authenticated(user),
    );
  }
}
