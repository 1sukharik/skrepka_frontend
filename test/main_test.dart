// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:skrepka/custom_widgets/auth_button.dart';
import 'package:skrepka/auth/auth_service.dart';
import 'package:skrepka/home_page.dart';
import 'package:skrepka/logged_in_page.dart';
import 'package:skrepka/main.dart';

import 'main_test.mocks.dart';

// Since GoogleSignInAccount and GoogleSignInAuthentication are real classes from a package,
// we can create fake implementations for testing purposes.
class FakeGoogleSignInAccount with Fake implements GoogleSignInAccount {
  @override
  Future<GoogleSignInAuthentication> get authentication async =>
      FakeGoogleSignInAuthentication();

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
}

class FakeGoogleSignInAuthentication extends Fake
    implements GoogleSignInAuthentication {
  @override
  String? get idToken => 'test_id_token_123456789012345678901234567890';

  @override
  String? get accessToken => 'test_access_token_123456789012345678901234567890';
}

class FakeNavigatorObserver extends NavigatorObserver {
  Route? pushedRoute;
  @override
  void didPush(Route route, Route? previousRoute) {
    pushedRoute = route;
  }
}

@GenerateMocks([AuthService])
void main() {
  group('main()', () {
    testWidgets('sets up providers and runs MyApp', (tester) async {
      // Build the app's widget tree with providers.
      await tester.pumpWidget(
        MultiProvider(
          providers: [Provider<AuthService>(create: (_) => AuthService())],
          child: const MyApp(),
        ),
      );

      // Verify that MyApp is the root widget.
      expect(find.byType(MyApp), findsOneWidget);
      // Verify that MaterialApp is rendered by MyApp.
      expect(find.byType(MaterialApp), findsOneWidget);
      // Verify that MyHomePage is rendered as the home page.
      expect(find.byType(MyHomePage), findsOneWidget);
    });
  });

  group('MyHomePage', () {
    // Late variables are initialized when they are first used.
    late MockAuthService mockAuthService;
    late FakeNavigatorObserver fakeNavigatorObserver;

    // This setUp function runs before each test.
    setUp(() {
      // Create a new mock instance for each test to ensure they are isolated.
      mockAuthService = MockAuthService();
      fakeNavigatorObserver = FakeNavigatorObserver();
    });

    // A helper function to build the widget tree with necessary providers.
    // This avoids code duplication in each test.
    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          // Provide the mock AuthService instead of the real one.
          Provider<AuthService>.value(value: mockAuthService),
        ],
        child: MaterialApp(
          home: const MyHomePage(),
          navigatorObservers: [fakeNavigatorObserver],
        ),
      );
    }

    testWidgets('renders AnotherAuthButton initially', (
      WidgetTester tester,
    ) async {
      // Build the widget tree.
      await tester.pumpWidget(buildTestWidget());

      // Check if the authentication button is present.
      expect(find.byType(AnotherAuthButton), findsOneWidget);
      // Check if the logged in page is not present.
      expect(find.byType(LoggedInPage), findsNothing);
    });

    testWidgets('navigates to LoggedInPage on successful login', (
      WidgetTester tester,
    ) async {
      // Arrange: Configure the mock to return a valid user on login.
      when(
        mockAuthService.login(),
      ).thenAnswer((_) async => FakeGoogleSignInAccount());

      // Act: Build the widget and tap the button.
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byType(AnotherAuthButton));
      await tester.pumpAndSettle();

      // Assert: Verify that a push navigation event happened.
      expect(fakeNavigatorObserver.pushedRoute, isA<MaterialPageRoute>());
      final pushedRoute =
          fakeNavigatorObserver.pushedRoute as MaterialPageRoute;
      expect(pushedRoute.builder(MockBuildContext()), isA<LoggedInPage>());
    });

    testWidgets('does not navigate when login is cancelled by user', (
      WidgetTester tester,
    ) async {
      // Arrange: Configure the mock to return null, simulating user cancellation.
      when(mockAuthService.login()).thenAnswer((_) async => null);

      // Act: Build the widget and tap the button.
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byType(AnotherAuthButton));
      // Rebuild the widget tree.
      await tester.pumpAndSettle();

      // Assert: Check that we are still on the home page.
      expect(find.byType(MyHomePage), findsOneWidget);
      // Check that the logged in page was not pushed.
      expect(find.byType(LoggedInPage), findsNothing);
    });

    testWidgets('shows AlertDialog when login throws an exception', (
      WidgetTester tester,
    ) async {
      // Arrange: Configure the mock to throw an error on login.
      final exception = Exception('Network error');
      when(mockAuthService.login()).thenThrow(exception);

      // Act: Build the widget and tap the button.
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byType(AnotherAuthButton));
      // Rebuild the widget tree to show the dialog.
      await tester.pump();

      // Assert: Check that an AlertDialog is displayed.
      expect(find.byType(AlertDialog), findsOneWidget);
      // Check that the dialog contains the error message.
      expect(find.text('Ошибка: $exception'), findsOneWidget);
      // Check that we are still on the home page.
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(LoggedInPage), findsNothing);
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
