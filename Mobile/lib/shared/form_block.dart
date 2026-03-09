import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class FormBlock extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isRequired;
  final bool isLoading;

  const FormBlock({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        isLoading
            ? SkeletonLine(
                style: SkeletonLineStyle(
                  height: 50,
                  width: double.infinity,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              )
            : child,
      ],
    );
  }
}
