import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_ads/core/theme/app_colors.dart';

class CommonConfirmationDialog extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String description;
  final VoidCallback onContinue;
  final String? svgIcon;
  final String continueLabel;

  const CommonConfirmationDialog({
    super.key,
    this.icon,
    required this.title,
    required this.description,
    required this.onContinue,
    this.svgIcon,
    this.continueLabel = "Continue",
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (svgIcon != null)
              SvgPicture.asset(
                svgIcon!,
                width: 48.w,
                height: 48.h,
                colorFilter: const ColorFilter.mode(
                  AppColors.darkGrey,
                  BlendMode.srcIn,
                ),
              )
            else if (icon != null)
              Icon(icon, size: 32, color: AppColors.darkGrey),

            SizedBox(height: 16.h),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.backgroundDark,
              ),
            ),

            SizedBox(height: 12.h),

            // Description
            Text(
              description,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.darkGrey,
              ),
            ),

            SizedBox(height: 32.h),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    continueLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
