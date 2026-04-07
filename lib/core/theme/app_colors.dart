import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF050816);
  static const Color backgroundSecondary = Color(0xFF0A1024);
  static const Color surface = Color(0xFF101933);
  static const Color surfaceElevated = Color(0xFF152143);
  static const Color glassFillTop = Color(0xCC17213F);
  static const Color glassFillBottom = Color(0x99131C35);
  static const Color glassStroke = Color(0x4DA4D8FF);

  static const Color neonBlue = Color(0xFF5AE8FF);
  static const Color neonGreen = Color(0xFF7CFFB2);
  static const Color neonPurple = Color(0xFF8F78FF);
  static const Color neonPink = Color(0xFFFF74C8);

  static const Color primaryText = Color(0xFFF5F8FF);
  static const Color secondaryText = Color(0xFFAFBCD9);
  static const Color tertiaryText = Color(0xFF7F8BA8);

  static const Color success = Color(0xFF76F5A4);
  static const Color warning = Color(0xFFFFC66D);
  static const Color danger = Color(0xFFFF748F);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      background,
      backgroundSecondary,
      Color(0xFF060A18),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      neonBlue,
      neonPurple,
      neonGreen,
    ],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      glassFillTop,
      glassFillBottom,
    ],
  );
}
