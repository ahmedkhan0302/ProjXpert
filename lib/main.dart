import 'package:flutter/material.dart';
import 'package:projxpert/pages/login_page.dart';
import 'package:projxpert/pages/start_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StartPage(),
      routes: {
        //'/signup': (context) => SignupPage(),
        '/login': (context) => const LoginPage(),
        //'/change_password': (context) => ChangePasswordPage(),
      },
    );
  }
}
