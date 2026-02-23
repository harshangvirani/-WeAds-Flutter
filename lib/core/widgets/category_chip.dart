import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceBlue : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: !isSelected ? Border.all(color: AppColors.lightGrey) : null,
        ),
        child: Row(
          children: [
            if (isSelected)
              const Icon(Icons.check, size: 14, color: AppColors.primary),

            if (isSelected) SizedBox(width: 4.w),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
