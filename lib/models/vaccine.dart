class Vaccine {
  final String id;
  final String catId;
  final String userId;
  final String name;
  final String appliedDate;
  final String? nextDueDate;
  final String? veterinarian;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vaccine({
    required this.id,
    required this.catId,
    required this.userId,
    required this.name,
    required this.appliedDate,
    this.nextDueDate,
    this.veterinarian,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) => Vaccine(
        id: json['id'] as String,
        catId: json['cat_id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        appliedDate: json['applied_date'] as String,
        nextDueDate: json['next_due_date'] as String?,
        veterinarian: json['veterinarian'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  /// Días hasta la próxima dosis. Negativo = vencida.
  int? get daysUntilDue {
    if (nextDueDate == null) return null;
    final due = DateTime.parse(nextDueDate!);
    return due.difference(DateTime.now()).inDays;
  }
}
