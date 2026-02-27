import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/utils/category_icon_helper.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';

class CategoryFilterSheet extends ConsumerWidget {
  final bool? safeArea;
  const CategoryFilterSheet({super.key, this.safeArea = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCats = ref.watch(selectedCategoriesProvider);
    final filteredCatsAsync = ref.watch(filteredCategoriesProvider);

    return SafeArea(
      top: false,
      bottom: safeArea ?? false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Drag Handle
            Center(
              child: Container(
                width: 50.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.mediumGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            SizedBox(height: 30.h),

            /// Search Field
            TextField(
              onChanged: (value) =>
                  ref.read(categorySearchProvider.notifier).state = value,
              decoration: const InputDecoration(
                hintText: "Search category",
                border: InputBorder.none,
                suffixIcon: Icon(Icons.search, color: AppColors.backgroundDark),
                hintStyle: TextStyle(fontSize: 16, color: AppColors.mediumGrey),
              ),
            ),

            SizedBox(height: 20.h),

            /// Title
            const Text(
              "Select category",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.backgroundDark,
              ),
            ),

            SizedBox(height: 16.h),

            /// Categories List
            Expanded(
              child: SingleChildScrollView(
                child: filteredCatsAsync.when(
                  data: (list) => Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: list.map((cat) {
                      final name = cat.categoryName ?? "";
                      final isSelected = selectedCats.contains(name);

                      return GestureDetector(
                        onTap: () {
                          final current = ref.read(selectedCategoriesProvider);

                          if (isSelected) {
                            ref
                                .read(selectedCategoriesProvider.notifier)
                                .state = current
                                .where((e) => e != name)
                                .toList();
                          } else {
                            ref
                                .read(selectedCategoriesProvider.notifier)
                                .state = [
                              ...current,
                              name,
                            ];
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFD6E9EE)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                            border: !isSelected
                                ? Border.all(
                                    color: AppColors.lightGrey,
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: IntrinsicWidth(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CategoryIconHelper.getIconForCategory(name),
                                  size: 16,
                                  color: isSelected ? AppColors.primary : AppColors.darkGrey,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.backgroundDark,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(
                    child: Text(
                      "Failed to load categories",
                      style: TextStyle(fontSize: 14, color: AppColors.errorRed),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
