import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrepka/auth_button.dart';
import 'package:skrepka/auth_service.dart';
import 'package:skrepka/logged_in_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [Provider<AuthService>(create: (_) => AuthService())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future googleAuth(BuildContext context) async {
    final authService = context.read<AuthService>();
    try {
      final googleUser = await authService.login();
      if (googleUser == null) {
        print("Вход был отменен пользователем.");
        return;
      }

      final googleAuth = await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;
      print("Пользователь успешно вошел!");
      print(
        "ID Token: ${idToken?.substring(0, 30)}...",
      ); // Печатаем для проверки
      print("Access Token: ${accessToken?.substring(0, 30)}...");

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoggedInPage(user: googleUser);
          },
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(content: Text("Ошибка: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnotherAuthButton(
          onTap: () => googleAuth(context),
          titleText: "Continue with Google",
          imgPath: 'assets/svg/googleLogo.svg',
          buttonColor: Colors.white,
          textColor: Colors.black,
        ),
      ),
    );
  }
}
