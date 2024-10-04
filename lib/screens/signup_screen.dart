import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController = TextEditingController();

  String errorMessage = '';

  Future<void> signUpUser() async {
    if (passwordController.text != retypePasswordController.text) {
      setState(() {
        errorMessage = "Passwords do not match!";
      });
      return;
    }

    try {
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );

      
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': nameController.text,
        'age': int.parse(ageController.text),
        'phone_number': phoneNumberController.text,
        'username': usernameController.text,
        'email': userCredential.user?.email,
      });

      
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
      // Background colour

      Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.orange.shade400, Colors.orange.shade600, Colors.orange.shade800],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ),
    ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.person, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age',
                  labelStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.cake, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number',
                  labelStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.phone, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username (Email)',
                  labelStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.person, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: retypePasswordController,
                decoration: InputDecoration(labelText: 'confirm Password',
                  labelStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                obscureText: true,
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: signUpUser,
                child: const Text('Sign Up'),
              ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.black),
                ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
  ],
    ),
    );
  }
}





