class AdoptionCat {
  final int id;
  final String name;
  final String age;
  final String gender;
  final String size;
  final String status;
  final String description;
  final String url;
  final List<String> breeds;
  final List<String> photos;
  final String contact;

  const AdoptionCat({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.size,
    required this.status,
    required this.description,
    required this.url,
    required this.breeds,
    required this.photos,
    required this.contact,
  });

  factory AdoptionCat.fromJson(Map<String, dynamic> json) => AdoptionCat(
        id: _int(json['id']),
        name: json['name']?.toString() ?? '',
        age: json['age']?.toString() ?? '',
        gender: json['gender']?.toString() ?? '',
        size: json['size']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
        breeds:
            (json['breeds'] as List? ?? []).map((e) => e.toString()).toList(),
        photos:
            (json['photos'] as List? ?? []).map((e) => e.toString()).toList(),
        contact: json['contact']?.toString() ?? '',
      );

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
