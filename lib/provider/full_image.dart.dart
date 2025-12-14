import 'package:flutter/material.dart';

class FullImageScreen extends StatelessWidget {
  final String image;

  const FullImageScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Image.asset(image, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
