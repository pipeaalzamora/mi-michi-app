import 'package:flutter_test/flutter_test.dart';
import 'package:mi_michi/models/user_profile.dart';

void main() {
  group('UserProfile.fromJson', () {
    test('parsea todos los campos', () {
      final u = UserProfile.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'display_name': 'Ana',
        'picture': 'https://x/a.png',
      });

      expect(u.id, 'u1');
      expect(u.email, 'a@b.com');
      expect(u.displayName, 'Ana');
      expect(u.picture, 'https://x/a.png');
    });

    test('display_name y picture ausentes -> cadena vacía', () {
      final u = UserProfile.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
      });

      expect(u.displayName, '');
      expect(u.picture, '');
    });
  });
}
