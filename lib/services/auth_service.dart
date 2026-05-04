import 'package:google_sign_in/google_sign_in.dart';
import '../core/api/api_client.dart';
import '../models/user_profile.dart';

class AuthService {
  static final _googleSignIn = GoogleSignIn(
    serverClientId: '1057417146171-7tbgg2ulho9falmt8qhf4ip61v1h722n.apps.googleusercontent.com',
    scopes: ['openid', 'email', 'profile'],
  );

  static Future<UserProfile> signInWithGoogle() async {
    await _googleSignIn.signOut();
    
    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } catch (e) {
      throw Exception('Error en Google Sign-In: $e');
    }
    
    if (googleUser == null) {
      // Intentar signInSilently como fallback
      googleUser = await _googleSignIn.signInSilently();
    }
    
    if (googleUser == null) throw Exception('Login cancelado por el usuario');

    GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await googleUser.authentication;
    } catch (e) {
      throw Exception('Error obteniendo tokens: $e');
    }

    final idToken = googleAuth.idToken;
    if (idToken == null) throw Exception('No se obtuvo el ID token. Verifica que Google Sign-In esté habilitado en Firebase Auth.');

    final response = await ApiClient.dio.post('/auth/google', data: {
      'id_token': idToken,
    });

    final token = response.data['token'] as String;
    await ApiClient.saveToken(token);
    return UserProfile.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  static Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      ApiClient.clearToken(),
    ]);
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiClient.getToken();
    return token != null;
  }
}
