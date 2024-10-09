import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final void Function() onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Sign in user function
  void signUserIn() async {
    // Show loading indicator
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Try to sign in the user with provided email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      // If successful, dismiss the loading indicator
      Navigator.pop(context); // This pops the CircularProgressIndicator
    } on FirebaseAuthException catch (e) {
      // If there's an error, dismiss the loading indicator first
      Navigator.pop(context);

      // Show error message dialog with the appropriate error message
      showErrorMessage(getFirebaseErrorMessage(e.code));
    }
  }

  // Convert Firebase error codes to user-friendly messages
  String getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      default:
        return 'An unknown error occurred.';
    }
  }

  // Show error message dialog
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.purple.shade100, Colors.purple.shade400],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade200,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextField(
                      label: 'Email ID', controller: usernameController),
                  MyTextField(
                    label: 'Password',
                    isPassword: true,
                    controller: passwordController,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/change_password');
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.purple.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: signUserIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onTap,
                    child: Text(
                      'New user? SIGNUP',
                      style: TextStyle(color: Colors.purple.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
