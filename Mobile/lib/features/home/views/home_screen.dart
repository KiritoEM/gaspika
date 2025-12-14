// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/home/viewmodels/home_viewmodel.dart';
import 'package:gaspika_mobile/features/home/widgets/avalaible_product_card.dart';
import 'package:gaspika_mobile/features/home/widgets/main_appbar.dart';
import 'package:gaspika_mobile/features/home/widgets/weekly_shopping_section.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
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

    Future.microtask(() async {
      final homeVm = Provider.of<HomeViewModel>(context, listen: false);

      await homeVm.fetchUserInfo();
      await homeVm.fetchAvailableFoodCount();
      await homeVm.fetchShoppingWeekItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final HomeViewModel homeVm = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72),
        child: MainAppbar(
          userName:
              Provider.of<HomeViewModel>(context).userName ?? 'Utilisateur',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(23, 28, 23, 23),
            child: Column(
              children: [
                // Avalaible product
                homeVm.isLoadingShopping
                    ? SkeletonLine(
                        style: SkeletonLineStyle(
                          height: 100,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      )
                    : AvalaibleProductCard(
                        productCount: homeVm.availableFoodCount,
                      ),

                SizedBox(height: 28),

                // Weekly shopping
                WeeklyShoppingSection(
                  isLoading: homeVm.isLoadingShopping,
                  shoppingListItems: homeVm.shoppingWeekItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
