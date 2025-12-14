import 'package:flutter/material.dart';

class AuthLinearBg extends StatelessWidget {
  const AuthLinearBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFB800),
            Color(0xFFFFE082),
            Color(0xFFFFF8E1),
            Colors.white,
            Colors.white,
          ],
          stops: [0.0, 0.3, 0.6, 0.85, 0.0],
        ),
      ),
    );
  }
}
