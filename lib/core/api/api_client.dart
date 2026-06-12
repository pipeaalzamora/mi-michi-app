import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _tokenKey = 'mi_michi_jwt';

class ApiClient {
  // En emulador Android: 10.0.2.2 apunta al localhost de la máquina host
  // En dispositivo físico: usa la IP de tu máquina en la red local (ej: 192.168.1.x)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.3:8080',
  );

  static const _storage = FlutterSecureStorage();
  static late final Dio _dio;

  // Callback para forzar logout cuando el token expira
  static void Function()? onUnauthorized;

  static void init() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // Log en modo debug
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint('[API] $o'),
      ));
    }

    // Interceptor: JWT + manejo de 401
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        final firebaseToken = await firebaseUser?.getIdToken();
        final token = firebaseToken ?? await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expirado — limpiar y forzar logout
          await _storage.delete(key: _tokenKey);
          onUnauthorized?.call();
        }
        // Mejorar el mensaje de error para mostrarlo en la UI
        final msg = _extractErrorMessage(error);
        handler.next(DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: msg,
          message: msg,
        ));
      },
    ));
  }

  static Dio get dio => _dio;

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  /// Extrae el mensaje de error del body de la respuesta del backend.
  static String _extractErrorMessage(DioException error) {
    try {
      final data = error.response?.data;
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
    } catch (_) {}
    return switch (error.type) {
      DioExceptionType.connectionTimeout => 'No se pudo conectar al servidor',
      DioExceptionType.receiveTimeout =>
        'El servidor tardó demasiado en responder',
      DioExceptionType.connectionError => 'Sin conexión. Verifica tu red.',
      _ => error.message ?? 'Error desconocido',
    };
  }
}
