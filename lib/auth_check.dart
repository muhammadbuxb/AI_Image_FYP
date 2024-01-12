import 'package:ai_image/Auth/login.dart';
import 'package:ai_image/Pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while checking authentication state.
        } else if (snapshot.hasData) {
          // User is already logged in, navigate to the home page.
          return HomePage();
        } else {
          // User is not logged in, navigate to the login page.
          return LoginView();
        }
      },
    );
  }
}
