import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

void showLocationPicker(
  BuildContext context,
  Function(String) onLocationSelected,
) {
  final List<String> suggestions = [
    "Current location",
    "84th street, bell rose, NJ",
    "Time square, NYC, NY",
    "Manhattan, NY",
    "Taipei, Taiwan",
    "Florida, USA",
    "Chicago, USA",
    "Indiana",
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceLow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 16.h),

          /// Drag handle
          Container(
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.borderGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),

          SizedBox(height: 30.h),

          /// Search Field
          TextField(
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: AppColors.backgroundDark,
            ),
            decoration: InputDecoration(
              hintText: "Search location",
              hintStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: AppColors.mediumGrey,
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              suffixIconConstraints: BoxConstraints(
                minWidth: 24.w,
                minHeight: 24.h,
              ),
              suffixIcon: const Icon(
                Icons.search,
                color: AppColors.backgroundDark,
                size: 22,
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                onLocationSelected(value);
                Navigator.pop(context);
              }
            },
          ),

          const Divider(color: AppColors.borderGrey, thickness: 1, height: 1),

          SizedBox(height: 8.h),

          /// Suggestions
          Expanded(
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    suggestions[index],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                  onTap: () {
                    onLocationSelected(suggestions[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
