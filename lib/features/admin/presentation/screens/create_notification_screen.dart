import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_ads/core/constants/assets_manager.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/theme/app_text_styles.dart';
import 'package:we_ads/core/utils/utility.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';
import 'package:we_ads/core/widgets/custom_text_field.dart';
import 'package:we_ads/core/widgets/dashed_border_painter.dart';
import 'package:we_ads/core/widgets/show_custom_date_range_picker.dart';
import 'package:we_ads/core/widgets/show_custom_time_picker.dart';
import 'package:we_ads/core/widgets/show_days_of_week_picker.dart';
import 'package:we_ads/core/widgets/show_image_source_sheet.dart';
import 'package:we_ads/core/widgets/show_location_picker.dart';
import 'package:we_ads/features/admin/provider/notification_provider.dart';

class CreateNotificationScreen extends ConsumerWidget {
  const CreateNotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: const CustomAppBar(
        title: "Create notification",
        showBackButton: true,
        backgroundColor: AppColors.lightBlueTint,
        titleColor: AppColors.backgroundDark,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 120.h),
        child: Column(
          children: [
            _buildImagePicker(context, ref, ref.watch(selectedImagesProvider)),
            _buildForm(),
            _buildTargetLocation(ref, context),
            _buildTrigger(context, ref),
            _buildRepeat(ref, context),
          ],
        ),
      ),

      bottomNavigationBar: _buildPostButton(),
    );
  }

  // Image Picker
  Widget _buildImagePicker(
    BuildContext context,
    WidgetRef ref,
    List<String>? images,
  ) {
    return _buildWhiteContainer(
      isBg: false,
      isMargin: false,
      padding: EdgeInsets.all(16.w),
      child: CustomPaint(
        painter: DashedBorderPainter(color: AppColors.borderGrey),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 120.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: images!.isEmpty
              ? _buildInitialPlaceholder(context, ref, images)
              : Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    alignment: WrapAlignment.start,
                    children: [
                      ...images.map(
                        (path) => _buildImageThumbnail(path, images, ref),
                      ),
                      _buildSmallAddButton(context, ref, images),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInitialPlaceholder(
    BuildContext context,
    WidgetRef ref,
    List<String> images,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () {
        showImageSourceSheet(context, (path) {
          ref.read(selectedImagesProvider.notifier).state = [...images, path];
        });
      },
      child: SizedBox(
        height: 120.h,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: AppColors.backgroundDark,
              size: 22,
            ),
            SizedBox(width: 8.w),
            Text(
              "Add image",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallAddButton(
    BuildContext context,
    WidgetRef ref,
    List<String> images,
  ) {
    return GestureDetector(
      onTap: () => showImageSourceSheet(context, (path) {
        ref.read(selectedImagesProvider.notifier).state = [...images, path];
      }),
      child: Container(
        width: 80.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Icon(
            Icons.add_a_photo_outlined,
            color: AppColors.primary,
            size: 28,
          ),
        ),
      ),
    );
  }

  // Individual Image thumbnail with delete button
  Widget _buildImageThumbnail(String path, List<String> images, WidgetRef ref) {
    final bool isNetwork = path.startsWith('http'); // Basic check

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: isNetwork
              ? Image.network(
                  path,
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(path),
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: -5.h,
          right: -5.w,
          child: GestureDetector(
            onTap: () => ref.read(selectedImagesProvider.notifier).state =
                images.where((e) => e != path).toList(),
            child: CircleAvatar(
              radius: 10.r,
              backgroundColor: AppColors.backgroundDark,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return _buildWhiteContainer(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomTextField(labelText: "Title"),
          SizedBox(height: 16.h),
          const CustomTextField(labelText: "Description"),
          SizedBox(height: 16.h),
          _buildCityField(),
        ],
      ),
    );
  }

  //  Target location
  Widget _buildTargetLocation(WidgetRef ref, BuildContext context) {
    final List<String> locations = ref.watch(selectedLocationsProvider);
    return _buildWhiteContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSectionHeader(
            "Target location",
            icon: Icons.add_location_alt_outlined,
            onIconTap: () => showLocationPicker(context, (newLocation) {
              final current = ref.read(selectedLocationsProvider);
              if (!current.contains(newLocation)) {
                ref.read(selectedLocationsProvider.notifier).state = [
                  ...current,
                  newLocation,
                ];
              }
            }),
          ),
          const Divider(height: 1, color: AppColors.surface),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: locations
                    .map((loc) => _buildLocationChip(loc, ref))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Rrigger and Time

  Widget _buildTrigger(BuildContext context, WidgetRef ref) {
    final String timeLabel = ref.watch(selectedTimeProvider);
    return _buildWhiteContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              _selectDate(context);
            },
            child: _buildTileRow(
              "Trigger on",
              "Jan 12",
              Icons.calendar_today_outlined,
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          InkWell(
            onTap: () async {
              // Open picker and wait for result
              final result = await showCustomTimePicker(context);

              if (result != null) {
                // Format the time (e.g., 09:00 AM)
                final formattedTime = result.format(context);

                ref.read(selectedTimeProvider.notifier).state = formattedTime;
              }
            },

            child: _buildTileRow("Time", timeLabel, Icons.more_time_outlined),
          ),
          if (ref.watch(selectedTimesProvider).isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Wrap(
                spacing: 8.w,
                children: ref
                    .watch(selectedTimesProvider)
                    .map(
                      (time) => _buildSelectionChip(
                        time,
                        ref,
                        provider: selectedTimesProvider,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionChip(
    String label,
    WidgetRef ref, {
    required StateProvider<List<String>> provider,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () {
              final current = ref.read(provider);
              ref.read(provider.notifier).state = current
                  .where((e) => e != label)
                  .toList();
            },
            child: Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // For the Date Picker Popup
  Future<void> _selectDate(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            useMaterial3: true,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceLow,
              onSurface: AppColors.backgroundDark,
            ),
            textTheme: Theme.of(context).textTheme.apply(
              fontFamily: null, // uses app font
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Widget _buildRepeat(WidgetRef ref, BuildContext context) {
    final selectedRepeat = ref.watch(selectedRepeatProvider);
    final repeatDesc = ref.watch(repeatDescriptionProvider);

    final List<String> repeatOptions = [
      "Do not repeat",
      "Daily",
      "Weekly",
      "Monthly",
      "Yearly",
      "Custom",
    ];

    return _buildWhiteContainer(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Repeat"),

          // Dynamic Date Range Text (e.g. "Aug 17 – Aug 23")
          if (repeatDesc.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 16.w, bottom: 12.h),
              child: Text(
                repeatDesc,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.backgroundDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 10.h,
              children: repeatOptions.map((label) {
                final isSelected = selectedRepeat == label;
                return GestureDetector(
                  onTap: () async {
                    ref.read(selectedRepeatProvider.notifier).state = label;

                    if (label == "Weekly") {
                      // Show Days Picker
                      final days = await showDaysOfWeekPicker(
                        context,
                        ref.read(selectedDaysProvider),
                      );
                      if (days != null && days.isNotEmpty) {
                        ref.read(selectedDaysProvider.notifier).state = days;
                        // Format the string: "Every Monday, Tuesday and Friday"
                        String desc = "Every ${days.join(', ')}";
                        if (days.length > 1) {
                          int lastComma = desc.lastIndexOf(',');
                          desc = desc.replaceRange(
                            lastComma,
                            lastComma + 1,
                            " and",
                          );
                        }
                        ref.read(repeatDescriptionProvider.notifier).state =
                            desc;
                      }
                    } else if (label == "Custom") {
                      final range = await showCustomDateRangePicker(context);
                      if (range != null) {
                        ref.read(repeatDescriptionProvider.notifier).state =
                            "${formatDateRange(range.start)} – ${formatDateRange(range.end)}";
                      }
                    } else {
                      ref.read(repeatDescriptionProvider.notifier).state = "";
                      ref.read(selectedDaysProvider.notifier).state = [];
                    }
                  },
                  child: _buildRepeatChip(
                    label,
                    isSelected: isSelected,
                    ref: ref,
                    context: context,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatChip(
    String label, {
    required bool isSelected,
    required WidgetRef ref,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceBlue : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isSelected ? Colors.transparent : AppColors.borderGrey,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? AppColors.primary : AppColors.backgroundDark,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected && label != "Do not repeat") ...[
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () async {
                ref.read(selectedRepeatProvider.notifier).state = label;

                if (label == "Weekly" || label == "Custom") {
                  final DateTimeRange? range = await showCustomDateRangePicker(
                    context,
                  );

                  if (range != null) {
                    // Format the dates: "Aug 17 – Aug 23"
                    final String start = formatDateRange(range.start);
                    final String end = formatDateRange(range.end);

                    ref.read(repeatDescriptionProvider.notifier).state =
                        "$start – $end";
                  }
                } else {
                  // Reset description for simple repeats like "Daily"
                  ref.read(repeatDescriptionProvider.notifier).state = "";
                }
              },
              child: Icon(Icons.close, size: 14, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  // Post button
  Widget _buildPostButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: Size(double.infinity, 50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
        ),
        child: Text(
          "Post",
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Common Widgets

  Widget _buildWhiteContainer({
    required Widget child,
    required EdgeInsets padding,
    bool isBg = true,
    bool isMargin = true,
  }) {
    return Container(
      margin: isMargin ? EdgeInsets.all(16.w) : EdgeInsets.zero,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: isBg ? AppColors.lightBlueTint : null,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(
    String title, {
    IconData? icon,
    VoidCallback? onIconTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.backgroundDark,
            ),
          ),
          if (icon != null)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(icon, size: 20, color: AppColors.backgroundDark),
              onPressed: onIconTap,
            ),
        ],
      ),
    );
  }

  Widget _buildCityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          labelText: "Zipcode or Name of your city",
          suffixIcon: Padding(
            padding: EdgeInsets.all(12.w),
            child: SvgPicture.asset(
              AssetsManager.zipcodeIcon,
              width: 30.w,
              height: 30.h,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4.h, left: 4.w),
          child: Text(
            "City",
            style: TextStyle(fontSize: 11, color: AppColors.backgroundDark),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationChip(String label, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.backgroundDark),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: () {
              final current = ref.read(selectedLocationsProvider);
              ref.read(selectedLocationsProvider.notifier).state = current
                  .where((item) => item != label)
                  .toList();
            },
            child: Icon(Icons.close, size: 14, color: AppColors.backgroundDark),
          ),
        ],
      ),
    );
  }

  // Widget _buildRepeatChip(String label, {bool isSelected = false}) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(8.r),
  //       border: Border.all(
  //         color: isSelected ? AppColors.primary :  AppColors.borderGrey,
  //       ),
  //     ),
  //     child: Text(
  //       label,
  //       style: TextStyle(
  //         fontSize: 13,
  //         color: isSelected ? AppColors.primary : AppColors.backgroundDark,
  //         fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTileRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.backgroundDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.backgroundDark, size: 20.sp),
        ],
      ),
    );
  }
}
