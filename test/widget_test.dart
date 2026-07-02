import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_michi/models/cat.dart';
import 'package:mi_michi/core/theme/cat_theme.dart';
import 'package:mi_michi/widgets/cat_share_card.dart';

Cat _cat({required String name}) => Cat(
      id: 'c1',
      userId: 'u1',
      name: name,
      sex: 'hembra',
      createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
    );

Future<void> _pump(WidgetTester tester, Cat cat) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CatShareCard(
          cat: cat,
          catTheme: CatTheme.hembra,
          repaintKey: GlobalKey(),
        ),
      ),
    ),
  );
}

void main() {
  group('CatShareCard', () {
    testWidgets('renderiza el nombre del gato', (tester) async {
      await _pump(tester, _cat(name: 'Michi'));
      expect(find.text('Michi'), findsOneWidget);
      expect(find.text('Mi Michi 🐾'), findsOneWidget);
    });

    testWidgets('no crashea con nombre de un solo carácter', (tester) async {
      // Antes del fix, cat.name.substring(0, 2) lanzaba RangeError.
      await _pump(tester, _cat(name: 'Y'));
      expect(tester.takeException(), isNull);
      // "Y" aparece dos veces: como inicial del avatar y como nombre.
      expect(find.text('Y'), findsNWidgets(2));
    });

    testWidgets('muestra iniciales de 2 letras en mayúscula', (tester) async {
      await _pump(tester, _cat(name: 'luna'));
      expect(find.text('LU'), findsOneWidget);
    });
  });
}
