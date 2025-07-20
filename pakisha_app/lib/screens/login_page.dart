import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();

  void _login() async {
    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Navigate to homepage after login
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
  builder: (context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Unknown';
    return HomePage(userEmail: email);
  },
),
    );
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _resetPassword() {
    if (_emailController.text.isNotEmpty) {
      _authService.sendPasswordReset(_emailController.text.trim());
      _showError('Reset email sent.');
    } else {
      _showError('Enter your email to reset password.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[100], // Login screen exemption from dark theme
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Welcome to PAKISHA",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: const Text("Forgot Password?"),
                ),
              ),

              ElevatedButton(onPressed: _login, child: const Text("Login")),

              const SizedBox(height: 16),

              CustomSocialButton(
                label: "Continue with Google",
                assetPath: "assets/google.png",
                onPressed: () {
                  _authService.signInWithGoogle();
                },
              ),

              CustomSocialButton(
                label: "Continue with Facebook",
                assetPath: "assets/facebook.png",
                onPressed: () {
                  // TODO: Add Facebook login
                },
              ),

              CustomSocialButton(
                label: "Continue with X",
                assetPath: "assets/x.png",
                onPressed: () {
                  // TODO: Add X login
                },
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                },
                child: const Text("Don't have an account? Sign Up"),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
