import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/cat_photo.dart';

class PhotosService {
  static Future<List<CatPhoto>> list(String catId) async {
    final res = await ApiClient.dio.get('/api/cats/$catId/photos');
    return (res.data as List)
        .map((e) => CatPhoto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<CatPhoto> upload(
    String catId,
    File photo, {
    String? caption,
  }) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        photo.path,
        filename: photo.path.split('/').last,
      ),
      if (caption != null && caption.trim().isNotEmpty)
        'caption': caption.trim(),
    });
    final res = await ApiClient.dio.post(
      '/api/cats/$catId/photos',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return CatPhoto.fromJson(Map<String, dynamic>.from(res.data));
  }

  static Future<void> delete(String catId, String photoId) async {
    await ApiClient.dio.delete('/api/cats/$catId/photos/$photoId');
  }
}
