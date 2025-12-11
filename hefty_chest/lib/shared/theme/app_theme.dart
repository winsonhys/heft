import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'app_colors.dart';

/// Build the Material theme data
ThemeData buildMaterialTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgPrimary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentBlue,
      secondary: AppColors.accentGreen,
      surface: AppColors.bgCard,
      error: AppColors.accentRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgCardInner,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderColor,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size: 24,
    ),
  );
}

/// Shadcn color scheme configuration for the app
shadcn.ColorScheme buildShadcnColorScheme() {
  return shadcn.ColorScheme(
    brightness: shadcn.Brightness.dark,
    background: AppColors.bgPrimary,
    foreground: AppColors.textPrimary,
    card: AppColors.bgCard,
    cardForeground: AppColors.textPrimary,
    popover: AppColors.bgCard,
    popoverForeground: AppColors.textPrimary,
    primary: AppColors.accentBlue,
    primaryForeground: const Color(0xFFFFFFFF),
    secondary: AppColors.bgCardInner,
    secondaryForeground: AppColors.textSecondary,
    muted: AppColors.bgCardInner,
    mutedForeground: AppColors.textMuted,
    accent: AppColors.accentBlue,
    accentForeground: const Color(0xFFFFFFFF),
    destructive: AppColors.accentRed,
    destructiveForeground: const Color(0xFFFFFFFF),
    border: AppColors.borderColor,
    input: AppColors.bgCardInner,
    ring: AppColors.accentBlue,
    chart1: AppColors.accentBlue,
    chart2: AppColors.accentGreen,
    chart3: AppColors.accentOrange,
    chart4: AppColors.accentRed,
    chart5: AppColors.textSecondary,
    // Sidebar colors (required)
    sidebar: AppColors.bgSecondary,
    sidebarForeground: AppColors.textPrimary,
    sidebarPrimary: AppColors.accentBlue,
    sidebarPrimaryForeground: const Color(0xFFFFFFFF),
    sidebarAccent: AppColors.bgCard,
    sidebarAccentForeground: AppColors.textPrimary,
    sidebarBorder: AppColors.borderColor,
    sidebarRing: AppColors.accentBlue,
  );
}
