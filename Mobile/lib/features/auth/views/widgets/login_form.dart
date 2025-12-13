import 'package:flutter/material.dart';
import 'package:gaspika_mobile/shared/password_input_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static const _emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  @override
  Widget build(BuildContext context) {

    return Form(
      child: Column(
        spacing: 32,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Votre adresse email'),
            keyboardType: TextInputType.emailAddress,
          ),

          PasswordInputField(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Se connecter'),
            ),
          ),
        ],
      ),
    );
  }
}
