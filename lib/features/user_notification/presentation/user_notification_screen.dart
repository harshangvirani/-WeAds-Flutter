import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/theme/app_text_styles.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';

class UserNotificationScreen extends StatefulWidget {
  const UserNotificationScreen({super.key});

  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: "User Notifications",
        showBackButton: true,
        backgroundColor: AppColors.lightBlueTint,
        titleColor: AppColors.backgroundDark,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // USER LIST
                  ListView.builder(
                    itemCount: 10,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
                    itemBuilder: (context, index) {
                      // Custom Colors for Avatars as seen in image
                      final List<Color> avatarColors = [
                        const Color(0xFF7A5421),
                        const Color(0xFF005F73),
                        const Color(0xFF7A5421),
                        const Color(0xFF005F73),
                      ];
                      final Color avatarColor =
                          avatarColors[index % avatarColors.length];

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        leading: CircleAvatar(
                          radius: 24.r,
                          backgroundColor: avatarColor,
                          child: Text(
                            "AD",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          "Jeans Tompson",
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          "Chef: Culinary Arts",
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
