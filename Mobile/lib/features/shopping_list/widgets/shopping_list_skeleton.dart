import 'package:flutter/cupertino.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class ShoppingListSkeleton extends StatelessWidget {
  const ShoppingListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        7,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonLine(
            style: SkeletonLineStyle(
              height: 85,
              width: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
