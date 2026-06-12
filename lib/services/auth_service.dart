import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/api/api_client.dart';
import '../models/user_profile.dart';

class AuthService {
  static const _devAuth = String.fromEnvironment('APP_AUTH_MODE') == 'dev';
  static const _devUser = UserProfile(
    id: 'dev-user-001',
    email: 'dev@mimichi.local',
    displayName: 'Modo diseño',
    picture: '',
  );

  static final _firebaseAuth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn(
    serverClientId:
        '1057417146171-kmie6i3dh6giduvuopejeqi2nsqh76de.apps.googleusercontent.com',
    scopes: ['openid', 'email', 'profile'],
  );

  static Future<UserProfile> signInWithGoogle() async {
    if (_devAuth) return _devUser;

    await _googleSignIn.signOut();

    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } catch (e) {
      throw Exception('Error en Google Sign-In: $e');
    }

    googleUser ??= await _googleSignIn.signInSilently();

    if (googleUser == null) {
      throw Exception('Login cancelado por el usuario');
    }

    GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await googleUser.authentication;
    } catch (e) {
      throw Exception('Error obteniendo tokens: $e');
    }

    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception(
          'No se obtuvo el ID token. Verifica que Google Sign-In esté habilitado en Firebase Auth.');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final firebaseToken = await userCredential.user?.getIdToken();
    if (firebaseToken == null) {
      throw Exception('No se obtuvo el token de Firebase.');
    }

    final response = await ApiClient.dio.post('/auth/firebase', data: {
      'id_token': firebaseToken,
    });
    return UserProfile.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  static Future<UserProfile?> currentUserProfile() async {
    if (_devAuth) return _devUser;

    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final firebaseToken = await user.getIdToken();
    if (firebaseToken == null) return null;

    final response = await ApiClient.dio.post('/auth/firebase', data: {
      'id_token': firebaseToken,
    });
    return UserProfile.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  static Future<UserProfile> updateDisplayName(String name) async {
    final response = await ApiClient.dio.put('/api/profile', data: {
      'display_name': name,
    });
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<void> signOut() async {
    if (_devAuth) return;

    await Future.wait([
      _googleSignIn.signOut(),
      _firebaseAuth.signOut(),
      ApiClient.clearToken(),
    ]);
  }

  static Future<bool> isLoggedIn() async {
    if (_devAuth) return true;

    return _firebaseAuth.currentUser != null;
  }
}
