import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/theme/app_colors.dart';

Future<List<String>?> showDaysOfWeekPicker(
  BuildContext context,
  List<String> initialDays,
) async {
  List<String> tempSelectedDays = List.from(initialDays);

  final List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  return showDialog<List<String>>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      backgroundColor: AppColors.surfaceGrey,
      contentPadding: EdgeInsets.all(20.w),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sync, color: AppColors.backgroundDark, size: 28),

              SizedBox(height: 16.h),

              /// Title
              const Text(
                "Select days of the week",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.backgroundDark,
                ),
              ),

              SizedBox(height: 12.h),

              /// Description
              const Text(
                "Choose the day(s) you want this notification to repeat each week. Select one or more days for your weekly notification.",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 13, color: AppColors.darkGrey),
              ),

              SizedBox(height: 20.h),

              /// Days Chips
              Wrap(
                spacing: 8.w,
                runSpacing: 10.h,
                alignment: WrapAlignment.start,
                children: weekDays.map((day) {
                  final isSelected = tempSelectedDays.contains(day);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          tempSelectedDays.remove(day);
                        } else {
                          tempSelectedDays.add(day);
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.surfaceBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFE0E4E7),
                        ),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.backgroundDark,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 24.h),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 14, color: AppColors.primary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, tempSelectedDays),
                    child: const Text(
                      "Ok",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}
