import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../theme/app_colors.dart';

class CustomPhoneField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialCountryCode;
  final Function(String)? onValueChanged;

  const CustomPhoneField({
    super.key,
    this.controller,
    this.initialCountryCode = 'US', // Default to India or your preferred region
    this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      initialCountryCode: initialCountryCode,
      dropdownIconPosition: IconPosition.trailing,
      flagsButtonPadding: EdgeInsetsGeometry.only(left: 15.w),
      // Matches the Figma styling
      decoration: InputDecoration(
        labelText: 'Mobile no.',
        labelStyle: TextStyle(color: AppColors.primary, fontSize: 14.sp),
        hintText: '12344 12345',
        counterText: '', // Removes the character counter
        filled: true,
        // fillColor: const Color(0xFFF5FAFD), // Light blue tint from Figma
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      languageCode: "en",
      onChanged: (phone) {
        if (onValueChanged != null) {
          onValueChanged!(phone.completeNumber);
        }
      },
    );
  }
}
