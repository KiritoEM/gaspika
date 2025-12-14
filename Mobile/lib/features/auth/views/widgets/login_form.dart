// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/constants/regex_pattern.dart';
import 'package:gaspika_mobile/features/auth/viewmodels/login_viewmodel.dart';
import 'package:gaspika_mobile/shared/button_with_loader.dart';
import 'package:gaspika_mobile/shared/password_input_field.dart';
import 'package:gaspika_mobile/shared/snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    final loginVm = context.watch<LoginViewModel>();

    return Form(
      key: loginVm.formkey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Votre adresse email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer une adresse email';
              }

              if (!RegExp(RegexPattern.EMAIL_REGEX).hasMatch(value)) {
                return 'Veuillez entrer une adresse email valide';
              }

              return null;
            },
            onSaved: (value) => {
              if (value != null) {loginVm.setEmail(value)},
            },
          ),

          const SizedBox(height: 32),

          PasswordInputField(
            label: 'Votre mot de passe',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer un mot de passe';
              }
              if (value.trim().length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
            onSaved: (value) {
              if (value != null) {
                loginVm.setPassword(value);
              }
            },
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ButtonWithLoader(
              isLoading: loginVm.isSubmitting,
              text: 'Se connecter',
              loadingText: 'Connexion en cours...',
              onPressed: () async {
                final message = await loginVm.submitLoginForm();

                if (!mounted) return;

                if (message != null) {
                  SnackbarUtils.showInSnackBar(
                    context,
                    message,
                    type: SnackbarType.error,
                  );
                  return;
                }

                context.go('/home');
              },
            ),
          ),
        ],
      ),
    );
  }
}
