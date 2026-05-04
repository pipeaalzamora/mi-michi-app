/// Mapea las características del gato a un modelo 3D .glb
class CatModelSelector {
  /// Devuelve el path del asset del modelo según color y raza.
  /// Si no hay coincidencia exacta, devuelve el modelo por defecto.
  static String selectModel({String? color, String? breed}) {
    final colorLower = color?.toLowerCase() ?? '';
    final breedLower = breed?.toLowerCase() ?? '';

    // Por raza primero
    if (breedLower.contains('siamés') || breedLower.contains('siames')) {
      return 'assets/models/gordita.glb';
    }
    if (breedLower.contains('persa')) {
      return 'assets/models/gordita.glb';
    }
    if (breedLower.contains('maine') || breedLower.contains('coon')) {
      return 'assets/models/gordita.glb';
    }
    if (breedLower.contains('bengal') || breedLower.contains('bengalí')) {
      return 'assets/models/gordita.glb';
    }

    // Por color
    if (colorLower.contains('naranja') || colorLower.contains('orange') ||
        colorLower.contains('rojizo') || colorLower.contains('anaranjado')) {
      return 'assets/models/gordita.glb';
    }
    if (colorLower.contains('negro') || colorLower.contains('black')) {
      return 'assets/models/gordita.glb';
    }
    if (colorLower.contains('blanco') || colorLower.contains('white')) {
      return 'assets/models/gordita.glb';
    }
    if (colorLower.contains('gris') || colorLower.contains('gray') ||
        colorLower.contains('grey') || colorLower.contains('azul')) {
      return 'assets/models/gordita.glb';
    }
    if (colorLower.contains('atigrado') || colorLower.contains('tabby') ||
        colorLower.contains('rayas')) {
      return 'assets/models/gordita.glb';
    }
    if (colorLower.contains('crema') || colorLower.contains('beige')) {
      return 'assets/models/gordita.glb';
    }

    // Default
    return 'assets/models/gordita.glb';
  }

  /// Lista de todos los modelos disponibles
  static const availableModels = [
    'assets/models/gordita.glb',
  ];
}
