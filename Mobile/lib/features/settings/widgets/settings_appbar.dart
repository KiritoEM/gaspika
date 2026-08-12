import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingsAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Future<void> Function() onLogout;

  const SettingsAppbar({super.key, required this.onLogout});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Mon compte',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: () async => await onLogout(),
            icon: SvgPicture.asset('assets/icons/logout.svg', width: 24),
          ),
        ],
      ),
    );
  }
}
