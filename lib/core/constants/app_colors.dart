import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C4DFF);
  static const Color primaryDark = Color(0xFF4C2BD9);
  static const Color sky = Color(0xFF3EC6FF);
  static const Color magenta = Color(0xFFE91E8C);
  static const Color gold = Color(0xFFFFC107);
  static const Color navy = Color(0xFF1E1B4B);
  static const Color muted = Color(0xFF6B7280);
  static const Color background = Color(0xFFF7F4FF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF128A5A);
  static const Color danger = Color(0xFFD92D20);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [sky, primary, magenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF4ECFF), Color(0xFFFFF1F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
