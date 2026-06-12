class FoodProduct {
  final String barcode;
  final String name;
  final String genericName;
  final String brands;
  final String quantity;
  final String categories;
  final String ingredientsText;
  final String imageUrl;
  final String nutriScore;
  final String novaGroup;
  final Map<String, dynamic> nutriments;
  final String sourceUrl;

  const FoodProduct({
    required this.barcode,
    required this.name,
    required this.genericName,
    required this.brands,
    required this.quantity,
    required this.categories,
    required this.ingredientsText,
    required this.imageUrl,
    required this.nutriScore,
    required this.novaGroup,
    required this.nutriments,
    required this.sourceUrl,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) => FoodProduct(
        barcode: json['barcode']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        genericName: json['generic_name']?.toString() ?? '',
        brands: json['brands']?.toString() ?? '',
        quantity: json['quantity']?.toString() ?? '',
        categories: json['categories']?.toString() ?? '',
        ingredientsText: json['ingredients_text']?.toString() ?? '',
        imageUrl: json['image_url']?.toString() ?? '',
        nutriScore: json['nutriscore_grade']?.toString() ?? '',
        novaGroup: json['nova_group']?.toString() ?? '',
        nutriments: (json['nutriments'] as Map?)?.cast<String, dynamic>() ?? {},
        sourceUrl: json['source_url']?.toString() ?? '',
      );

  bool get hasData =>
      name.isNotEmpty ||
      genericName.isNotEmpty ||
      brands.isNotEmpty ||
      ingredientsText.isNotEmpty;

  String get title {
    if (name.isNotEmpty) return name;
    if (genericName.isNotEmpty) return genericName;
    return barcode.isEmpty ? 'Producto' : 'Producto $barcode';
  }

  String nutrient(String key) {
    final value = nutriments[key];
    if (value == null) return '';
    if (value is num) return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
    return value.toString();
  }
}
