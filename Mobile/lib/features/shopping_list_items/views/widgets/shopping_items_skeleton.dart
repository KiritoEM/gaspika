import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class ShoppingItemsSkeleton extends StatelessWidget {
  const ShoppingItemsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 7,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return const SkeletonLine(
          style: SkeletonLineStyle(
            height: 100,
            width: double.infinity,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        );
      },
    );
  }
}
