import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn;

  // Dependency injection via constructor
  AuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']);

  Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
}
