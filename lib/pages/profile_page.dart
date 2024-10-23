import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String? userID;
  const ProfilePage({super.key, required this.userID});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? email;
  String? phoneNumber;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    if (widget.userID != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'];
          email = userDoc['email'];
          phoneNumber = userDoc['phno'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple[200], // Change to purple
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                // Center the entire content
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center vertically
                  children: [
                    _buildProfilePhoto(),
                    const SizedBox(height: 20),
                    _buildUsername(),
                    const SizedBox(height: 10),
                    _buildContactDetails(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePhoto() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage(
              'assets/profile_photo.png'), // Replace with your image path
          fit: BoxFit.cover,
        ),
        border: Border.all(
            color: Colors.purpleAccent, width: 4), // Change to purple
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
    );
  }

  Widget _buildUsername() {
    return Text(
      username ?? 'Username',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.purpleAccent, // Change to purple
      ),
      textAlign: TextAlign.center, // Center align the username
    );
  }

  Widget _buildContactDetails() {
    return Column(
      children: [
        Text(
          'Email: ${email ?? 'Email'}',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center, // Center align the email
        ),
        const SizedBox(height: 5),
        Text(
          'Phone: ${phoneNumber ?? 'Phone Number'}',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center, // Center align the phone number
        ),
      ],
    );
  }
}
