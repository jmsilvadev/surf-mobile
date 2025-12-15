import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF005B82);
  static const Color deepBlue = Color(0xFF013B59);
  static const Color sunsetOrange = Color(0xFFF05A28);
  static const Color goldenWave = Color(0xFFFFB347);
  static const Color sandBackground = Color(0xFFFFF4E5);
  static const Color tideTeal = Color(0xFF008C99);
}

class AppTheme {
  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryBlue,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primaryBlue,
    secondary: AppColors.sunsetOrange,
    surface: AppColors.sandBackground,
  );

  static final ThemeData themeData = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.sandBackground,
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.primaryBlue),
      displayMedium: TextStyle(color: AppColors.primaryBlue),
      displaySmall: TextStyle(color: AppColors.primaryBlue),
      headlineLarge: TextStyle(color: AppColors.primaryBlue),
      headlineMedium: TextStyle(color: AppColors.primaryBlue),
      headlineSmall: TextStyle(color: AppColors.primaryBlue),
      titleLarge: TextStyle(color: AppColors.primaryBlue),
      titleMedium: TextStyle(color: AppColors.deepBlue),
      titleSmall: TextStyle(color: AppColors.deepBlue),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.black54),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.deepBlue,
      selectedItemColor: AppColors.sunsetOrange,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: AppColors.primaryBlue.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.sunsetOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.deepBlue,
        side: const BorderSide(color: AppColors.deepBlue, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.deepBlue),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
      selectedColor: AppColors.sunsetOrange.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: AppColors.primaryBlue),
    ),
    dividerColor: AppColors.deepBlue.withValues(alpha: 0.1),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.deepBlue,
      contentTextStyle: TextStyle(color: Colors.white),
      actionTextColor: AppColors.sunsetOrange,
    ),
  );
}
