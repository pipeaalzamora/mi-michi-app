import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../core/api/api_client.dart';
import '../models/user_profile.dart';

class AuthService {
  static const _clientId =
      '1057417146171-hcv6s2317p86dtef7va89g6q9ehrfd7q.apps.googleusercontent.com';
  static const _redirectUri = 'http://localhost';

  static Future<UserProfile> signInWithGoogle() async {
    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'response_type': 'code',
      'scope': 'openid email profile',
      'access_type': 'offline',
      'prompt': 'select_account',
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'http',
      options: const FlutterWebAuth2Options(preferEphemeral: true),
    );

    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) throw Exception('No se recibió el código de autorización');

    final response = await ApiClient.dio.post('/auth/google/desktop', data: {
      'code': code,
      'redirect_uri': _redirectUri,
      'client_id': _clientId,
    });

    final token = response.data['token'] as String;
    await ApiClient.saveToken(token);
    return UserProfile.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  static Future<void> signOut() async {
    await ApiClient.clearToken();
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiClient.getToken();
    return token != null;
  }
}
