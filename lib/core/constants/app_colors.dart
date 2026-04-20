import 'package:flutter/material.dart';

class AppColors {
  // Sky Blue Palette
  static const Color skyPrimary = Color(0xFF0EA5E9);
  static const Color skyDark = Color(0xFF0284C7);
  static const Color skyDarker = Color(0xFF0369A1);
  static const Color skyLight = Color(0xFFBAE6FD);
  static const Color skyLighter = Color(0xFFE0F2FE);
  static const Color skyUltra = Color(0xFFF0F9FF);
  static const Color navy = Color(0xFF0C4A6E);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray800 = Color(0xFF1E293B);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [skyPrimary, skyDark],
  );

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [skyPrimary, navy],
  );
}
