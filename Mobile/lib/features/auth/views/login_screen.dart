import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/auth/views/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: Icon(Icons.chevron_left, size: 32),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: .spaceBetween,

            children: [
              Column(
                spacing: 40,
                children: [
                  // Header
                  Column(
                    spacing: 12,
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'Accéder à votre compte',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.fontSize!,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Entrer vos informations pour continuer.',
                        style: TextStyle(color: AppColors.mutedForeground),
                      ),
                    ],
                  ),

                  // Form
                  LoginForm(),
                ],
              ),

              //Signup link
              RichText(
                text: TextSpan(
                  text: 'Pas encore de compte? ',
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: 'S\'inscrire',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
