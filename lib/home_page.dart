import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrepka/auth/auth_service.dart';
import 'package:skrepka/custom_widgets/auth_button.dart';
import 'package:skrepka/logged_in_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future googleAuth(BuildContext context) async {
    final authService = context.read<AuthService>();
    try {
      final googleUser = await authService.login();
      if (googleUser == null) {
        return;
      }

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoggedInPage(user: googleUser)),
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
