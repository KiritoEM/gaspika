import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/auth/views/widgets/linear_bg.dart';
import 'package:gaspika_mobile/features/auth/views/widgets/login_form.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/chevron-left.svg', width: 42),
          onPressed: () => context.go('/'),
        ),
      ),

      body: Stack(
        children: [
          AuthLinearBg(),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(23, 8, 23, 23),
              child: Column(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 40),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 12),
                          const Text(
                            'Entrer vos informations pour continuer.',
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      LoginForm(),
                    ],
                  ),

                  //Register link
                  RichText(
                    text: TextSpan(
                      text: 'Pas encore inscrit?  ',
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'S\'inscrire',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.go('/register'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
