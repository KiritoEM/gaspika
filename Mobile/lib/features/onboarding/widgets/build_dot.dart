// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class BuildDot extends StatelessWidget {
  bool isActive = false;

  BuildDot({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      width: isActive ? 35 : 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isActive ? AppColors.primary : Colors.grey[300],
      ),
    );
  }
}
