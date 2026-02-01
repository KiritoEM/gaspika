import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class ErrorState extends StatelessWidget {
  final String text;
  final bool showRefreshButton;
  final VoidCallback? onRefresh;

  const ErrorState({
    super.key,
    required this.text,
    this.showRefreshButton = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/images/error.svg', width: 220),

            const SizedBox(height: 24),

            Text(
              text,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            if (showRefreshButton && onRefresh != null)
              ElevatedButton.icon(
                onPressed: onRefresh,
                label: const Text('Réessayer', style: TextStyle(fontSize: 14)),
                icon: const Icon(Icons.refresh, size: 20),
                iconAlignment: IconAlignment.end,
              ),
          ],
        ),
      ),
    );
  }
}
