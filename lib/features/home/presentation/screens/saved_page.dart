import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/network/api_error_handler.dart';
import 'package:we_ads/core/utils/filter_utils.dart';
import 'package:we_ads/core/widgets/category_chip.dart';
import 'package:we_ads/core/widgets/common_fade_animation.dart';
import 'package:we_ads/core/widgets/common_skeleton.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';
import 'package:we_ads/core/widgets/gradient_background.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/home/presentation/widgets/post_card.dart';
import 'package:we_ads/features/posts/presentation/providers/saved_posts_provider.dart';

class SavedPage extends ConsumerStatefulWidget {
  const SavedPage({super.key});

  @override
  ConsumerState<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends ConsumerState<SavedPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedCategoriesProvider.notifier).state = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedPostsAsync = ref.watch(savedPostsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCats = ref.watch(selectedCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: CustomAppBar(
        title: "Saved",
        titleColor: AppColors.backgroundDark,
        backgroundColor: AppColors.surface,
        showLogo: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: GradientBackground(
        isMainGradient: true,
        child: Column(
          children: [
            /// Filter Bar
            Container(
              height: 60.h,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              color: AppColors.white.withOpacity(0.5),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        ref.watch(categoriesProvider);
                        FilterUtils.showCategorySheet(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: categoriesAsync.when(
                      data: (list) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final cat = list[index];
                          final name = cat.categoryName ?? "";
                          final isSelected = selectedCats.contains(name);

                          return AnimatedScale(
                            scale: isSelected ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: CategoryChip(
                              key: ValueKey(name),
                              isSelected: isSelected,
                              label: name,
                              onTap: () {
                                final current = ref.read(
                                  selectedCategoriesProvider,
                                );
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
                            ),
                          );
                        },
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.lightGrey),

            /// Saved Posts
            Expanded(
              child: savedPostsAsync.when(
                data: (posts) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(savedPostsProvider);
                    ref.invalidate(categoriesProvider);
                    await ref.read(savedPostsProvider.future);
                  },
                  child: posts.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(
                              child: Text(
                                "No saved posts found.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.backgroundDark,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: posts.length,
                          itemBuilder: (context, index) => CommonFadeAnimation(
                            delay: index * 0.1,
                            child: PostCard(post: posts[index]),
                          ),
                        ),
                ),
                loading: () => SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 16.w,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const CommonSkeleton(
                                      shape: SkeletonShape.circle,
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(width: 12.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CommonSkeleton.line(width: 150.w),
                                        SizedBox(height: 8.h),
                                        CommonSkeleton.line(width: 100.w),
                                      ],
                                    ),
                                  ],
                                ),
                                CommonSkeleton.box(height: 200.h),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(height: 8.h);
                        },
                        itemCount: 10,
                      ), // The Image box
                    ],
                  ),
                ),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.errorRed,
                        size: 48,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Saved Posts Unavailable",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(
                          ApiErrorHandler.getErrorMessage(err),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(savedPostsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Try Again"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
