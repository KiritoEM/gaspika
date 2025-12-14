import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaspika_mobile/features/onboarding/models/slider_model.dart';
import 'package:gaspika_mobile/features/onboarding/widgets/onboarding_slider.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // data for onboarding slider
    final List<SliderModel> slides = [
      SliderModel(
        title: 'Planifie mieux tes courses',
        description:
            'Organise tes achats en toute simplicité et garde le contrôle de ton budget chaque semaine.',
        illustration: 'assets/images/onboarding-logo-1.svg',
      ),
      SliderModel(
        title: 'Maîtrise ton stock alimentaire',
        description:
            'Système intelligent pour suivre ce que tu as déjà et te prévenir avant que ça ne s\'abîme.',
        illustration: 'assets/images/onboarding-logo-2.svg',
      ),
      SliderModel(
        title: 'Transforme tes restes',
        description:
            'L\'IA te propose des astuces, recettes et techniques pour donner une seconde vie à ta nourriture.',
        illustration: 'assets/images/onboarding-logo-3.svg',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [
            //Logo
            Positioned.fill(
              top: 8,
              child: Align(
                alignment: Alignment.topCenter,
                child: SvgPicture.asset(
                  'assets/icons/gaspika-logo-text.svg',
                  semanticsLabel: 'Illustration Gaspika',
                  width: 130,
                ),
              ),
            ),

            // Slider
            OnboardingSlider(
              slides: slides,
              onComplete: () {
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
