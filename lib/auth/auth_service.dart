import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn;
  final FlutterSecureStorage _storage;

  AuthService({GoogleSignIn? googleSignIn, FlutterSecureStorage? storage})
    : _googleSignIn =
          googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']),
      _storage = storage ?? const FlutterSecureStorage();

  Future<GoogleSignInAccount?> login() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken != null) {
        await _storage.write(key: 'accessToken', value: googleAuth.accessToken);
      }
      if (googleAuth.idToken != null) {
        await _storage.write(key: 'idToken', value: googleAuth.idToken);
      }
    }
    return googleUser;
  }

  Future<String?> getIdToken() => _storage.read(key: 'idToken');
}
