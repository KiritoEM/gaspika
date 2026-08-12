import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:gaspika_mobile/shared/button_with_loader.dart';
import 'package:gaspika_mobile/shared/password_input_field.dart';
import 'package:provider/provider.dart';

class ChangePasswordForm extends StatefulWidget {
  final VoidCallback onSubmit;

  const ChangePasswordForm({super.key, required this.onSubmit});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = Provider.of<SettingsViewmodel>(context);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          PasswordInputField(
            label: 'Mot de passe actuel',
            controller: settingsVm.currentPasswordController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Entrez votre mot de passe actuel.';
              }

              return null;
            },
          ),

          PasswordInputField(
            label: 'Nouveau mot de passe',
            controller: settingsVm.newPasswordController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Entrez votre nouveau mot de passe.';
              }

              if (value.trim().length < 8) {
                return 'Le mot de passe doit contenir au moins 8 caractères.';
              }

              if (value == settingsVm.currentPasswordController.text) {
                return 'Le nouveau mot de passe doit être différent de l\'ancien.';
              }

              return null;
            },
          ),

          Text(
            'Utilisez au moins 8 caractères. Vous resterez connecté après la modification.',
            style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
          ),

          ButtonWithLoader(
            text: 'Modifier le mot de passe',
            loadingText: 'Modification',
            isLoading: settingsVm.isChangingPassword,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
