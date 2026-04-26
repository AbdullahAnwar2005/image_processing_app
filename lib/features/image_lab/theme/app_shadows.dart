import 'package:flutter/material.dart';

class AppShadows {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 16,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> heroShadow = [
    BoxShadow(
      color: const Color(0xFF4F46E5).withOpacity(0.28),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> primaryButtonShadow = [
    BoxShadow(
      color: const Color(0xFF4F46E5).withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> bottomBarShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];
}
