import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String iconPath;

  const ActionCard({super.key, required this.title, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 243, 242, 242),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),

        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
	  spacing: 16,
            children: [
              SvgPicture.asset(iconPath, width: 26),
              Text(title, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
