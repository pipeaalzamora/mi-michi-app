class CatPhoto {
  final String id;
  final String userId;
  final String catId;
  final String photoUrl;
  final String caption;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CatPhoto({
    required this.id,
    required this.userId,
    required this.catId,
    required this.photoUrl,
    required this.caption,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CatPhoto.fromJson(Map<String, dynamic> json) => CatPhoto(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        catId: json['cat_id']?.toString() ?? '',
        photoUrl: json['photo_url']?.toString() ?? '',
        caption: json['caption']?.toString() ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}
