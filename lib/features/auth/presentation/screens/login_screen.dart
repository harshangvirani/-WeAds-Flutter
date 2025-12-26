import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/constants/assets_manager.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/theme/app_text_styles.dart';
import 'package:we_ads/core/widgets/custom_button.dart';
import 'package:we_ads/core/widgets/custom_phone_field.dart';
import 'package:we_ads/core/widgets/gradient_background.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.symmetric(vertical: 16.h),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(AssetsManager.appLogo, width: 56.w, height: 56.h),
            SizedBox(width: 6.w),
            Image.asset(AssetsManager.nameLogo, width: 90.w, height: 56.h),
          ],
        ),
        toolbarHeight: 100.h,
      ),
      body: GradientBackground(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Login",
                  style: AppTextStyles.headlineMedium,
                ),
                SizedBox(height: 24.h),

                // The Phone Field
                const CustomPhoneField(),

                SizedBox(height: 24.h),

                // The Submit Button
                CustomButton(
                  text: "Send OTP",
                  backgroundColor: AppColors.borderGrey.withValues(alpha: 0.1),
                  textColor: AppColors.mediumGrey,
                  onTap: null,
                  borderRadius: 50.w,
                ),

                SizedBox(height: 16.h),

                const Divider(color: AppColors.lightGrey),

                TextButton(
                  onPressed: () {},
                  child: Text("Don't have an account?",style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.normal,
                    color: AppColors.darkGrey
                  ),),
                ),

                CustomButton(
                  text: "Create new account",
                  backgroundColor: Colors.transparent,
                  borderColor: AppColors.borderGrey,
                  textColor: AppColors.secondary,
                  borderRadius: 50.w,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
