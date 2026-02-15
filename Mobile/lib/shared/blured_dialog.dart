import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BluredDialog extends StatelessWidget {
  final Widget child;
  final bool popOnOutsideDialogTap;

  const BluredDialog({
    super.key,
    required this.child,
    this.popOnOutsideDialogTap = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Stack(
          children: [
            GestureDetector(
              onTap: popOnOutsideDialogTap ? () => context.pop() : null,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Color.fromARGB(88, 228, 226, 226)),
              ),
            ),

            Center(
              child: Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: Opacity(
                  opacity: value,
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
