import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/home/viewmodels/home_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final bool isLoading;

  const HomeAppbar({
    super.key,
    required this.userName,
    required this.isLoading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final homeVm = Provider.of<HomeViewModel>(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(4.5),
          child: SvgPicture.asset('assets/icons/gaspika-logo.svg'),
        ),
        titleSpacing: 6,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedForeground,
              ),
            ),

            isLoading
                ? SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 20,
                      width: 100,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  )
                : Text(
                    userName,
                    style: TextStyle(
                      fontSize: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              homeVm.logout();
              context.go('/login');
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
