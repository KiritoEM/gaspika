import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/regex_pattern.dart';
import 'package:gaspika_mobile/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:gaspika_mobile/shared/button_with_loader.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:provider/provider.dart';

class AccountInfoForm extends StatefulWidget {
  final VoidCallback onSubmit;

  const AccountInfoForm({super.key, required this.onSubmit});

  @override
  State<AccountInfoForm> createState() => _AccountInfoFormState();
}

class _AccountInfoFormState extends State<AccountInfoForm> {
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
          FormBlock(
            label: 'Prénom',
            isRequired: true,
            child: TextFormField(
              controller: settingsVm.firstNameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.givenName],
              decoration: const InputDecoration(hintText: 'Entrez votre prénom'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le prénom est obligatoire.';
                }

                return null;
              },
            ),
          ),

          FormBlock(
            label: 'Nom',
            isRequired: true,
            child: TextFormField(
              controller: settingsVm.lastNameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.familyName],
              decoration: const InputDecoration(hintText: 'Entrez votre nom'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est obligatoire.';
                }

                return null;
              },
            ),
          ),

          FormBlock(
            label: 'Email',
            isRequired: true,
            child: TextFormField(
              controller: settingsVm.emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                hintText: 'Entrez votre email',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'email est obligatoire.';
                }

                if (!RegExp(RegexPattern.EMAIL_REGEX).hasMatch(value.trim())) {
                  return 'Entrez une adresse email valide.';
                }

                return null;
              },
              onFieldSubmitted: (_) => _handleSubmit(),
            ),
          ),

          const SizedBox(height: 4),

          ButtonWithLoader(
            text: 'Enregistrer',
            loadingText: 'Enregistrement',
            isLoading: settingsVm.isUpdatingUser,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
