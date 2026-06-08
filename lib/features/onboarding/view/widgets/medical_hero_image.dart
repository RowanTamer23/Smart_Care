import 'package:flutter/material.dart';

class MedicalHeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background effect
        Container(
          width: double.infinity,
          height: 280,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8EC5D8),
                Color(0xFF6BA8C0),
                Color(0xFF4A8FA8),
              ],
            ),
          ),
        ),
        // Laptop silhouette
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          top: 0,
          child: Image.asset(
            'assets/images/hero.jpg',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
