import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? borderColor;
  final Color? loadingColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 52.0, // Default height
    this.borderRadius = 8.0, // Default radius
    this.backgroundColor = AppColors.primary, // Default from your palette
    this.textColor = AppColors.white,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.borderColor,
    this.loadingColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Handle disabled or loading state logic
    final bool effectiveDisabled = isDisabled || isLoading || onTap == null;

    return SizedBox(
      width: width ?? double.infinity, // Default to full width if not specified
      height: height.h,
      child: ElevatedButton(
        onPressed: effectiveDisabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: loadingColor,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: effectiveDisabled ? AppColors.lightGrey : textColor,
                  fontSize: fontSize.sp,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }
}
