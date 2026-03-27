import 'package:flutter/material.dart';
import 'package:name_avatar/name_avatar.dart';

class UserInfos extends StatelessWidget {
  final String fullName;

  const UserInfos({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          NameAvatar(name: fullName, radius: 60, isTwoChar: true),

          SizedBox(height: 16),

          Text(
            fullName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ],
      ),
    );
  }
}
