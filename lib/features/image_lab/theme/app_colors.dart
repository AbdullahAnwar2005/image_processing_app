import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF4F6FA);
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryGradientEnd = Color(0xFF7C3AED);
  static const Color accent = Color(0xFF06B6D4);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E1E2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE8EDF5);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color surfaceAlt = Color(0xFFF1F5F9);
  static const Color surfaceInput = Color(0xFFF8FAFC);

  // Feature chip colors
  static const Color grayscaleBg = Color(0xFFE0E7FF);
  static const Color grayscaleText = Color(0xFF4F46E5);
  
  static const Color contrastBg = Color(0xFFF0FDF4);
  static const Color contrastText = Color(0xFF16A34A);
  
  static const Color blurBg = Color(0xFFF0F9FF);
  static const Color blurText = Color(0xFF0284C7);
  
  static const Color edgesBg = Color(0xFFFFF7ED);
  static const Color edgesText = Color(0xFFEA580C);
  
  static const Color histogramBg = Color(0xFFF0FDFA);
  static const Color histogramText = Color(0xFF0D9488);

  // Slider colors
  static const Color brightnessSlider = Color(0xFFCA8A04);
  static const Color contrastSlider = Color(0xFF4F46E5);
  static const Color blurSlider = Color(0xFF0284C7);

  // Histogram colors
  static const Color histogramR = Color(0xFFEF4444);
  static const Color histogramG = Color(0xFF22C55E);
  static const Color histogramB = Color(0xFF3B82F6);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
