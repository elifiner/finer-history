import 'package:flutter/material.dart';

class AppTheme {
  // Primary color scheme
  static const Color primaryColor = Color(0xFF667EEA);
  static const Color scaffoldBackgroundColor = Color(0xFFF5F5F5);
  
  // Text colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Background colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  // Border and divider colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFE0E0E0);
  
  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  
  // Neutral colors
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: cardBackground,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: surfaceColor,
        elevation: 16,
      ),
      listTileTheme: ListTileThemeData(
        selectedTileColor: primaryColor.withValues(alpha: 0.1),
        selectedColor: primaryColor,
        iconColor: grey600,
        textColor: textPrimary,
      ),
    );
  }
}

