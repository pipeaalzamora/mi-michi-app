import 'package:flutter_test/flutter_test.dart';
import 'package:mi_michi/models/cat.dart';

void main() {
  group('Cat.fromJson', () {
    test('parsea todos los campos', () {
      final cat = Cat.fromJson({
        'id': 'c1',
        'user_id': 'u1',
        'name': 'Michi',
        'birth_date': '2022-01-01',
        'breed': 'Siamés',
        'sex': 'hembra',
        'color': 'blanco',
        'weight_kg': 4.2,
        'photo_url': 'https://x/p.png',
        'notes': 'juguetona',
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': '2023-06-01T00:00:00.000Z',
      });

      expect(cat.id, 'c1');
      expect(cat.userId, 'u1');
      expect(cat.name, 'Michi');
      expect(cat.breed, 'Siamés');
      expect(cat.sex, 'hembra');
      expect(cat.weightKg, 4.2);
      expect(cat.photoUrl, 'https://x/p.png');
      expect(cat.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
    });

    test('usa "desconocido" cuando falta el sexo y admite nulos', () {
      final cat = Cat.fromJson({
        'id': 'c2',
        'user_id': 'u1',
        'name': 'Gato',
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': '2023-01-01T00:00:00.000Z',
      });

      expect(cat.sex, 'desconocido');
      expect(cat.breed, isNull);
      expect(cat.weightKg, isNull);
      expect(cat.photoUrl, isNull);
    });

    test('convierte weight_kg entero a double', () {
      final cat = Cat.fromJson({
        'id': 'c3',
        'user_id': 'u1',
        'name': 'Gato',
        'weight_kg': 5,
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': '2023-01-01T00:00:00.000Z',
      });

      expect(cat.weightKg, 5.0);
      expect(cat.weightKg, isA<double>());
    });
  });

  group('Cat.copyWith', () {
    final base = Cat(
      id: 'c1',
      userId: 'u1',
      name: 'Michi',
      sex: 'hembra',
      weightKg: 4.0,
      createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
    );

    test('sobrescribe solo los campos indicados', () {
      final updated = base.copyWith(name: 'Luna', weightKg: 4.5);
      expect(updated.name, 'Luna');
      expect(updated.weightKg, 4.5);
      expect(updated.id, 'c1');
      expect(updated.sex, 'hembra');
    });

    test('mantiene id, userId y fechas', () {
      final updated = base.copyWith(name: 'Otro');
      expect(updated.id, base.id);
      expect(updated.userId, base.userId);
      expect(updated.createdAt, base.createdAt);
      expect(updated.updatedAt, base.updatedAt);
    });
  });

  group('Cat.toJson', () {
    test('serializa las claves esperadas por el backend', () {
      final cat = Cat(
        id: 'c1',
        userId: 'u1',
        name: 'Michi',
        birthDate: '2022-01-01',
        sex: 'macho',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final json = cat.toJson();

      expect(json['name'], 'Michi');
      expect(json['birth_date'], '2022-01-01');
      expect(json['sex'], 'macho');
      expect(json.containsKey('weight_kg'), isTrue);
    });
  });
}
