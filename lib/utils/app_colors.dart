import 'package:flutter/material.dart';

class AppColors {
  // Professional Educational Palette
  static const Color primary = Color(0xFF1A237E); // Deep Indigo
  static const Color secondary = Color(0xFF00B0FF); // Light Blue
  static const Color accent = Color(0xFFFFAB40); // Soft Orange

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;

  static const Color studentColor = Color(0xFF388E3C);
  static const Color parentColor = Color(0xFF1976D2);
  static const Color adminColor = Color(0xFFC2185B);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
