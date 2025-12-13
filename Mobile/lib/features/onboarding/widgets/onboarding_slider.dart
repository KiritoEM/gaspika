import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/onboarding/models/slider_model.dart';
import 'package:gaspika_mobile/features/onboarding/widgets/build_dot.dart';

class OnboardingSlider extends StatefulWidget {
  final List<SliderModel> slides;
  final VoidCallback onComplete;

  const OnboardingSlider({
    super.key,
    required this.slides,
    required this.onComplete,
  });

  @override
  State<OnboardingSlider> createState() => _OnboardingSliderState();
}

class _OnboardingSliderState extends State<OnboardingSlider> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //go to next slide
  void _hanlePressNext() {
    if (currentIndex < widget.slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Slider Illustration
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.45,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemCount: widget.slides.length,
            itemBuilder: (context, index) {
              return SvgPicture.asset(
                widget.slides[index].illustration,
                semanticsLabel: 'Illustration Gaspika',
                fit: BoxFit.fill,
                alignment: Alignment.topCenter,
              );
            },
          ),
        ),

        const SizedBox(height: 45),

        // Slider Content
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Text(
                  widget.slides[currentIndex].title,
                  style: TextStyle(
                    fontSize: theme.textTheme.headlineLarge!.fontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),

                Text(
                  widget.slides[currentIndex].description,
                  style: const TextStyle(color: AppColors.mutedForeground),
                ),

                const SizedBox(height: 20),

                // Dots and Navigation Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        widget.slides.length,
                        (index) => BuildDot(isActive: index == currentIndex),
                      ),
                    ),

                    IconButton.filled(
                      onPressed: _hanlePressNext,
                      icon: SvgPicture.asset(
                        'assets/icons/arrow-right-broken.svg',
                        width: 26,
                        height: 26,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
