import '../core/api/api_client.dart';
import '../models/health_log.dart';

class HealthService {
  static Future<List<HealthLog>> list(String catId) async {
    final res = await ApiClient.dio.get('/api/cats/$catId/health');
    return (res.data as List).map((e) => HealthLog.fromJson(e)).toList();
  }

  static Future<HealthLog> create({
    required String catId,
    required String logType,
    required String logDate,
    required String title,
    double? numericValue,
    String? description,
  }) async {
    final res = await ApiClient.dio.post('/api/cats/$catId/health', data: {
      'log_type': logType,
      'log_date': logDate,
      'title': title,
      'numeric_value': numericValue,
      'description': description,
    });
    return HealthLog.fromJson(res.data);
  }

  static Future<HealthLog> update({
    required String catId,
    required String logId,
    required String logType,
    required String logDate,
    required String title,
    double? numericValue,
    String? description,
  }) async {
    final res =
        await ApiClient.dio.put('/api/cats/$catId/health/$logId', data: {
      'log_type': logType,
      'log_date': logDate,
      'title': title,
      'numeric_value': numericValue,
      'description': description,
    });
    return HealthLog.fromJson(res.data);
  }

  static Future<void> delete(String catId, String logId) async {
    await ApiClient.dio.delete('/api/cats/$catId/health/$logId');
  }
}
