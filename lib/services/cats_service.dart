import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/cat.dart';

class CatsService {
  static Future<List<Cat>> list() async {
    final res = await ApiClient.dio.get('/api/cats');
    return (res.data as List).map((e) => Cat.fromJson(e)).toList();
  }

  static Future<Cat> create({
    required String name,
    String? birthDate,
    String? breed,
    String sex = 'desconocido',
    String? color,
    double? weightKg,
    String? notes,
  }) async {
    final res = await ApiClient.dio.post('/api/cats', data: {
      'name': name,
      'birth_date': birthDate,
      'breed': breed,
      'sex': sex,
      'color': color,
      'weight_kg': weightKg,
      'notes': notes,
    });
    return Cat.fromJson(res.data);
  }

  static Future<Cat> update({
    required String id,
    required String name,
    String? birthDate,
    String? breed,
    String sex = 'desconocido',
    String? color,
    double? weightKg,
    String? photoUrl,
    String? notes,
  }) async {
    final res = await ApiClient.dio.put('/api/cats/$id', data: {
      'name': name,
      'birth_date': birthDate,
      'breed': breed,
      'sex': sex,
      'color': color,
      'weight_kg': weightKg,
      'photo_url': photoUrl,
      'notes': notes,
    });
    return Cat.fromJson(res.data);
  }

  static Future<void> delete(String id) async {
    await ApiClient.dio.delete('/api/cats/$id');
  }

  /// Sube una foto y devuelve el gato actualizado con la nueva photo_url.
  static Future<Cat> uploadPhoto(String catId, File photo) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        photo.path,
        filename: photo.path.split('/').last,
      ),
    });
    final res = await ApiClient.dio.post(
      '/api/cats/$catId/photo',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Cat.fromJson(res.data);
  }
}
