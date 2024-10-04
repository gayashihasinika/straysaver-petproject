import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = '';
  String email = '';
  String phoneNumber = '';
  int age = 0;
  XFile? _image; // Variable to hold the selected image
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(
          user.uid).get();
      if (userData.exists) {
        setState(() {
          name = userData['name'];
          email = user.email!;
          phoneNumber = userData['phone_number'];
          age = userData['age'];
        });
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
      // Background colour
      Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.orange.shade300, Colors.orange.shade500, Colors.orange.shade700],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ),
    ),
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                              child: _image == null
                                  ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        const Text(
                          'Profile Information',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileInfoTile(
                                  'Name:', name, icon: Icons.person),
                              _buildProfileInfoTile(
                                  'Email:', email, icon: Icons.email),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileInfoTile(
                                  'Phone Number:', phoneNumber,
                                  icon: Icons.phone),
                              _buildProfileInfoTile(
                                  'Age:', age.toString(), icon: Icons.cake),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildProfileInfoTile(
                            'Name:', name, icon: Icons.person),
                        _buildProfileInfoTile(
                            'Email:', email, icon: Icons.email),
                        _buildProfileInfoTile(
                            'Phone Number:', phoneNumber, icon: Icons.phone),
                        _buildProfileInfoTile(
                            'Age:', age.toString(), icon: Icons.cake),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    ],
      ),
    );
  }

  Widget _buildProfileInfoTile(String title, String subtitle,
      {required IconData icon}) {
    return Card(
      elevation: 4, // Adds a shadow to create a layered effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            15.0), // Rounded corners for a soft look
      ),
      color: Colors.white, // Background color for the card
      child: ListTile(
        leading: Icon(icon, color: Colors.orangeAccent),
        // Leading icon with a custom color
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold, // Makes the title text bold
            color: Colors.grey[700], // Custom color for the title text
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black, // Subtitle text style
          ),
        ),
        contentPadding: EdgeInsets.all(
            12.0), // Padding inside the ListTile to give space around text
      ),
    );
  }
}
