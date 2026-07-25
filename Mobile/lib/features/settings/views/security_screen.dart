// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:gaspika_mobile/features/settings/widgets/action_card.dart';
import 'package:gaspika_mobile/features/settings/widgets/change_password_form.dart';
import 'package:gaspika_mobile/features/settings/widgets/delete_account_dialog.dart';
import 'package:gaspika_mobile/features/settings/widgets/settings_sub_appbar.dart';
import 'package:gaspika_mobile/shared/loader_with_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  @override
  void initState() {
    super.initState();

    SettingsViewmodel settingsVm = Provider.of<SettingsViewmodel>(
      context,
      listen: false,
    );

    Future.microtask(() => settingsVm.resetPasswordFields());
  }

  Future handleChangePassword(SettingsViewmodel settingsVm) async {
    await settingsVm.changePassword();

    if (!mounted) return;

    if (settingsVm.hasChangePasswordError) {
      Toastify.show(
        context,
        message: settingsVm.changePasswordErrorMessage,
        type: ToastType.error,
      );
      return;
    }

    Toastify.show(
      context,
      message: 'Mot de passe modifié avec succès.',
      type: ToastType.success,
    );
  }

  Future handleDeleteAccount(SettingsViewmodel settingsVm) async {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      useRootNavigator: true,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, __) {
        return LoaderWithOverlay(text: 'Suppression en cours');
      },
    );

    await settingsVm.deleteAccount();

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop(true);

    if (settingsVm.hasDeleteAccountError) {
      Toastify.show(
        context,
        message: settingsVm.deleteAccountErrorMessage,
        type: ToastType.error,
      );
      return;
    }

    Toastify.show(
      context,
      message: 'Votre compte a été supprimé.',
      type: ToastType.success,
    );

    context.go(NavigationConstant.DEFAULT_ROUTE);
  }

  void confirmDeleteAccount(SettingsViewmodel settingsVm) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return DeleteAccountDialog(
          onDelete: () async => await handleDeleteAccount(settingsVm),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = Provider.of<SettingsViewmodel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsSubAppbar(
        title: 'Securités',
        onGoBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChangePasswordForm(
                  onSubmit: () async => await handleChangePassword(settingsVm),
                ),

                const SizedBox(height: 48),

                _buildDangerZone(settingsVm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone(SettingsViewmodel settingsVm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          'Zone de danger',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.destructive,
          ),
        ),

        Text(
          'La suppression de votre compte est définitive et ne peut pas être annulée.',
          style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
        ),

        ActionCard(
          title: 'Supprimer mon compte',
          iconPath: 'assets/icons/trash.svg',
          isDestructive: true,
          onTap: () => confirmDeleteAccount(settingsVm),
        ),
      ],
    );
  }
}
