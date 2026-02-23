import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/constants/assets_manager.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/utils/available_plans_sheet.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Manage you subscription",
        showBackButton: true,
        titleColor: AppColors.backgroundDark,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            /// Current Plan Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(AssetsManager.appLogo, width: 32.w),
                      SizedBox(width: 8.w),
                      Text(
                        "Weads",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Lite - Monthly",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showPlansSheet(context),
                        child: const Text(
                          "View all plans",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: AppColors.lightGrey),

                  _buildPlanInfo(Icons.credit_card, "\$4.99 per month"),
                  SizedBox(height: 8.h),
                  _buildPlanInfo(
                    Icons.calendar_today_outlined,
                    "Your next bill is on 01-28-2026",
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.errorRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: const Text(
                  "Cancel subscription",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            const Text(
              "If you cancel now, you can still access your subscription till 01-28-2026.",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 11, color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.backgroundDark),
        SizedBox(width: 10.w),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: AppColors.backgroundDark),
        ),
      ],
    );
  }

  void _showPlansSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AvailablePlansSheet(),
    );
  }
}
