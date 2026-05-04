class Cat {
  final String id;
  final String userId;
  final String name;
  final String? birthDate;
  final String? breed;
  final String sex;
  final String? color;
  final double? weightKg;
  final String? photoUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cat({
    required this.id,
    required this.userId,
    required this.name,
    this.birthDate,
    this.breed,
    this.sex = 'desconocido',
    this.color,
    this.weightKg,
    this.photoUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cat.fromJson(Map<String, dynamic> json) => Cat(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        birthDate: json['birth_date'] as String?,
        breed: json['breed'] as String?,
        sex: json['sex'] as String? ?? 'desconocido',
        color: json['color'] as String?,
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        photoUrl: json['photo_url'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'birth_date': birthDate,
        'breed': breed,
        'sex': sex,
        'color': color,
        'weight_kg': weightKg,
        'photo_url': photoUrl,
        'notes': notes,
      };

  Cat copyWith({
    String? name,
    String? birthDate,
    String? breed,
    String? sex,
    String? color,
    double? weightKg,
    String? photoUrl,
    String? notes,
  }) =>
      Cat(
        id: id,
        userId: userId,
        name: name ?? this.name,
        birthDate: birthDate ?? this.birthDate,
        breed: breed ?? this.breed,
        sex: sex ?? this.sex,
        color: color ?? this.color,
        weightKg: weightKg ?? this.weightKg,
        photoUrl: photoUrl ?? this.photoUrl,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
