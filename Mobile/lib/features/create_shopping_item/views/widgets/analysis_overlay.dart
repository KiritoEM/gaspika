import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/shared/blured_dialog.dart';

class AnalysisOverlay extends StatelessWidget {
  const AnalysisOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BluredDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 4.5,
              strokeCap: .round,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Analyse en cours...',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
