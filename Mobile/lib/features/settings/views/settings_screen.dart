import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:gaspika_mobile/features/settings/widgets/action_card.dart';
import 'package:gaspika_mobile/features/settings/widgets/settings_appbar.dart';
import 'package:gaspika_mobile/features/settings/widgets/settings_skeleton.dart';
import 'package:gaspika_mobile/features/settings/widgets/user_infos.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    SettingsViewmodel settingsVm = Provider.of<SettingsViewmodel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppbar(onLogout: () async {
       await settingsVm.logout();

       if (!mounted) return;

       context.go(NavigationConstant.DEFAULT_ROUTE);
      }),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(23),
          child: _buildBody(settingsVm),
        ),
      ),
    );
  }

  Widget _buildBody(SettingsViewmodel settingsVm) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (!settingsVm.isLoadingUser)
            Column(
              children: [
                UserInfos(fullName: '${settingsVm.user?.firstName} ${settingsVm.user?.lastName}'),

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
        ),

        ActionCard(title: 'Securités', iconPath: 'assets/icons/lock.svg'),

        ActionCard(
          title: 'Notification',
          iconPath: 'assets/icons/notification.svg',
        ),
      ],
    );
  }
}
