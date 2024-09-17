// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projxpert/pages/calendar_page.dart';
import 'package:projxpert/pages/home_page.dart';
import 'package:projxpert/pages/inpire_page.dart';
import 'package:projxpert/pages/tasks_page.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _selectedIndex = 0;

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List _pages = [HomePage(), TasksPage(), CalendarPage(), InspirePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 95),
          child: Text('P r o j X p e r t'),
        ),
        backgroundColor: Colors.deepPurple[200],
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.deepPurple[200],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
            backgroundColor: Colors.deepPurple[200],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
            backgroundColor: Colors.deepPurple[200],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Idea',
            backgroundColor: Colors.deepPurple[200],
          ),
        ],
      ),
    );
  }
}
