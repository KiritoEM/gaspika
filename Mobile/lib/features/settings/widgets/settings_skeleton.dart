import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(
                width: 120,
                height: 120,
                child: SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 120,
                    width: 120,
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 200,
                height: 20,
                child: SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 20,
                    width: 200,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 42),

        Column(
          children: List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SkeletonLine(
                style: SkeletonLineStyle(
                  height: 75,
                  width: double.infinity,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
