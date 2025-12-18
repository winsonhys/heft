import 'package:forui/forui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

// ignore_for_file: avoid_redundant_argument_values

/// Custom Heft theme for forui components.
/// Colors are based on AppColors to maintain consistency across the app.
///
/// Usage in app.dart:
/// ```dart
/// FTheme(
///   data: heftDarkTheme,
///   child: child!,
/// )
/// ```

/// Heft dark theme - matches AppColors palette
FThemeData get heftDarkTheme {
  const colors = FColors(
    brightness: Brightness.dark,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    barrier: Color(0x7A000000),
    // Use AppColors for consistency
    background: AppColors.bgPrimary,           // #0A0E1A - Deep navy
    foreground: AppColors.textPrimary,         // #FFFFFF - White text
    primary: AppColors.accentBlue,             // #4F5FFF - Primary blue
    primaryForeground: AppColors.textPrimary,  // White on primary
    secondary: AppColors.bgCard,               // #151C2C - Card background
    secondaryForeground: AppColors.textPrimary,
    muted: AppColors.bgCardInner,              // #1A2235 - Inner card
    mutedForeground: AppColors.textMuted,      // #5A6478 - Muted text
    destructive: AppColors.accentRed,          // #EF4444 - Error red
    destructiveForeground: AppColors.textPrimary,
    error: AppColors.accentRed,                // #EF4444 - Error red
    errorForeground: AppColors.textPrimary,
    border: AppColors.borderColor,             // #2D3548 - Border
  );

  final typography = _typography(colors: colors);
  final style = _style(colors: colors, typography: typography);

  return FThemeData(colors: colors, typography: typography, style: style);
}

/// Heft light theme (optional - for future use)
FThemeData get heftLightTheme {
  const colors = FColors(
    brightness: Brightness.light,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    barrier: Color(0x33000000),
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    primary: AppColors.accentBlue,             // Keep brand color
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    destructive: AppColors.accentRed,
    destructiveForeground: Color(0xFFFAFAFA),
    error: AppColors.accentRed,
    errorForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
  );

  final typography = _typography(colors: colors);
  final style = _style(colors: colors, typography: typography);

  return FThemeData(colors: colors, typography: typography, style: style);
}

FTypography _typography({
  required FColors colors,
  String defaultFontFamily = 'packages/forui/Inter',
}) => FTypography(
  xs: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 12,
    height: 1,
  ),
  sm: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 14,
    height: 1.25,
  ),
  base: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 16,
    height: 1.5,
  ),
  lg: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 18,
    height: 1.75,
  ),
  xl: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 20,
    height: 1.75,
  ),
  xl2: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 22,
    height: 2,
  ),
  xl3: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 30,
    height: 2.25,
  ),
  xl4: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 36,
    height: 2.5,
  ),
  xl5: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 48,
    height: 1,
  ),
  xl6: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 60,
    height: 1,
  ),
  xl7: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 72,
    height: 1,
  ),
  xl8: TextStyle(
    color: colors.foreground,
    fontFamily: defaultFontFamily,
    fontSize: 96,
    height: 1,
  ),
);

FStyle _style({required FColors colors, required FTypography typography}) =>
    FStyle(
      formFieldStyle: FFormFieldStyle.inherit(
        colors: colors,
        typography: typography,
      ),
      focusedOutlineStyle: FFocusedOutlineStyle(
        color: colors.primary,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      iconStyle: IconThemeData(color: colors.primary, size: 20),
      tappableStyle: FTappableStyle(),
      borderRadius: const FLerpBorderRadius.all(Radius.circular(12), min: 24),
      borderWidth: 1,
      pagePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shadow: const [
        BoxShadow(
          color: Color(0x0d000000),
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
      ],
    );
