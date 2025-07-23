// ignore_for_file: avoid_print

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skrepka/auth/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([GoogleSignIn, FlutterSecureStorage])
void main() {
  late AuthService authService;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockFlutterSecureStorage mockFlutterSecureStorage;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    authService = AuthService(
      googleSignIn: mockGoogleSignIn,
      storage: mockFlutterSecureStorage,
    );
  });

  group('AuthService', () {
    final fakeAccount = FakeGoogleSignInAccount();
    final fakeAuth = FakeGoogleSignInAuthentication();

    test('login saves tokens on successful sign in', () async {
      // Arrange
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => fakeAccount);
      when(
        mockFlutterSecureStorage.write(
          key: 'accessToken',
          value: anyNamed('value'),
        ),
      ).thenAnswer((_) async {});
      when(
        mockFlutterSecureStorage.write(
          key: 'idToken',
          value: anyNamed('value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await authService.login();

      // Assert
      verify(
        mockFlutterSecureStorage.write(
          key: 'accessToken',
          value: fakeAuth.accessToken,
        ),
      ).called(1);
      verify(
        mockFlutterSecureStorage.write(key: 'idToken', value: fakeAuth.idToken),
      ).called(1);
    });

    test('login calls GoogleSignIn.signIn', () async {
      // Arrange
      when(
        mockGoogleSignIn.signIn(),
      ).thenAnswer((_) async => null); // Успешный, но отмененный вход
      // Act
      await authService.login();
      // Assert
      verify(mockGoogleSignIn.signIn()).called(1);
    });

    test('login returns GoogleSignInAccount on successful sign in', () async {
      // Arrange
      final account = FakeGoogleSignInAccount();
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => account);
      // Act
      final result = await authService.login();
      // Assert
      expect(result, account);
    });

    test('login returns null when sign in is cancelled', () async {
      // Arrange
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
      // Act
      final result = await authService.login();
      // Assert
      expect(result, isNull);
    });

    test('login throws exception when GoogleSignIn throws', () async {
      // Arrange
      final exception = Exception('Sign in failed');
      when(mockGoogleSignIn.signIn()).thenThrow(exception);
      // Act & Assert
      expect(() => authService.login(), throwsA(isA<Exception>()));
    });

    test('uses default GoogleSignIn if none is provided', () {
      // This test checks the constructor's default behavior.
      // It's more of a structural test.
      final service = AuthService();
      expect(service, isNotNull);
    });

    test('getIdToken returns stored token', () async {
      // Arrange
      const fakeToken = 'test_id_token';
      when(
        mockFlutterSecureStorage.read(key: 'idToken'),
      ).thenAnswer((_) async => fakeToken);
      // Act
      final token = await authService.getIdToken();
      // Assert
      expect(token, fakeToken);
      verify(mockFlutterSecureStorage.read(key: 'idToken')).called(1);
    });
  });
}

// Fake class to represent a successful sign-in result.
class FakeGoogleSignInAccount implements GoogleSignInAccount {
  @override
  String get displayName => 'Test User';
  @override
  String get email => 'test@example.com';
  @override
  String get id => '12345';
  @override
  String? get photoUrl => null;
  @override
  String? get serverAuthCode => null;

  @override
  Future<GoogleSignInAuthentication> get authentication async =>
      FakeGoogleSignInAuthentication();
  @override
  Future<void> clearAuthCache() => throw UnimplementedError();
  @override
  Future<GoogleSignInAccount?> disconnect() => throw UnimplementedError();
  @override
  Future<Map<String, String>> get authHeaders => throw UnimplementedError();
}

class FakeGoogleSignInAuthentication implements GoogleSignInAuthentication {
  @override
  String? get accessToken => 'fake_access_token';

  @override
  String? get idToken => 'fake_id_token';

  @override
  String? get serverAuthCode => 'fake_server_auth_code';
}
