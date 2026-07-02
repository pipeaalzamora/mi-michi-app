import 'package:flutter_test/flutter_test.dart';
import 'package:mi_michi/core/auth/auth_provider.dart';
import 'package:mi_michi/models/user_profile.dart';

const _user = UserProfile(
  id: 'u1',
  email: 'a@b.com',
  displayName: 'Ana',
  picture: '',
);

void main() {
  group('AuthState', () {
    test('estado por defecto es loading sin usuario', () {
      const state = AuthState();
      expect(state.status, AuthStatus.loading);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('copyWith actualiza status y user', () {
      const base = AuthState();
      final updated = base.copyWith(
        status: AuthStatus.authenticated,
        user: _user,
      );
      expect(updated.status, AuthStatus.authenticated);
      expect(updated.user, _user);
    });

    test('copyWith limpia el error cuando no se pasa (semántica intencional)',
        () {
      const base = AuthState(status: AuthStatus.unauthenticated, error: 'boom');
      final updated = base.copyWith(status: AuthStatus.authenticated);
      expect(updated.error, isNull);
    });

    test('copyWith conserva el user previo si no se pasa', () {
      const base = AuthState(status: AuthStatus.authenticated, user: _user);
      final updated = base.copyWith(status: AuthStatus.authenticated);
      expect(updated.user, _user);
    });
  });
}
