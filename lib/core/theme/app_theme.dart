import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/size.dart';
import 'app_text style.dart';

class AppTheme {
  AppTheme._(); // منع الإنشاء

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.surface,
    canvasColor: AppColors.surface,
    fontFamily: AppTextStyles.primaryFont,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      background: AppColors.background,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),

    // TextTheme بالأسماء الحديثة
    textTheme: TextTheme(
      titleLarge: AppTextStyles.headline1,
      titleMedium: AppTextStyles.headline2,
      bodyLarge: AppTextStyles.body1,
      bodyMedium: AppTextStyles.body2,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.button,
    ),

    appBarTheme: AppBarTheme(
      color: AppColors.surface,
      elevation: 1,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTextStyles.headline2,
      toolbarTextStyle: AppTextStyles.body1,
    ),

    // زر ElevatedButton باستخدام ButtonStyle
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppColors.primary),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        minimumSize: MaterialStateProperty.all(
          Size(double.infinity, AppSizes.buttonHeight),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        textStyle: MaterialStateProperty.all(AppTextStyles.button),
        elevation: MaterialStateProperty.all(2.0),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: BorderSide.none,
      ),
      hintStyle: AppTextStyles.body2,
      errorStyle: AppTextStyles.body2.copyWith(color: AppColors.danger),
    ),

    // CardTheme باستخدام copyWith لتفادي مشاكل النوع
    cardTheme: ThemeData.light().cardTheme.copyWith(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      color: AppColors.surface,
      shadowColor: AppColors.cardShadow,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),

    iconTheme: IconThemeData(color: AppColors.primary),
    dividerTheme: DividerThemeData(
      color: AppColors.textSecondary.withOpacity(0.12),
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.body2.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: const Color(0xFF0B1220),
    fontFamily: AppTextStyles.primaryFont,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.accent,
      background: const Color(0xFF0B1220),
      surface: const Color(0xFF0F1724),
      onPrimary: Colors.white,
      onSurface: Colors.white70,
    ),

    textTheme: TextTheme(
      titleLarge: AppTextStyles.headline1.copyWith(color: Colors.white),
      titleMedium: AppTextStyles.headline2.copyWith(color: Colors.white),
      bodyLarge: AppTextStyles.body1.copyWith(color: Colors.white70),
      bodyMedium: AppTextStyles.body2.copyWith(color: Colors.white70),
      bodySmall: AppTextStyles.caption.copyWith(color: Colors.white60),
      labelLarge: AppTextStyles.button,
    ),

    appBarTheme: AppBarTheme(
      color: const Color(0xFF0F1724),
      elevation: 1,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: AppTextStyles.headline2.copyWith(color: Colors.white),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppColors.primaryDark),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        minimumSize: MaterialStateProperty.all(
          Size(double.infinity, AppSizes.buttonHeight),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        textStyle: MaterialStateProperty.all(AppTextStyles.button),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F1724),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: BorderSide.none,
      ),
      hintStyle: AppTextStyles.body2.copyWith(color: Colors.white54),
    ),

    cardTheme: ThemeData.dark().cardTheme.copyWith(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      color: const Color(0xFF0F1724),
      shadowColor: Colors.black54,
    ),

    iconTheme: const IconThemeData(color: Colors.white),
  );
}
