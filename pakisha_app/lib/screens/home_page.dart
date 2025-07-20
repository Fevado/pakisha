import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
   final String userEmail;
  // const HomePage({super.key});
  const HomePage({super.key, required this.userEmail});
  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String role = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          role = doc['role'] ?? 'Unknown';
          email = user!.email ?? 'User';
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("PAKISHA Home"),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome $email",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "You are logged in as: $role",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            if (role == 'donor') ...[
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/donor'),
                child: const Text("Go to Donor Dashboard"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/post-food'),
                child: const Text("Post Food"),
              ),
            ] else if (role == 'recipient') ...[
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/recipient'),
                child: const Text("Go to Recipient Dashboard"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/map'),
                child: const Text("View Map"),
              ),
            ] else ...[
              const CircularProgressIndicator(),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/map'),
              child: const Text("Open Map"),
            ),
          ],
        ),
      ),
    );
  }
}

