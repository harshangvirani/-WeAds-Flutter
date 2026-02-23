import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  bool isUpperGradient;
  bool isMainGradient;
  final Widget child;

  GradientBackground({
    super.key,
    this.isUpperGradient = false,
    this.isMainGradient = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: isUpperGradient
            ? AppColors.backgroundUpperGradient
            : isMainGradient
            ? AppColors.backgroundMainGradient
            : AppColors.backgroundGradient,
      ),
      child: child,
    );
  }
}
