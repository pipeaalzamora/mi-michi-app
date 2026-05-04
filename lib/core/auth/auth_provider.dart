import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
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

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    // Cuando el token expira, forzar logout automático
    ApiClient.onUnauthorized = () {
      state = const AuthState(status: AuthStatus.unauthenticated);
    };
    _checkSession();
  }

  /// Al arrancar verifica si hay JWT guardado y carga el perfil.
  Future<void> _checkSession() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final res = await ApiClient.dio.get('/api/profile');
      final profile = UserProfile.fromJson(res.data as Map<String, dynamic>);
      state = AuthState(status: AuthStatus.authenticated, user: profile);
    } catch (_) {
      // Token expirado o inválido
      await ApiClient.clearToken();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await AuthService.signInWithGoogle();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateDisplayName(String name) async {
    final res = await ApiClient.dio.put('/api/profile', data: {'display_name': name});
    final updated = UserProfile.fromJson(res.data as Map<String, dynamic>);
    state = state.copyWith(user: updated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (_) => AuthNotifier(),
);
