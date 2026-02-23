import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

Future<TimeOfDay?> showCustomTimePicker(BuildContext context) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 9, minute: 0),
    initialEntryMode: TimePickerEntryMode.inputOnly,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surfaceLow,
            onSurface: AppColors.backgroundDark,
            tertiaryContainer: AppColors.tertiary, // AM/PM selected color
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.surfaceLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.r),
            ),
            hourMinuteShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: const BorderSide(color: AppColors.borderGrey, width: 1),
            ),
            hourMinuteColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.surfaceBlue;
              }
              return Colors.transparent;
            }),
            hourMinuteTextColor: AppColors.backgroundDark,

            // Style for AM/PM toggle
            dayPeriodBorderSide: const BorderSide(color: AppColors.borderGrey),
            dayPeriodShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            dayPeriodColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.tertiary; // Peach/Orange color for selected
              }
              return Colors.transparent;
            }),
            dayPeriodTextColor: AppColors.backgroundDark,

            // Layout styling
            inputDecorationTheme: InputDecorationTheme(
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    // Handle the selected time
    print("Selected time: ${picked.format(context)}");
  }
  return picked;
}
