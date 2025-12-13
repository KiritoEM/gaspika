import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/regex_pattern.dart';
import 'package:gaspika_mobile/features/auth/viewmodels/register_viewmodel.dart';
import 'package:gaspika_mobile/shared/password_input_field.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  @override
  Widget build(BuildContext context) {
    RegisterViewModel loginVm = Provider.of<RegisterViewModel>(context);

    return Form(
      key: loginVm.formkey,
      child: Column(
        spacing: 32,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Votre nom complet'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer une adresse email';
              }

              return null;
            },
            onSaved: (value) => {
              if (value != null) {loginVm.setFullname(value)},
            },
          ),

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

          PasswordInputField(
            label: 'Créer votre mot de passe',
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

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => loginVm.submitLoginForm(),
              child: Text('Se connecter'),
            ),
          ),
        ],
      ),
    );
  }
}
