import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../api/api_client.dart';

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

// Usuario demo — sin auth
const _demoUser = UserProfile(
  id: 'demo-user',
  email: 'demo@mimichi.app',
  displayName: 'Demo',
  picture: '',
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    ApiClient.onUnauthorized = () {
      state = const AuthState(status: AuthStatus.unauthenticated);
    };
    // Autologin inmediato
    Future.microtask(() {
      state = const AuthState(
        status: AuthStatus.authenticated,
        user: _demoUser,
      );
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState(status: AuthStatus.authenticated, user: _demoUser);
  }

  Future<void> signOut() async {
    await ApiClient.clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateDisplayName(String name) async {
    state = state.copyWith(
      user: UserProfile(
        id: _demoUser.id,
        email: _demoUser.email,
        displayName: name,
        picture: _demoUser.picture,
      ),
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (_) => AuthNotifier(),
);
