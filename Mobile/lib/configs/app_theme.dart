import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData theme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        brightness: Brightness.light,
        onSurface: AppColors.foreground,
      ),
      textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)
          .copyWith(
            bodyMedium: GoogleFonts.montserrat(
              fontWeight: FontWeight.w500,
            ).copyWith(fontSize: 15),
            bodyLarge: GoogleFonts.montserrat(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          elevation: 0.5,
          disabledForegroundColor: AppColors.mutedForeground,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: AppColors.surface),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          elevation: 0.5,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        labelTextStyle: MaterialStateProperty.resolveWith((state) {
          if (state.contains(MaterialState.selected)) {
            return GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.primary,
            );
          }

          return TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColors.mutedForeground,
          );
        }),
      ),
    );
  }
}
