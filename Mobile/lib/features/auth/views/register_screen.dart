import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/auth/views/widgets/login_form.dart';
import 'package:gaspika_mobile/features/auth/views/widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                        'Créer un compte',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.fontSize!,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Renseignez vos informations pour créer votre compte Gaspika.',
                        style: TextStyle(color: AppColors.mutedForeground),
                      ),
                    ],
                  ),

                  // Form
                  RegisterForm(),
                ],
              ),

              //Signup link
              RichText(
                text: TextSpan(
                  text: 'Vous avez déja un compte?  ',
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: 'Se connecter',
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
