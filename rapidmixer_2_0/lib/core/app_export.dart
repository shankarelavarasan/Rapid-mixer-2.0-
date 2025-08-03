import 'package:flutter/material.dart';

// App Theme Configuration
class AppTheme {
  // Colors
  static const Color primaryDark = Color(0xFF1A1A1A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color borderColor = Color(0xFF333333);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF2196F3);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFF2A2A2A),
      background: Color(0xFF1A1A1A),
      error: Color(0xFFF44336),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondary,
      ),
    ),
  );
}

// Custom Icon Widget
class CustomIconWidget extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const CustomIconWidget({
    super.key,
    required this.icon,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size ?? 24,
      color: color ?? AppTheme.textPrimary,
    );
  }
}