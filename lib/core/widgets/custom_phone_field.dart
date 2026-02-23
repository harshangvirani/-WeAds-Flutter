import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../theme/app_colors.dart';

class CustomPhoneField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialCountryCode;
  final Function(String)? onValueChanged;
  final void Function(String countryCode, String dialCode)? onCountryChanged;
  final FutureOr<String?> Function(PhoneNumber?)? validator;
  final bool? readOnly;

  const CustomPhoneField({
    super.key,
    this.controller,
    this.initialCountryCode = 'US',
    this.onValueChanged,
    this.onCountryChanged,
    this.validator,
    this.readOnly = false,
  });

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  /// Text inside field + dropdown
  final TextStyle visibleStyle = TextStyle(
    color: AppColors.backgroundDark,
    // fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// Country dialog styles
  final TextStyle countryNameStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    // fontFamily: 'Roboto',
    color: Colors.black,
  );

  final TextStyle countryCodeStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    // fontFamily: 'Roboto',
    color: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: widget.controller,
      initialCountryCode: widget.initialCountryCode,

      validator: widget.validator,
      readOnly: widget.readOnly ?? false,

      dropdownIconPosition: IconPosition.trailing,
      dropdownTextStyle: visibleStyle,
      style: visibleStyle,

      flagsButtonPadding: EdgeInsets.only(left: 15.w),
      enabled: !(widget.readOnly ?? false),

      /// Country picker dialog
      pickerDialogStyle: PickerDialogStyle(
        searchFieldInputDecoration: InputDecoration(
          hintText: 'Search country',
          suffixIcon: const Icon(Icons.search),
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            // fontFamily: 'Roboto',
          ),
        ),
        countryNameStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          // fontFamily: 'Roboto',
          color: Colors.black,
        ),
        countryCodeStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          // fontFamily: 'Roboto',
          color: Colors.black87,
        ),
      ),

      decoration: InputDecoration(
        labelText: 'Mobile no.',
        labelStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          // fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
        ),

        hintText: '12344 12345',
        counterText: '',
        filled: true,

        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.mediumGrey,
          // fontFamily: 'Roboto',
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      onChanged: (phone) {
        widget.onValueChanged?.call(phone.completeNumber);
      },

      onCountryChanged: (country) {
        widget.onCountryChanged?.call(country.code, country.dialCode);
      },
    );
  }
}
