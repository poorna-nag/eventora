import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B5BD6), Color(0xFF7A3EE6), Color(0xFF9A4EDB)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -50, left: -40, child: _glowCircle(180)),
            Positioned(bottom: 100, right: -60, child: _glowCircle(220)),

            child,
          ],
        ),
      ),
    );
  }

  Widget _glowCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
      ),
    );
  }
}
