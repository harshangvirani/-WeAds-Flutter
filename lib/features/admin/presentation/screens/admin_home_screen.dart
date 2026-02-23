import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/constants/assets_manager.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/theme/app_text_styles.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';
import 'package:we_ads/core/widgets/gradient_background.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: CustomAppBar(
        showLogo: true,
        backgroundColor: AppColors.lightBlueTint,
      ),
      body: GradientBackground(
        isMainGradient: true,
        child: Column(
          children: [
            const Divider(height: 1, color: AppColors.lightGrey),
            Expanded(
              child: ListView.separated(
                itemCount: 5,
                padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.lightGrey),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.asset(
                            AssetsManager.appLogo,
                            width: 56.w,
                            height: 56.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Monthly", style: AppTextStyles.labelSmall),
                              Text(
                                "New cooking channel in the town",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.backgroundDark,
                                ),
                              ),
                              Text(
                                "Checkout new cooking channel.",
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.darkGrey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
