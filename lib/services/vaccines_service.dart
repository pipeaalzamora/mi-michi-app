import '../core/api/api_client.dart';
import '../models/vaccine.dart';

class VaccinesService {
  static Future<List<Vaccine>> list(String catId) async {
    final res = await ApiClient.dio.get('/api/cats/$catId/vaccines');
    return (res.data as List).map((e) => Vaccine.fromJson(e)).toList();
  }

  static Future<Vaccine> create({
    required String catId,
    required String name,
    required String appliedDate,
    String? nextDueDate,
    String? veterinarian,
    String? notes,
  }) async {
    final res = await ApiClient.dio.post('/api/cats/$catId/vaccines', data: {
      'name': name,
      'applied_date': appliedDate,
      'next_due_date': nextDueDate,
      'veterinarian': veterinarian,
      'notes': notes,
    });
    return Vaccine.fromJson(res.data);
  }

  static Future<Vaccine> update({
    required String catId,
    required String vacId,
    required String name,
    required String appliedDate,
    String? nextDueDate,
    String? veterinarian,
    String? notes,
  }) async {
    final res = await ApiClient.dio.put('/api/cats/$catId/vaccines/$vacId', data: {
      'name': name,
      'applied_date': appliedDate,
      'next_due_date': nextDueDate,
      'veterinarian': veterinarian,
      'notes': notes,
    });
    return Vaccine.fromJson(res.data);
  }

  static Future<void> delete(String catId, String vacId) async {
    await ApiClient.dio.delete('/api/cats/$catId/vaccines/$vacId');
  }
}
