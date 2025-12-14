import 'package:flutter/material.dart';

class PasswordInputField extends StatefulWidget {
  final String? label;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const PasswordInputField({
    super.key,
    this.label = 'Mot de passe',
    this.onSaved,
    this.validator,
    this.controller,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      obscureText: !_passwordVisible,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: Container(
          margin: EdgeInsets.only(right: 4),
          child: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
      ),
      keyboardType: TextInputType.visiblePassword,
      validator: widget.validator,
      onSaved: widget.onSaved,
    );
  }
}
