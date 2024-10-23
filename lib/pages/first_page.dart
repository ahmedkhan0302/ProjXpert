import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projxpert/pages/calendar_page.dart';
import 'package:projxpert/pages/home_page.dart';
import 'package:projxpert/pages/inpire_page.dart';
import 'package:projxpert/pages/profile_page.dart'; // Import your ProfilePage
import 'package:projxpert/pages/tasks_page.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _selectedIndex = 0;
  String? userid;

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List _pages = [
    const HomePage(),
    const TasksPage(),
    const CalendarPage(),
    const InspirePage()
  ];

  void _navigateToProfile() {
    userid = FirebaseAuth.instance.currentUser!.uid;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ProfilePage(userID: userid)), // Navigate to ProfilePage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 95),
          child: Text('P r o j X p e r t'),
        ),
        backgroundColor: Colors.deepPurple[200],
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed:
                _navigateToProfile, // Add this line for profile navigation
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.deepPurple[200],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.task),
            label: 'Tasks',
            backgroundColor: Colors.deepPurple[200],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: 'Calendar',
            backgroundColor: Colors.deepPurple[200],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.lightbulb),
            label: 'Idea',
            backgroundColor: Colors.deepPurple[200],
          ),
        ],
      ),
    );
  }
}
