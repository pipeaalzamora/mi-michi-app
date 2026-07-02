import 'package:flutter_test/flutter_test.dart';
import 'package:mi_michi/data/life_stages.dart';

// Devuelve una fecha ISO (yyyy-MM-dd) situada [days] días en el pasado.
String _isoDaysAgo(int days) {
  final d = DateTime.now().subtract(Duration(days: days));
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

void main() {
  group('LifeStages.calculate', () {
    test('devuelve null si la fecha es null', () {
      expect(LifeStages.calculate(null), isNull);
    });

    test('devuelve null si la fecha es inválida', () {
      expect(LifeStages.calculate('no-es-fecha'), isNull);
    });

    test('gatito de 2 meses -> cachorro', () {
      final stage = LifeStages.calculate(_isoDaysAgo(60));
      expect(stage?.key, 'cachorro');
    });

    test('gato de 8 meses -> juvenil', () {
      final stage = LifeStages.calculate(_isoDaysAgo(30 * 8));
      expect(stage?.key, 'juvenil');
    });

    test('gato de 3 años -> adulto-joven', () {
      final stage = LifeStages.calculate(_isoDaysAgo(365 * 3));
      expect(stage?.key, 'adulto-joven');
    });

    test('gato de 8 años -> adulto-maduro', () {
      final stage = LifeStages.calculate(_isoDaysAgo(365 * 8));
      expect(stage?.key, 'adulto-maduro');
    });

    test('gato de 13 años -> senior', () {
      final stage = LifeStages.calculate(_isoDaysAgo(365 * 13));
      expect(stage?.key, 'senior');
    });
  });

  group('LifeStages.formatAge', () {
    test('null -> Edad desconocida', () {
      expect(LifeStages.formatAge(null), 'Edad desconocida');
    });

    test('fecha inválida -> Edad desconocida', () {
      expect(LifeStages.formatAge('xx'), 'Edad desconocida');
    });

    test('menor de un año muestra meses', () {
      expect(LifeStages.formatAge(_isoDaysAgo(90)), contains('mes'));
    });

    test('un año o más muestra años', () {
      expect(LifeStages.formatAge(_isoDaysAgo(365 * 2)), contains('año'));
    });
  });
}
