import 'package:flutter/material.dart';
import 'package:projxpert/pages/login_page.dart';
import 'package:projxpert/pages/register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;
  //toggle between login and register
  void toggleView() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: toggleView,
      );
    } else {
      return RegisterPage(
        onTap: toggleView,
      );
    }
  }
}
