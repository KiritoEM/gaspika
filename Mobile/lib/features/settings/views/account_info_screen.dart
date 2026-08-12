// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:gaspika_mobile/features/settings/widgets/account_info_form.dart';
import 'package:gaspika_mobile/features/settings/widgets/settings_sub_appbar.dart';
import 'package:gaspika_mobile/shared/error_state.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  @override
  void initState() {
    super.initState();

    SettingsViewmodel settingsVm = Provider.of<SettingsViewmodel>(
      context,
      listen: false,
    );

    Future.microtask(() async {
      if (settingsVm.user == null) {
        await settingsVm.fetchUserInfo();
        return;
      }

      settingsVm.hydrateUserFields();
    });
  }

  Future handleUpdateUser(SettingsViewmodel settingsVm) async {
    await settingsVm.updateUserInfo();

    if (!mounted) return;

    if (settingsVm.hasUpdateUserError) {
      Toastify.show(
        context,
        message: settingsVm.updateUserErrorMessage,
        type: ToastType.error,
      );
      return;
    }

    Toastify.show(
      context,
      message: 'Informations modifiées avec succès.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = Provider.of<SettingsViewmodel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsSubAppbar(
        title: 'Informations du compte',
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

    if (settingsVm.isLoadingUser) {
      return _buildSkeleton();
    }

    return SingleChildScrollView(
      child: AccountInfoForm(
        onSubmit: () async => await handleUpdateUser(settingsVm),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      spacing: 20,
      children: List.generate(
        3,
        (index) => const FormBlock(
          label: '',
          isLoading: true,
          child: SizedBox.shrink(),
        ),
      ),
    );
  }
}
