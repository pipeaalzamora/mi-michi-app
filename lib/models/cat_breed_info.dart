class CatBreedInfo {
  final String id;
  final String name;
  final String origin;
  final String temperament;
  final String description;
  final String lifeSpan;
  final String wikipediaUrl;
  final String referenceImageId;
  final String weightMetric;
  final int energyLevel;
  final int affectionLevel;
  final int childFriendly;
  final int dogFriendly;
  final int healthIssues;
  final int grooming;
  final int intelligence;
  final bool hypoallergenic;

  const CatBreedInfo({
    required this.id,
    required this.name,
    required this.origin,
    required this.temperament,
    required this.description,
    required this.lifeSpan,
    required this.wikipediaUrl,
    required this.referenceImageId,
    required this.weightMetric,
    required this.energyLevel,
    required this.affectionLevel,
    required this.childFriendly,
    required this.dogFriendly,
    required this.healthIssues,
    required this.grooming,
    required this.intelligence,
    required this.hypoallergenic,
  });

  factory CatBreedInfo.fromJson(Map<String, dynamic> json) {
    final weight = (json['weight'] as Map?)?.cast<String, dynamic>() ?? {};
    return CatBreedInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      temperament: json['temperament']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      lifeSpan: json['life_span']?.toString() ?? '',
      wikipediaUrl: json['wikipedia_url']?.toString() ?? '',
      referenceImageId: json['reference_image_id']?.toString() ?? '',
      weightMetric: weight['metric']?.toString() ?? '',
      energyLevel: _int(json['energy_level']),
      affectionLevel: _int(json['affection_level']),
      childFriendly: _int(json['child_friendly']),
      dogFriendly: _int(json['dog_friendly']),
      healthIssues: _int(json['health_issues']),
      grooming: _int(json['grooming']),
      intelligence: _int(json['intelligence']),
      hypoallergenic: _int(json['hypoallergenic']) == 1,
    );
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
