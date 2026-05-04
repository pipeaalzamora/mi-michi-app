class LifeStage {
  final String key;
  final String label;
  final String emoji;
  final String description;
  final String ageRange;
  final List<String> tips;
  final String vetVisits;

  const LifeStage({
    required this.key,
    required this.label,
    required this.emoji,
    required this.description,
    required this.ageRange,
    required this.tips,
    required this.vetVisits,
  });
}

class LifeStages {
  static const _stages = [
    LifeStage(
      key: 'cachorro',
      label: 'Cachorro',
      emoji: '🐾',
      ageRange: '0 a 6 meses',
      description: 'Etapa de descubrimiento. Tu michi crece muy rápido, juega sin parar y aprende del mundo.',
      tips: [
        'Alimento específico para gatitos (kitten), rico en proteínas y grasas.',
        'Socialízalo con personas, ruidos y juguetes desde temprano.',
        'Esquema completo de vacunas y desparasitación.',
      ],
      vetVisits: 'Cada 3-4 semanas durante el esquema de vacunas.',
    ),
    LifeStage(
      key: 'juvenil',
      label: 'Juvenil',
      emoji: '✨',
      ageRange: '6 a 12 meses',
      description: 'Tu gato es un adolescente: muy enérgico, curioso y un poco travieso.',
      tips: [
        'Considera la esterilización entre los 5 y 8 meses.',
        'Transición gradual a alimento de adulto al cumplir el año.',
        'Mucho juego activo: cazar, trepar, perseguir.',
      ],
      vetVisits: 'Revisión general a los 6 meses y al año.',
    ),
    LifeStage(
      key: 'adulto-joven',
      label: 'Adulto joven',
      emoji: '😺',
      ageRange: '1 a 6 años',
      description: 'Tu michi está en su mejor momento: activo, sano y con personalidad bien definida.',
      tips: [
        'Alimento balanceado de adulto, controlando porciones.',
        'Mantén las vacunas anuales y desparasitación al día.',
        'Juego diario para mantener el peso ideal.',
      ],
      vetVisits: 'Revisión anual.',
    ),
    LifeStage(
      key: 'adulto-maduro',
      label: 'Adulto maduro',
      emoji: '🐈',
      ageRange: '7 a 10 años',
      description: 'Tu gato empieza a bajar el ritmo. Es momento de prestar más atención a su salud.',
      tips: [
        'Considera alimento senior o de madurez.',
        'Revisiones veterinarias cada 6 meses.',
        'Vigila el peso y la hidratación.',
      ],
      vetVisits: 'Cada 6 meses.',
    ),
    LifeStage(
      key: 'senior',
      label: 'Senior',
      emoji: '👴🐱',
      ageRange: '11+ años',
      description: 'Tu michi es un veterano. Merece cuidados especiales y mucho amor.',
      tips: [
        'Alimento específico para gatos senior.',
        'Análisis de sangre anuales para detectar problemas a tiempo.',
        'Camas cómodas y acceso fácil a recursos.',
      ],
      vetVisits: 'Cada 6 meses o antes si hay cambios.',
    ),
  ];

  static LifeStage? calculate(String? birthDate) {
    if (birthDate == null) return null;
    final birth = DateTime.tryParse(birthDate);
    if (birth == null) return null;
    final months = DateTime.now().difference(birth).inDays ~/ 30;

    if (months < 6) return _stages[0];
    if (months < 12) return _stages[1];
    if (months < 72) return _stages[2];
    if (months < 120) return _stages[3];
    return _stages[4];
  }

  static String formatAge(String? birthDate) {
    if (birthDate == null) return 'Edad desconocida';
    final birth = DateTime.tryParse(birthDate);
    if (birth == null) return 'Edad desconocida';
    final now = DateTime.now();
    final years = now.year - birth.year - (now.month < birth.month || (now.month == birth.month && now.day < birth.day) ? 1 : 0);
    final months = now.difference(birth).inDays ~/ 30;
    if (years >= 1) return '$years ${years == 1 ? 'año' : 'años'}';
    return '$months ${months == 1 ? 'mes' : 'meses'}';
  }
}
