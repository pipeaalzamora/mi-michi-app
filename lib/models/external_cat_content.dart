class CatImageInfo {
  final String id;
  final String url;
  final int width;
  final int height;

  const CatImageInfo({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
  });

  factory CatImageInfo.fromJson(Map<String, dynamic> json) => CatImageInfo(
        id: json['id']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
        width: _int(json['width']),
        height: _int(json['height']),
      );

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class CatFactInfo {
  final String fact;
  final int length;

  const CatFactInfo({required this.fact, required this.length});

  factory CatFactInfo.fromJson(Map<String, dynamic> json) => CatFactInfo(
        fact: json['fact']?.toString() ?? '',
        length: CatImageInfo._int(json['length']),
      );
}

class CareTipInfo {
  final String id;
  final String category;
  final String emoji;
  final String title;
  final String text;
  final String source;

  const CareTipInfo({
    required this.id,
    required this.category,
    required this.emoji,
    required this.title,
    required this.text,
    required this.source,
  });

  factory CareTipInfo.fromJson(Map<String, dynamic> json) => CareTipInfo(
        id: json['id']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        emoji: json['emoji']?.toString() ?? '🐾',
        title: json['title']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        source: json['source']?.toString() ?? '',
      );
}

class CataasImageInfo {
  final String id;
  final String url;
  final List<String> tags;

  const CataasImageInfo({
    required this.id,
    required this.url,
    required this.tags,
  });

  factory CataasImageInfo.fromJson(Map<String, dynamic> json) =>
      CataasImageInfo(
        id: json['id']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
        tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}
