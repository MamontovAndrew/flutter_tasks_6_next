import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppThemes {
  static final mainTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      error: AppColors.errorColor,
      onSurface: AppColors.textColor,
      onSurfaceVariant: AppColors.textSecondaryColor,
      background: AppColors.backgroundColor,
    ),
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 24,
        color: AppColors.textColor,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 20,
        color: AppColors.textColor,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 17,
        color: AppColors.textColor,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 16,
        color: AppColors.textColor,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 15,
        color: AppColors.textSecondaryColor,
      ),
    ),
  );
}
