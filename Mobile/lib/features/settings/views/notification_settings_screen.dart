// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:gaspika_mobile/features/settings/widgets/notification_preference_tile.dart';
import 'package:gaspika_mobile/features/settings/widgets/settings_sub_appbar.dart';
import 'package:gaspika_mobile/shared/error_state.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();

    SettingsViewmodel settingsVm = Provider.of<SettingsViewmodel>(
      context,
      listen: false,
    );

    Future.microtask(() async {
      await settingsVm.fetchNotificationPreferences();
    });
  }

  Future handleToggle(
    SettingsViewmodel settingsVm, {
    bool? pushEnabled,
    bool? foodExpirationEnabled,
    bool? listExpirationEnabled,
  }) async {
    await settingsVm.togglePreference(
      pushEnabled: pushEnabled,
      foodExpirationEnabled: foodExpirationEnabled,
      listExpirationEnabled: listExpirationEnabled,
    );

    if (!mounted) return;

    if (settingsVm.hasUpdatePreferencesError) {
      Toastify.show(
        context,
        message: settingsVm.updatePreferencesErrorMessage,
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = Provider.of<SettingsViewmodel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsSubAppbar(
        title: 'Notification',
        onGoBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 8),
          child: _buildBody(settingsVm),
        ),
      ),
    );
  }

  Widget _buildBody(SettingsViewmodel settingsVm) {
    if (settingsVm.hasPreferencesError) {
      return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: ErrorState(
          text: settingsVm.preferencesErrorMessage,
          onRefresh: () => settingsVm.fetchNotificationPreferences(),
        ),
      );
    }

    if (settingsVm.isLoadingPreferences || settingsVm.preferences == null) {
      return _buildSkeleton();
    }

    final preferences = settingsVm.preferences!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Choisissez les alertes que vous souhaitez recevoir sur cet appareil.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mutedForeground,
              ),
            ),
          ),

          NotificationPreferenceTile(
            title: 'Notifications push',
            subtitle: 'Activer ou désactiver toutes les notifications',
            value: preferences.pushEnabled,
            onChanged: (value) =>
                handleToggle(settingsVm, pushEnabled: value),
          ),

          NotificationPreferenceTile(
            title: 'Aliments proches de péremption',
            subtitle: 'Être alerté avant qu\'un aliment expire',
            value: preferences.foodExpirationEnabled,
            enabled: preferences.pushEnabled,
            onChanged: (value) =>
                handleToggle(settingsVm, foodExpirationEnabled: value),
          ),

          NotificationPreferenceTile(
            title: 'Rappel de liste de courses',
            subtitle: 'Être alerté des aliments non achetés en fin de semaine',
            value: preferences.listExpirationEnabled,
            enabled: preferences.pushEnabled,
            onChanged: (value) =>
                handleToggle(settingsVm, listExpirationEnabled: value),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        3,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: SkeletonLine(
            style: SkeletonLineStyle(
              height: 82,
              width: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
