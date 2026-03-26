import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/utils/date.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:go_router/go_router.dart';

class NotificationCard extends StatelessWidget {
  String details;
  String createdAt;
  String? image;
  NotificationTypeEnum type;
  String route;

  NotificationCard({
    super.key,
    required this.details,
    required this.createdAt,
    required this.type,
    required this.route,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(route);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 23),
        child: Row(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                spacing: 14,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(type, image),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(
                          details,
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.titleMedium?.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Row(
                          spacing: 4,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/clock.svg',
                              width: 16,
                              height: 16,
                            ),

                            Text(
                              DateUtilities.getDatesInterval(
                                    DateTime.parse(createdAt).toUtc(),
                                  ) ??
                                  '',
                              style: TextStyle(
                                fontSize: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.fontSize!,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => {},
              child: Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.more_horiz,
                  size: 22,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationTypeEnum type, String? imagePath) {
    if (type == NotificationTypeEnum.food_expiration) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 56,
          height: 56,
          color: AppColors.surface,
          child: Image.network(
            imagePath ?? '',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child; // image chargée

              return SkeletonLine(
                style: SkeletonLineStyle(
                  height: double.infinity,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.shopping_basket,
                size: 30,
                color: AppColors.mutedForeground,
              );
            },
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 58,
          height: 58,
          color: AppColors.secondary,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/pajamas_planning.svg',
              width: 30,
              height: 30,
            ),
          ),
        ),
      );
    }
  }
}
