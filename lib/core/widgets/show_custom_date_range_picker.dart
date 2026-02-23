// core/widgets/show_custom_date_range_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

Future<DateTimeRange?> showCustomDateRangePicker(BuildContext context) async {
  return await showDateRangePicker(
    context: context,
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
    helpText: 'Select date',
    saveText: 'Save',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary, // Range selection and circles
            onPrimary: Colors.white, // Text on circles
            onSurface: AppColors.backgroundDark, // Calendar numbers
            surface: AppColors.surfaceLow, // Background
            secondaryContainer:
                AppColors.surfaceBlue, // Background of the selected range
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.surfaceLow,
            iconTheme: const IconThemeData(color: AppColors.backgroundDark),
            titleTextStyle: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.surfaceLow,
            headerBackgroundColor: AppColors.surfaceLow,
            headerForegroundColor: AppColors.backgroundDark,
            rangeSelectionBackgroundColor: AppColors.surfaceBlue,
            rangePickerHeaderHeadlineStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.backgroundDark,
            ),
            dayStyle: TextStyle(fontSize: 14.sp),
          ),
        ),
        child: child!,
      );
    },
  );
}
