import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoggedInPage extends StatelessWidget {
  const LoggedInPage({super.key, required this.user});
  final GoogleSignInAccount user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 120),
            Text(user.displayName!),
            SizedBox(height: 10),
            Text(user.email),
          ],
        ),
      ),
    );
  }
}
