import 'package:flutter/material.dart';

class AppColors {
  static final bgColor = Colors.grey[300];
  static const Color primaryColor = Color(0xFF4A1A1A); // Dark brown
  static const Color secondaryColor = Color(0xFF2A1010); // Darker brown
  static const Color accentColor = Color(0xFFE53E3E); // Red accent
  static const Color backgroundColor = Color(0xFF1A0A0A); // Very dark brown
  static const Color surfaceColor = Color(0xFF3A1515); // Medium brown
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFB0B0B0); // Light gray
  static const Color cardColor = Color(0xFF2D1212);
  static const Color cardBackground = Color(0xFF200308);
  static const Color white = Color(0xFFFFFFFF);
  // Additional colors for minesweeper
  static const Color cellDefault = Color(
    0xFFD4D4D8,
  ); // Light gray for unclicked cells
  static const Color cellPressed = Color(
    0xFFE4E4E7,
  ); // Slightly darker when pressed
  static const Color cellRevealed = Color(
    0xFFF4F4F5,
  ); // Very light for revealed cells
  static const Color borderDark = Color(0xFF71717A); // Dark border
  static const Color borderLight = Color(
    0xFFFAFAFA,
  ); // Light border for 3D effect
}

class ColorUtils {
  static Color getNumberColor(int number) {
    switch (number) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.brown;
      case 6:
        return Colors.cyan;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}