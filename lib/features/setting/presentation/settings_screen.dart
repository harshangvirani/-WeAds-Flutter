import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/theme/app_text_styles.dart';
import 'package:we_ads/core/utils/filter_utils.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';
import 'package:we_ads/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Settings",
        showBackButton: true,
        titleColor: AppColors.backgroundDark,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Section
            ListTile(
              onTap: () => context.push('/manage_subscription'),
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.credit_card,
                color: AppColors.backgroundDark,
                size: 24,
              ),
              title: Text(
                "Manage your subscription",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.backgroundDark,
                ),
              ),
              subtitle: Text(
                "Next payment date is 01-28-2026",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
            const Divider(color: AppColors.borderGrey),

            Text(
              "Other services",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.backgroundDark,
              ),
            ),
            SizedBox(height: 12.h),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    Icons.privacy_tip_outlined,
                    "Privacy policy",
                    "Supporting line text lorem ipsum...",
                  ),
                  _buildSettingsTile(
                    Icons.help_outline,
                    "Help",
                    "Supporting line text lorem ipsum...",
                  ),
                  _buildSettingsTile(
                    Icons.share_outlined,
                    "Share app",
                    null,
                    showDivider: false,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Logout Section
            ListTile(
              onTap: () => FilterUtils.showLogoutDialog(
                context,
                () => ref.read(authProvider.notifier).logout(context),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              leading: Icon(
                Icons.sensor_door_outlined,
                color: AppColors.errorRed,
                size: 24,
              ),
              title: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Supporting line text lorem ipsum dolor sit...",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String? subtitle, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.backgroundDark, size: 22),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.backgroundDark,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mediumGrey,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.arrow_right,
            color: AppColors.backgroundDark,
            size: 24,
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const Divider(height: 1, color: AppColors.lightGrey),
          ),
      ],
    );
  }
}
