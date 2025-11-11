import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user provider
final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final authState = await ref.watch(authStateProvider.future);

  if (authState == null) {
    yield null;
  } else {
    final databaseService = DatabaseService();
    final userModel = await databaseService.getUserById(authState.uid);
    yield userModel;
  }
});

// Auth notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userModel = await _databaseService.getUserById(user.uid);
      state = AsyncValue.data(userModel);
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      state = const AsyncValue.loading();

      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      if (user != null) {
        final userModel = await _databaseService.getUserById(user.uid);
        state = AsyncValue.data(userModel);
        return true;
      }

      state = const AsyncValue.data(null);
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();

      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        final userModel = await _databaseService.getUserById(user.uid);
        state = AsyncValue.data(userModel);
        return true;
      }

      state = const AsyncValue.data(null);
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        final userModel = await _databaseService.getUserById(user.uid);
        state = AsyncValue.data(userModel);
        return true;
      }

      state = const AsyncValue.data(null);
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? photoUrl,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      await _databaseService.updateUserProfile(
        userId: currentUser.uid,
        displayName: displayName,
        bio: bio,
        photoUrl: photoUrl,
      );

      final updatedUser = await _databaseService.getUserById(currentUser.uid);
      state = AsyncValue.data(updatedUser);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier();
});
