import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/constants/assets_manager.dart';
import 'package:we_ads/core/theme/app_colors.dart';

class AvailablePlansSheet extends StatefulWidget {
  const AvailablePlansSheet({super.key});

  @override
  State<AvailablePlansSheet> createState() => _AvailablePlansSheetState();
}

class _AvailablePlansSheetState extends State<AvailablePlansSheet> {
  String selectedPlan = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Logo
          Image.asset(AssetsManager.appLogo, width: 48.w, height: 48.h),

          SizedBox(height: 12.h),

          /// Title
          const Text(
            "Available plans",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: AppColors.backgroundDark,
            ),
          ),

          SizedBox(height: 24.h),

          /// Plans
          _buildPlanTile("Yearly", "\$59.99 \$40.99"),
          _buildPlanTile("Quarterly", "\$20.99 \$18.99"),
          _buildPlanTile("Monthly", "\$14.99"),

          SizedBox(height: 32.h),

          /// Change Plan Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mediumGrey.withOpacity(0.2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: const Text(
                "Change plan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildPlanTile(String title, String price) {
    bool isSelected = selectedPlan == title;

    return GestureDetector(
      onTap: () => setState(() => selectedPlan = title),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: title,
              groupValue: selectedPlan,
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedPlan = val);
                }
              },
            ),

            /// Plan Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.backgroundDark,
              ),
            ),

            const Spacer(),

            /// Price Text
            RichText(
              text: TextSpan(
                children: [
                  if (price.contains(' ')) ...[
                    TextSpan(
                      text: price.split(' ')[0],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: price.split(' ')[1],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                  ] else ...[
                    TextSpan(
                      text: price,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
