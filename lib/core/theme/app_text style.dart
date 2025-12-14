import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTextStyles {
  // الخط الأساسي
  static const String primaryFont = 'Tajawal';
  static const List<String> fallbackFonts = ['Inter'];

  static TextStyle headline1 = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: fallbackFonts,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle headline2 = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: fallbackFonts,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle body1 = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: fallbackFonts,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle body2 = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: fallbackFonts,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle caption = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: fallbackFonts,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle button = TextStyle(
    fontFamily: primaryFont,
    fontFamilyFallback: fallbackFonts,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
