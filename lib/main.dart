import 'package:flutter/material.dart';
import 'package:projxpert/pages/auth_page.dart';
import 'package:projxpert/pages/calendar_page.dart';
import 'package:projxpert/pages/change_password_page.dart';
import 'package:projxpert/pages/home_page.dart';
import 'package:projxpert/pages/inpire_page.dart';
//import 'package:projxpert/pages/login_page.dart';
import 'package:projxpert/pages/start_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projxpert/pages/tasks_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/auth': (context) => const AuthPage(),
        //'/change_password': (context) => ChangePasswordPage(),
        '/home': (context) => const HomePage(),
        '/task': (context) => const TasksPage(),
        '/calendar': (context) => const CalendarPage(),
        '/inspire': (context) => const InspirePage(),
        '/change_password': (context) => ChangePasswordPage(),
      },
    );
  }
}
