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
  static const _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '1057417146171-kmie6i3dh6giduvuopejeqi2nsqh76de.apps.googleusercontent.com',
  );

  static final _googleSignIn = GoogleSignIn.instance;
  static bool _googleInitialized = false;

  static Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize(serverClientId: _serverClientId);
    _googleInitialized = true;
  }

  static Future<UserProfile> signInWithGoogle() async {
    if (_devAuth) return _devUser;

    await _ensureGoogleInitialized();

    // Cierra cualquier sesión previa para forzar el selector de cuenta.
    await _googleSignIn.signOut();

    GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw Exception('Login cancelado por el usuario');
      }
      throw Exception(
          'Error en Google Sign-In: ${e.description ?? e.code.name}');
    } catch (e) {
      throw Exception('Error en Google Sign-In: $e');
    }

    // En google_sign_in 7.x `authentication` es un getter síncrono que solo
    // expone el idToken (los access tokens de scopes van por authorizationClient).
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception(
          'No se obtuvo el ID token. Verifica que Google Sign-In esté habilitado en Firebase Auth.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
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

    await _ensureGoogleInitialized();
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
