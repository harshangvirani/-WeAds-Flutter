import 'package:flutter/material.dart';

class AppColors {
  // Primary & Brand Colors
  static const Color primary = Color(0xFF04677E);
  static const Color primaryVariant = Color(0xFF004E60);
  static const Color secondary = Color(0xFF344A52);

  //main screen background color
  static const Color mainBg = Color(0xFFDBE4E8);

  // Grays & Neutrals
  static const Color darkGrey = Color(0xFF40484C);
  static const Color mediumGrey = Color(0xFF70787C);
  static const Color lightGrey = Color(0xFFBFC8CC);
  static const Color borderGrey = Color(0xFFCAC4D0);

  // Scaffolding & Backgrounds
  static const Color backgroundDark = Color(0xFF171C1F);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceBlue = Color(0xFFCFE6F0);
  static const Color surface = Color(0xFFEAEFF1);
  static const Color surfaceLow = Color(0xFFEFF4F7);
  static const Color surfaceGrey = Color(0xFFE4E9EC);
  static const Color deepDeepBlue = Color(0xFF001F28);

  // Functional Colors
  static const Color accentGold = Color(0xFF7C580D);
  static const Color errorRed = Color(0xFFBA1A1A);
  static const Color textMuted = Color(0xFF4C626A);
  static const Color tertiary = Color(0xFFFFDEAC);

  // light blue tint
  static const Color lightBlueTint = Color(0xFFF5FAFD);

  // Opacity Colors
  static Color backgroundWithOpacity = const Color(
    0xFF171C1F,
  ).withOpacity(0.10);
  static Color whiteWithOpacity = const Color(0xFFFFFFFF).withOpacity(0.16);

  // Linear Gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFCFE6F0)],
  );

  // upper Gradient
  static const LinearGradient backgroundUpperGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.topLeft,
    colors: [Color(0xFFCFE6F0), Color(0xFFFFFFFF)],
  );
  // upper Gradient
  static const LinearGradient backgroundMainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F4F7), Color(0xFFDBE4E8)],
    stops: [0.0, 0.4, 1.0],
  );
}
