import 'package:flutter_test/flutter_test.dart';
import 'package:mi_michi/core/cats/cats_provider.dart';
import 'package:mi_michi/models/cat.dart';

Cat _cat(String id, {String name = 'Michi'}) => Cat(
      id: id,
      userId: 'u1',
      name: name,
      createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
    );

void main() {
  group('CatsState.activeCat', () {
    test('null cuando no hay gatos', () {
      const state = CatsState();
      expect(state.activeCat, isNull);
    });

    test('primer gato cuando activeCatId es null', () {
      final state = CatsState(cats: [_cat('a'), _cat('b')]);
      expect(state.activeCat?.id, 'a');
    });

    test('devuelve el gato que coincide con activeCatId', () {
      final state = CatsState(cats: [_cat('a'), _cat('b')], activeCatId: 'b');
      expect(state.activeCat?.id, 'b');
    });

    test('cae al primero si activeCatId no existe en la lista', () {
      final state =
          CatsState(cats: [_cat('a'), _cat('b')], activeCatId: 'zzz');
      expect(state.activeCat?.id, 'a');
    });
  });

  group('CatsState.copyWith', () {
    test('sobrescribe cats y activeCatId', () {
      const base = CatsState();
      final updated = base.copyWith(cats: [_cat('a')], activeCatId: 'a');
      expect(updated.cats.length, 1);
      expect(updated.activeCatId, 'a');
    });

    test('loading conserva su valor previo si no se pasa', () {
      const base = CatsState(loading: true);
      final updated = base.copyWith(activeCatId: 'a');
      expect(updated.loading, isTrue);
    });
  });
}
