import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:we_ads/core/constants/assets_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_background.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AssetsManager.succesIcon,
                width: 100.w,
                height: 100.h,
              ),

              SizedBox(height: 20.h),

              Text(
                "All done!",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  // fontFamily: 'Roboto',
                  color: AppColors.backgroundDark,
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                "Welcome to WeAds",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  // fontFamily: 'Roboto',
                  color: AppColors.mediumGrey,
                ),
              ),

              SizedBox(height: 40.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: const LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceBlue,
                ),
              ),

              SizedBox(height: 60.h),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "Getting things ready...",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    // fontFamily: 'Roboto',
                    color: AppColors.mediumGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
