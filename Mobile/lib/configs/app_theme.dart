import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData theme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)
          .copyWith(
            bodyMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
          ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(backgroundColor: AppColors.primary),
      ),
    );
  }
}
