import '../models/cat_breed_info.dart';

class LocalizedBreed {
  final String name;
  final String origin;
  final String description;
  final List<String> temperaments;

  const LocalizedBreed({
    required this.name,
    required this.origin,
    required this.description,
    required this.temperaments,
  });

  String get searchText => CatBreedLocalizations.searchable(
      '$name $origin ${temperaments.join(' ')}');
}

class CatBreedLocalizations {
  static LocalizedBreed from(CatBreedInfo breed) {
    final name = displayName(breed);
    final origin = localizedOrigin(breed.origin);
    final temperaments = localizedTemperaments(breed.temperament);
    return LocalizedBreed(
      name: name,
      origin: origin,
      temperaments: temperaments,
      description: spanishDescription(
        name: name,
        origin: origin,
        temperaments: temperaments,
        lifeSpan: breed.lifeSpan,
        weightMetric: breed.weightMetric,
        hypoallergenic: breed.hypoallergenic,
      ),
    );
  }

  static String displayName(CatBreedInfo breed) {
    final byId = _breedNamesById[breed.id.toLowerCase()];
    if (byId != null) return byId;
    return displayStoredName(breed.name);
  }

  static String displayStoredName(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return normalized;
    return _breedNamesByEnglishName[normalized.toLowerCase()] ?? normalized;
  }

  static String searchable(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp('[áàäâã]'), 'a')
        .replaceAll(RegExp('[éèëê]'), 'e')
        .replaceAll(RegExp('[íìïî]'), 'i')
        .replaceAll(RegExp('[óòöôõ]'), 'o')
        .replaceAll(RegExp('[úùüû]'), 'u')
        .replaceAll('ñ', 'n');
  }

  static String localizedOrigin(String origin) {
    final parts = origin
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map((part) => _origins[part] ?? part)
        .toList();
    return parts.join(', ');
  }

  static List<String> localizedTemperaments(String temperament) {
    return temperament
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .map((tag) => _temperaments[tag] ?? tag)
        .toList();
  }

  static String spanishDescription({
    required String name,
    required String origin,
    required List<String> temperaments,
    required String lifeSpan,
    required String weightMetric,
    required bool hypoallergenic,
  }) {
    final sentences = <String>[];
    if (origin.isNotEmpty) {
      sentences.add('$name es una raza originaria de $origin.');
    } else {
      sentences.add('$name es una raza reconocida por registros felinos.');
    }
    if (temperaments.isNotEmpty) {
      final traits = temperaments.take(4).map(_lowerFirst).toList();
      sentences.add('Suele destacar por un temperamento ${_join(traits)}.');
    }
    final details = <String>[];
    if (lifeSpan.isNotEmpty) {
      details.add('una esperanza de vida aproximada de $lifeSpan años');
    }
    if (weightMetric.isNotEmpty) {
      details.add('un peso adulto habitual de $weightMetric kg');
    }
    if (details.isNotEmpty) {
      sentences.add('Como referencia, presenta ${_join(details)}.');
    }
    if (hypoallergenic) {
      sentences.add(
        'También aparece catalogada como una raza con menor tendencia a provocar alergias.',
      );
    }
    return sentences.join(' ');
  }

  static String _join(List<String> values) {
    if (values.isEmpty) return '';
    if (values.length == 1) return values.first;
    if (values.length == 2) return '${values.first} y ${values.last}';
    return '${values.take(values.length - 1).join(', ')} y ${values.last}';
  }

  static String _lowerFirst(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toLowerCase()}${value.substring(1)}';
  }
}

const _breedNamesById = {
  'abys': 'Abisinio',
  'aege': 'Egeo',
  'abob': 'Bobtail americano',
  'acur': 'Curl americano',
  'asho': 'Americano de pelo corto',
  'awir': 'Americano de pelo duro',
  'amau': 'Mau árabe',
  'amis': 'Australian Mist',
  'bali': 'Balinés',
  'bamb': 'Bambino',
  'beng': 'Bengalí',
  'birm': 'Birmano',
  'bomb': 'Bombay',
  'bslo': 'Británico de pelo largo',
  'bsho': 'Británico de pelo corto',
  'bure': 'Burmés',
  'buri': 'Burmilla',
  'cspa': 'California Spangled',
  'ctif': 'Chantilly-Tiffany',
  'char': 'Chartreux',
  'chau': 'Chausie',
  'chee': 'Cheetoh',
  'csho': 'Colorpoint de pelo corto',
  'crex': 'Cornish Rex',
  'cymr': 'Cymric',
  'cypr': 'Chipriota',
  'drex': 'Devon Rex',
  'dons': 'Donskoy',
  'lihu': 'Dragon Li',
  'emau': 'Mau egipcio',
  'ebur': 'Burmés europeo',
  'esho': 'Exótico de pelo corto',
  'hbro': 'Havana Brown',
  'hima': 'Himalayo',
  'jbob': 'Bobtail japonés',
  'java': 'Javanés',
  'khao': 'Khao Manee',
  'kora': 'Korat',
  'kuri': 'Bobtail kuriliano',
  'lape': 'LaPerm',
  'mcoo': 'Maine Coon',
  'mala': 'Malayo',
  'manx': 'Manx',
  'munc': 'Munchkin',
  'nebe': 'Nebelung',
  'norw': 'Bosque de Noruega',
  'ocic': 'Ocicat',
  'orie': 'Oriental',
  'pers': 'Persa',
  'pixi': 'Pixie-bob',
  'raga': 'Ragamuffin',
  'ragd': 'Ragdoll',
  'rblu': 'Azul ruso',
  'sava': 'Savannah',
  'sfol': 'Escocés plegado',
  'srex': 'Selkirk Rex',
  'siam': 'Siamés',
  'sibe': 'Siberiano',
  'sing': 'Singapura',
  'snow': 'Snowshoe',
  'soma': 'Somalí',
  'sphy': 'Sphynx',
  'tonk': 'Tonkinés',
  'toyg': 'Toyger',
  'tang': 'Angora turco',
  'tvan': 'Van turco',
  'ycho': 'York Chocolate',
};

const _breedNamesByEnglishName = {
  'abyssinian': 'Abisinio',
  'aegean': 'Egeo',
  'american bobtail': 'Bobtail americano',
  'american curl': 'Curl americano',
  'american shorthair': 'Americano de pelo corto',
  'american wirehair': 'Americano de pelo duro',
  'arabian mau': 'Mau árabe',
  'balinese': 'Balinés',
  'bengal': 'Bengalí',
  'birman': 'Birmano',
  'british longhair': 'Británico de pelo largo',
  'british shorthair': 'Británico de pelo corto',
  'burmese': 'Burmés',
  'cyprus': 'Chipriota',
  'egyptian mau': 'Mau egipcio',
  'european burmese': 'Burmés europeo',
  'exotic shorthair': 'Exótico de pelo corto',
  'himalayan': 'Himalayo',
  'japanese bobtail': 'Bobtail japonés',
  'javanese': 'Javanés',
  'kurilian': 'Bobtail kuriliano',
  'malayan': 'Malayo',
  'norwegian forest cat': 'Bosque de Noruega',
  'persian': 'Persa',
  'russian blue': 'Azul ruso',
  'scottish fold': 'Escocés plegado',
  'siamese': 'Siamés',
  'siberian': 'Siberiano',
  'somali': 'Somalí',
  'tonkinese': 'Tonkinés',
  'turkish angora': 'Angora turco',
  'turkish van': 'Van turco',
};

const _origins = {
  'Australia': 'Australia',
  'Burma': 'Birmania',
  'Canada': 'Canadá',
  'China': 'China',
  'Cyprus': 'Chipre',
  'Egypt': 'Egipto',
  'France': 'Francia',
  'Greece': 'Grecia',
  'Iran (Persia)': 'Irán',
  'Isle of Man': 'Isla de Man',
  'Japan': 'Japón',
  'Norway': 'Noruega',
  'Russia': 'Rusia',
  'Singapore': 'Singapur',
  'Somalia': 'Somalia',
  'Thailand': 'Tailandia',
  'Turkey': 'Turquía',
  'United Arab Emirates': 'Emiratos Árabes Unidos',
  'United Kingdom': 'Reino Unido',
  'United States': 'Estados Unidos',
};

const _temperaments = {
  'Active': 'Activo',
  'Adaptable': 'Adaptable',
  'Affectionate': 'Cariñoso',
  'Agile': 'Ágil',
  'Alert': 'Alerta',
  'Calm': 'Calmado',
  'Clever': 'Listo',
  'Curious': 'Curioso',
  'Demanding': 'Exigente',
  'Dependent': 'Dependiente',
  'Docile': 'Dócil',
  'Dog-like': 'Perruno',
  'Easy Going': 'Relajado',
  'Energetic': 'Enérgico',
  'Friendly': 'Amigable',
  'Gentle': 'Dócil',
  'Gregarious': 'Sociable',
  'Independent': 'Independiente',
  'Inquisitive': 'Curioso',
  'Intelligent': 'Inteligente',
  'Interactive': 'Interactivo',
  'Lap Cat': 'Faldero',
  'Lively': 'Vivaz',
  'Loving': 'Amoroso',
  'Loyal': 'Leal',
  'Mischievous': 'Travieso',
  'Patient': 'Paciente',
  'Playful': 'Juguetón',
  'Quiet': 'Silencioso',
  'Relaxed': 'Relajado',
  'Reserved': 'Reservado',
  'Sensitive': 'Sensible',
  'Shy': 'Tímido',
  'Social': 'Sociable',
  'Sweet': 'Dulce',
  'Tenacious': 'Tenaz',
  'Trainable': 'Entrenable',
  'Vocal': 'Vocal',
  'Warm': 'Cálido',
};
