import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../api/api_client.dart';
import '../cats/cats_provider.dart';
import '../../services/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, UserProfile? user, String? error}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    ApiClient.onUnauthorized = () {
      _ref.read(catsProvider.notifier).clear();
      state = const AuthState(status: AuthStatus.unauthenticated);
    };
    Future.microtask(_init);
  }

  Future<void> _init() async {
    try {
      final user = await AuthService.currentUserProfile();
      if (user == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final user = await AuthService.signInWithGoogle();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      await _ref.read(catsProvider.notifier).refresh();
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    _ref.read(catsProvider.notifier).clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateDisplayName(String name) async {
    final user = await AuthService.updateDisplayName(name);
    state = state.copyWith(user: user);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
