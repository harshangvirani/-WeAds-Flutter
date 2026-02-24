import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:we_ads/core/network/api_error_handler.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/utils/filter_utils.dart';
import 'package:we_ads/core/widgets/category_chip.dart';
import 'package:we_ads/core/widgets/common_skeleton.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';
import 'package:we_ads/core/widgets/gradient_background.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/home/presentation/widgets/post_card.dart';
import 'package:we_ads/features/posts/data/modals/post_model.dart';
import 'package:we_ads/features/posts/data/modals/saved_post_response_madel.dart';
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

  /// Groups posts by date header (Today / Yesterday / d MMM yyyy), sorted latest first.
  Map<String, List<_PostWithUser>> _groupByDate(
    List<SavedPostResponse> responses,
  ) {
    final Map<String, List<_PostWithUser>> grouped = {};

    // Each response entry is one user + one post
    final List<_PostWithUser> allPosts = responses
        .where((r) => r.post != null)
        .map(
          (r) => _PostWithUser(
            post: r.post!,
            firstName: r.firstName,
            lastName: r.lastName,
            profilePhotoUrl: r.profilePhotoUrl,
          ),
        )
        .toList();

    // Sort descending (newest first)
    allPosts.sort(
      (a, b) => (b.post.enteredOn ?? DateTime(0)).compareTo(
        a.post.enteredOn ?? DateTime(0),
      ),
    );

    for (final item in allPosts) {
      if (item.post.enteredOn == null) continue;
      final date = item.post.enteredOn!;
      final now = DateTime.now();
      String header;

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        header = "Today";
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1) {
        header = "Yesterday";
      } else {
        header = DateFormat('d MMM yyyy').format(date);
      }

      grouped.putIfAbsent(header, () => []).add(item);
    }
    return grouped;
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
            /// Category Filter Bar
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
                                      .state =
                                      current
                                          .where((e) => e != name)
                                          .toList();
                                } else {
                                  ref
                                      .read(selectedCategoriesProvider.notifier)
                                      .state = [...current, name];
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

            /// Saved Posts List
            Expanded(
              child: savedPostsAsync.when(
                data: (responses) {
                  final groupedPosts = _groupByDate(responses);

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(savedPostsProvider);
                      ref.invalidate(categoriesProvider);
                      await ref.read(savedPostsProvider.future);
                    },
                    child: groupedPosts.isEmpty
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
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            itemCount: groupedPosts.length,
                            itemBuilder: (context, index) {
                              final dateHeader =
                                  groupedPosts.keys.elementAt(index);
                              final postsForDate = groupedPosts[dateHeader]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(
                                    height: 1,
                                    color: AppColors.lightGrey,
                                    indent: 16.w,
                                    endIndent: 16.w,
                                  ),
                                  _buildDateHeader(dateHeader),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: postsForDate.length,
                                    itemBuilder: (context, postIndex) {
                                      final item = postsForDate[postIndex];
                                      return PostCard(
                                        post: item.post,
                                        firstName: item.firstName,
                                        lastName: item.lastName,
                                        profileImg: item.profilePhotoUrl,
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              );
                            },
                          ),
                  );
                },
                loading: () => SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        shrinkWrap: true,
                        itemBuilder: (context, index) => Container(
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
                        ),
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemCount: 5,
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

/// Helper model to carry user info alongside each post.
class _PostWithUser {
  final PostModel post;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoUrl;

  _PostWithUser({
    required this.post,
    this.firstName,
    this.lastName,
    this.profilePhotoUrl,
  });
}

Widget _buildDateHeader(String date) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: Center(
      child: Text(
        date,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.mediumGrey,
        ),
      ),
    ),
  );
}
