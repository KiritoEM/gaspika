// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/home/viewmodels/home_viewmodel.dart';
import 'package:gaspika_mobile/features/home/widgets/avalaible_product_card.dart';
import 'package:gaspika_mobile/features/home/widgets/home_appbar.dart';
import 'package:gaspika_mobile/features/home/widgets/weekly_shopping_section.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:gaspika_mobile/shared/error_state.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    HomeViewModel homeVm = Provider.of<HomeViewModel>(context, listen: false);

    Future.microtask(() async {
      await Future.wait([
        homeVm.fetchUserInfo(),
        homeVm.fetchAvailableFoodCount(),
        homeVm.fetchShoppingWeekItems(),
        homeVm.fetchNotificationCount(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final HomeViewModel homeConsumerVm = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: HomeAppbar(
          userName: homeConsumerVm.userName ?? 'Utilisateur',
          notificationCount: homeConsumerVm.notificationCount,
          isLoading: homeConsumerVm.isLoadingUser,
          onNavigateToNofication: () async {
            await context.push(NavigationConstant.NOTIFICATION_ROUTE);
            await homeConsumerVm.refreshAll();
          },
        ),
      ),
      body: SafeArea(child: _buildBody(homeConsumerVm)),
    );
  }

  Widget _buildBody(HomeViewModel homeVm) {
    if (homeVm.hasError && homeVm.errorType != NetworkErrorType.notFound) {
      return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: ErrorState(
          text: homeVm.errorMessage,
          onRefresh: () => homeVm.refreshAll(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(23),
        child: Column(
          children: [
            // Available product
            homeVm.isLoadingShopping
                ? SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 100,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  )
                : AvalaibleProductCard(productCount: homeVm.availableFoodCount),

            const SizedBox(height: 28),

            // Weekly shopping
            WeeklyShoppingSection(
              isLoading: homeVm.isLoadingShopping,
              shoppingListItems: homeVm.shoppingWeekItems,
            ),
          ],
        ),
      ),
    );
  }
}
