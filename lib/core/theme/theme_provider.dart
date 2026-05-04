import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cats/cats_provider.dart';
import 'cat_theme.dart';

/// Devuelve el CatTheme según el sexo del gato activo.
/// Se recalcula automáticamente cada vez que cambia el gato seleccionado.
final catThemeProvider = Provider<CatTheme>((ref) {
  final activeCat = ref.watch(catsProvider).activeCat;
  return CatTheme.fromSex(activeCat?.sex);
});
