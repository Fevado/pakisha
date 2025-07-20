import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
// import 'screens/donor_dashboard.dart';
// import 'screens/recipient_dashboard.dart';
// import 'screens/post_food_page.dart';
// import 'screens/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAKISHA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginPage(), // Initial screen
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) {
  final user = FirebaseAuth.instance.currentUser;
  final email = user?.email ?? 'Unknown';
  return HomePage(userEmail: email);
},
        // '/donor': (context) => const DonorDashboard(),
        // '/recipient': (context) => const RecipientDashboard(),
        // '/post-food': (context) => const PostFoodPage(),
        // '/map': (context) => const MapPage(),
      },
    );
  }
}

