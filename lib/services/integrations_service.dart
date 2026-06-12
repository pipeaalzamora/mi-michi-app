import '../core/api/api_client.dart';
import '../models/adoption_cat.dart';
import '../models/cat_breed_info.dart';
import '../models/external_cat_content.dart';
import '../models/food_product.dart';

class IntegrationsService {
  static Future<List<CatBreedInfo>> catBreeds() async {
    final res = await ApiClient.dio.get('/api/integrations/cat-breeds');
    return (res.data as List)
        .map((e) => CatBreedInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<List<CatImageInfo>> catBreedImages(
    String breedId, {
    int limit = 8,
  }) async {
    final res = await ApiClient.dio.get(
      '/api/integrations/cat-breeds/$breedId/images',
      queryParameters: {'limit': limit},
    );
    return (res.data as List)
        .map((e) => CatImageInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<CatFactInfo> catFact() async {
    final res = await ApiClient.dio.get('/api/integrations/cat-fact');
    return CatFactInfo.fromJson(Map<String, dynamic>.from(res.data));
  }

  static Future<CataasImageInfo> catImage({String? tag}) async {
    final res = await ApiClient.dio.get(
      '/api/integrations/cat-image',
      queryParameters: {
        if (tag != null && tag.trim().isNotEmpty) 'tag': tag.trim(),
      },
    );
    return CataasImageInfo.fromJson(Map<String, dynamic>.from(res.data));
  }

  static Future<FoodProduct> foodProduct(String barcode) async {
    final res =
        await ApiClient.dio.get('/api/integrations/food-products/$barcode');
    return FoodProduct.fromJson(Map<String, dynamic>.from(res.data));
  }

  static Future<List<FoodProduct>> searchFoodProducts(
    String query, {
    int limit = 10,
  }) async {
    final res = await ApiClient.dio.get(
      '/api/integrations/food-products',
      queryParameters: {'q': query, 'limit': limit},
    );
    return (res.data as List)
        .map((e) => FoodProduct.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<List<AdoptionCat>> adoptableCats({
    String? location,
    String? breed,
    int limit = 10,
  }) async {
    final res = await ApiClient.dio.get(
      '/api/integrations/adoptions/cats',
      queryParameters: {
        'limit': limit,
        if (location != null && location.trim().isNotEmpty)
          'location': location.trim(),
        if (breed != null && breed.trim().isNotEmpty) 'breed': breed.trim(),
      },
    );
    return (res.data as List)
        .map((e) => AdoptionCat.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
