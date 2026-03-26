import 'package:flutter/cupertino.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class NotificationsListSkeleton extends StatelessWidget {
  const NotificationsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: List.generate(7, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const SkeletonLine(
                style: SkeletonLineStyle(
                  height: 56,
                  width: 56,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 14,
                        width: double.infinity,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 8),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 12,
                        width: 180,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 10),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 12,
                        width: 120,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
