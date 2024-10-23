//import 'package:crudtest/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projxpert/pages/first_page.dart';
import 'package:projxpert/pages/login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              //User is signed in
              if (snapshot.hasData) {
                return const FirstPage();
              } else {
                return const LoginOrRegisterPage();
              }
            }));
  }
}
