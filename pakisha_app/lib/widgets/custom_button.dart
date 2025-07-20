import 'package:flutter/material.dart';

class CustomSocialButton extends StatelessWidget {
  final String label;
  final String assetPath;
  final VoidCallback onPressed;

  const CustomSocialButton({
    required this.label,
    required this.assetPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: Size(double.infinity, 50),
      ),
      icon: Image.asset(assetPath, height: 24),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
