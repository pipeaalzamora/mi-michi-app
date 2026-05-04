class HealthLog {
  final String id;
  final String catId;
  final String userId;
  final String logType;
  final String logDate;
  final double? numericValue;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HealthLog({
    required this.id,
    required this.catId,
    required this.userId,
    required this.logType,
    required this.logDate,
    this.numericValue,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthLog.fromJson(Map<String, dynamic> json) => HealthLog(
        id: json['id'] as String,
        catId: json['cat_id'] as String,
        userId: json['user_id'] as String,
        logType: json['log_type'] as String,
        logDate: json['log_date'] as String,
        numericValue: (json['numeric_value'] as num?)?.toDouble(),
        title: json['title'] as String,
        description: json['description'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

// Metadatos visuales por tipo de log
class LogMeta {
  final String label;
  final String emoji;

  const LogMeta({required this.label, required this.emoji});
}

const logMetaMap = {
  'peso': LogMeta(label: 'Peso', emoji: '⚖️'),
  'visita_vet': LogMeta(label: 'Visita al vet', emoji: '🩺'),
  'sintoma': LogMeta(label: 'Síntoma', emoji: '🤒'),
  'medicamento': LogMeta(label: 'Medicamento', emoji: '💊'),
  'otro': LogMeta(label: 'Otro', emoji: '📝'),
};
