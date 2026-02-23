import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:we_ads/core/network/api_error_handler.dart';
import 'package:we_ads/core/utils/filter_utils.dart';
import 'package:we_ads/core/widgets/category_chip.dart';
import 'package:we_ads/core/widgets/common_fade_animation.dart';
import 'package:we_ads/core/widgets/common_skeleton.dart';
import 'package:we_ads/core/widgets/gradient_background.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/home/data/modal/feed_model.dart';
import 'package:we_ads/features/home/presentation/providers/user_feed_provider.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:we_ads/features/home/presentation/widgets/feed_user_tile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final Set<int> selectedIndices = {0};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedFeedUserProvider.notifier).state = FeedUser();
      ref.read(selectedCategoriesProvider.notifier).state = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCats = ref.watch(selectedCategoriesProvider);
    final userFeedAsync = ref.watch(userFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: CustomAppBar(
        showLogo: true,
        backgroundColor: AppColors.surface,
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
            /// Category Filter Bar
            Container(
              height: 60.h,
              padding: EdgeInsets.symmetric(vertical: 10.h),
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
                              label: name,
                              isSelected: isSelected,
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
                      error: (_, __) => const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.lightGrey),

            /// Feed List
            Expanded(
              child: userFeedAsync.when(
                data: (users) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(userFeedProvider);
                    ref.invalidate(categoriesProvider);
                    await ref.read(userFeedProvider.future);
                  },
                  child: users.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(
                              child: Text(
                                "No feed available",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.backgroundDark,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: users.length,
                          padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: AppColors.lightGrey,
                          ),
                          itemBuilder: (context, index) {
                            final user = users[index];

                            final List<Color> avatarColors = [
                              const Color(0xFF7A5421),
                              const Color(0xFF005F73),
                              const Color(0xFF7A5421),
                              const Color(0xFF005F73),
                            ];

                            final avatarColor =
                                avatarColors[index % avatarColors.length];
                            final initials =
                                "${user.firstName?[0]}${user.lastName?[0]}";

                            return CommonFadeAnimation(
                              delay: index * 0.1,
                              child: FeedUserTile(
                                user: user,
                                avatarColor: avatarColor,
                                initials: initials,
                                onTap: () async {
                                  Future.microtask(() {
                                    ref
                                        .read(selectedFeedUserProvider.notifier)
                                        .state = user;
                                  });

                                  await context.push('/user-posts-list',
                                      extra: user.userId);
                                  ref.invalidate(userFeedProvider);
                                },
                              ),
                            );
                          },
                        ),
                ),
                loading: () => SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return CommonSkeleton.box(height: 100.h);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(height: 8.h);
                        },
                        itemCount: 10,
                      ),
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
                      const Text(
                        "Feed Unavailable",
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
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(userFeedProvider),
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

