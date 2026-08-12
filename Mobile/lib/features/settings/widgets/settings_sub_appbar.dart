import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingsSubAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onGoBack;

  const SettingsSubAppbar({
    super.key,
    required this.title,
    required this.onGoBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/chevron-left.svg', width: 40),
          tooltip: 'Retour',
          onPressed: () => onGoBack(),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        titleSpacing: 4,
      ),
    );
  }
}
