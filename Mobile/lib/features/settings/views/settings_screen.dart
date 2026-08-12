// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:gaspika_mobile/features/settings/widgets/action_card.dart';
import 'package:gaspika_mobile/features/settings/widgets/logout_confirmation_dialog.dart';
import 'package:gaspika_mobile/features/settings/widgets/settings_appbar.dart';
import 'package:gaspika_mobile/features/settings/widgets/settings_skeleton.dart';
import 'package:gaspika_mobile/features/settings/widgets/user_infos.dart';
import 'package:gaspika_mobile/shared/app_bottom_navigation.dart';
import 'package:gaspika_mobile/shared/error_state.dart';
import 'package:gaspika_mobile/shared/loader_with_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();

    SettingsViewmodel settingsVm = Provider.of<SettingsViewmodel>(
      context,
      listen: false,
    );

    Future.microtask(() async {
      await settingsVm.fetchUserInfo();
    });
  }

  Future handleLogout(SettingsViewmodel settingsVm) async {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      useRootNavigator: true,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, __) {
        return LoaderWithOverlay(text: 'Déconnexion en cours');
      },
    );

    await settingsVm.logout();

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop(true);

    Toastify.show(
      context,
      message: 'Vous avez été déconnecté.',
      type: ToastType.success,
    );

    context.go(NavigationConstant.DEFAULT_ROUTE);
  }

  void confirmLogout(SettingsViewmodel settingsVm) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return LogoutConfirmationDialog(
          onLogout: () async => await handleLogout(settingsVm),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SettingsViewmodel settingsVm = Provider.of<SettingsViewmodel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppbar(
        onLogout: () async => confirmLogout(settingsVm),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(23),
          child: _buildBody(settingsVm),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildBody(SettingsViewmodel settingsVm) {
    if (settingsVm.hasError) {
      return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: ErrorState(
          text: settingsVm.errorMessage,
          onRefresh: () => settingsVm.fetchUserInfo(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (!settingsVm.isLoadingUser)
            Column(
              children: [
                UserInfos(fullName: settingsVm.fullName),

                SizedBox(height: 40),

                _buildActions(),
              ],
            )
          else
            SettingsSkeleton(),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      spacing: 8,
      children: [
        ActionCard(
          title: 'Informations du compte',
          iconPath: 'assets/icons/profile-circle.svg',
          onTap: () => context.push(NavigationConstant.SETTINGS_ACCOUNT_ROUTE),
        ),

        ActionCard(
          title: 'Securités',
          iconPath: 'assets/icons/lock.svg',
          onTap: () => context.push(NavigationConstant.SETTINGS_SECURITY_ROUTE),
        ),

        ActionCard(
          title: 'Notification',
          iconPath: 'assets/icons/notification.svg',
          onTap: () =>
              context.push(NavigationConstant.SETTINGS_NOTIFICATIONS_ROUTE),
        ),
      ],
    );
  }
}
