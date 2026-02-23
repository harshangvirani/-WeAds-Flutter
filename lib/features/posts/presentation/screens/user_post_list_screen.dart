import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:we_ads/core/constants/assets_manager.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/theme/app_text_styles.dart';
import 'package:we_ads/core/utils/filter_utils.dart';
import 'package:we_ads/core/widgets/category_chip.dart';
import 'package:we_ads/core/widgets/gradient_background.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/home/presentation/providers/other_user_posts_provider.dart';
import 'package:we_ads/features/home/presentation/providers/user_feed_provider.dart';
import 'package:we_ads/features/home/presentation/widgets/post_card.dart';
import 'package:we_ads/features/posts/data/modals/post_model.dart';

class UserPostListScreen extends ConsumerStatefulWidget {
  const UserPostListScreen({super.key});
  @override
  ConsumerState<UserPostListScreen> createState() => _UserPostListScreenState();
}

class _UserPostListScreenState extends ConsumerState<UserPostListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedCategoriesProvider.notifier).state = [];
    });
  }

  Map<String, List<PostModel>> _groupPostsByDate(List<PostModel> posts) {
    Map<String, List<PostModel>> grouped = {};

    // Sort posts by date descending first (Latest first)
    posts.sort(
      (a, b) =>
          (b.enteredOn ?? DateTime(0)).compareTo(a.enteredOn ?? DateTime(0)),
    );
    for (var post in posts) {
      if (post.enteredOn == null) continue;

      String dateHeader;
      DateTime date = post.enteredOn!;
      DateTime now = DateTime.now();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        dateHeader = "Today";
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1) {
        dateHeader = "Yesterday";
      } else {
        dateHeader = DateFormat('d MMM yyyy').format(date);
      }

      grouped.putIfAbsent(dateHeader, () => []).add(post);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final viewPost = ref.watch(viewPostProvider);
    final selectedUser = ref.watch(selectedFeedUserProvider);
    final initials =
        "${selectedUser.firstName?[0] ?? ''}${selectedUser.lastName?[0] ?? ''}";
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCats = ref.watch(selectedCategoriesProvider);
    final otherUserPostsAsync = ref.watch(otherUserPostsProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.backgroundDark,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.accentGold,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "${selectedUser.firstName} ${selectedUser.lastName}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.backgroundDark,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        selectedUser.description ?? "",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.phone_outlined, color: AppColors.backgroundDark),
              onPressed: () {
                FilterUtils.showPhoneDialog(
                  context,
                  selectedUser.mobileNo ?? "",
                );
              },
            ),
            IconButton(
              icon: SvgPicture.asset(
                AssetsManager.messageIcon,
                width: 30.w,
                height: 30.h,
                colorFilter: ColorFilter.mode(
                  AppColors.backgroundDark,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => FilterUtils.showMessageDialog(
                context,
                null,
                AssetsManager.messageIcon,
                selectedUser.mobileNo ?? "",
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: GradientBackground(
          isMainGradient: true,
          child: Column(
            children: [
              // Category Filter Row
              Container(
                height: 60.h,

                padding: EdgeInsets.symmetric(vertical: 10.h),
                color: Colors.transparent,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () => {
                          ref.watch(categoriesProvider),
                          FilterUtils.showCategorySheet(context),
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
                                isSelected: isSelected,
                                label: name,
                                onTap: () {
                                  final current = ref.read(
                                    selectedCategoriesProvider,
                                  );
                                  if (isSelected) {
                                    ref
                                        .read(
                                          selectedCategoriesProvider.notifier,
                                        )
                                        .state = current
                                        .where((e) => e != name)
                                        .toList();
                                  } else {
                                    ref
                                        .read(
                                          selectedCategoriesProvider.notifier,
                                        )
                                        .state = [
                                      ...current,
                                      name,
                                    ];
                                  }
                                },
                                key: ValueKey(name),
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

              // Expanded(
              //   child: ListView(
              //     padding: EdgeInsets.symmetric(vertical: 10.h),
              //     children: [
              //       Divider(
              //         height: 1,
              //         color: AppColors.lightGrey,
              //         indent: 16.w,
              //         endIndent: 16.w,
              //       ),
              //       _buildDateHeader("25 Nov 2025"),
              //       // const PostCard(mediaType: 'audio'),
              //       // const PostCard(mediaType: 'audio'),
              //       SizedBox(height: 10.h),
              //       Divider(
              //         height: 1,
              //         color: AppColors.lightGrey,
              //         indent: 16.w,
              //         endIndent: 16.w,
              //       ),
              //       _buildDateHeader("Today"),
              //       // const PostCard(mediaType: 'image_scroll'),
              //     ],
              //   ),
              // ),
              Expanded(
                child: otherUserPostsAsync.when(
                  data: (response) {
                    final posts = response.data?.posts ?? [];
                    if (posts.isEmpty) {
                      return const Center(
                        child: Text(
                          "No posts found",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      );
                    }

                    // Group the posts
                    final groupedPosts = _groupPostsByDate(posts);

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      itemCount: groupedPosts.length,
                      itemBuilder: (context, index) {
                        String dateHeader = groupedPosts.keys.elementAt(index);
                        List<PostModel> postsForDate =
                            groupedPosts[dateHeader]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              height: 1,
                              color: AppColors.lightGrey,
                              indent: 16.w,
                              endIndent: 16.w,
                            ),

                            // Date Header UI
                            _buildDateHeader(dateHeader),

                            // List of posts for this specific date
                            ListView.builder(
                              shrinkWrap:
                                  true, // Necessary inside another ListView
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: postsForDate.length,
                              itemBuilder: (context, postIndex) {
                                final post = postsForDate[postIndex];

                                // Extract fileUrl from the profilePhoto object in the response
                                final String? profileImageUrl = response
                                    .data
                                    ?.profilePhoto
                                    ?.toString();

                                return PostCard(
                                  post: post,
                                  profileImg:
                                      profileImageUrl, // Pass the extracted string URL
                                  firstName: response.data?.firstName,
                                  lastName: response.data?.lastName,
                                );
                              },
                            ),
                            SizedBox(height: 10.h),
                          ],
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text(
                      err.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
