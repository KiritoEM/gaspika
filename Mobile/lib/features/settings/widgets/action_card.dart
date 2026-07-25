import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;
  final bool isDestructive;

  const ActionCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = isDestructive
        ? AppColors.destructive
        : AppColors.foreground;

    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDestructive
                  ? AppColors.destructive.withValues(alpha: 0.25)
                  : const Color.fromARGB(255, 243, 242, 242),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                spacing: 16,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: 26,
                    colorFilter: isDestructive
                        ? const ColorFilter.mode(
                            AppColors.destructive,
                            BlendMode.srcIn,
                          )
                        : null,
                  ),

                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 16, color: foregroundColor),
                    ),
                  ),

                  Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: isDestructive
                        ? AppColors.destructive
                        : AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
