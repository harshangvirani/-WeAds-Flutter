import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:we_ads/core/providers/user_provider.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/utils/filter_utils.dart';
import 'package:we_ads/core/widgets/category_chip.dart';
import 'package:we_ads/core/widgets/common_fade_animation.dart';
import 'package:we_ads/core/widgets/common_skeleton.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';
import 'package:we_ads/core/widgets/gradient_background.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/home/presentation/providers/profile_provide.dart';
import 'package:we_ads/features/home/presentation/widgets/post_card.dart';
import 'package:we_ads/features/posts/presentation/providers/my_posts_provider.dart';
import '../widgets/profile_header.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userProfileDataProvider.future);
      ref.read(selectedCategoriesProvider.notifier).state = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCats = ref.watch(selectedCategoriesProvider);
    final myPostsAsync = ref.watch(myPostsProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: CustomAppBar(
        title: "Profile",
        titleColor: AppColors.backgroundDark,
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: GradientBackground(
        isMainGradient: true,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myPostsProvider);
            ref.invalidate(userProfileDataProvider);

            await Future.wait([
              ref.read(myPostsProvider.future),
              ref.read(userProfileDataProvider.future),
            ]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ProfileHeader(user: user),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: const Text(
                  "My posts",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundDark,
                  ),
                ),
              ),

              /// Category filter
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
                              ),
                            );
                          },
                        ),
                        loading: () => Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return CommonSkeleton(height: 10.h);
                            },
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),

              /// POSTS
              myPostsAsync.when(
                data: (postsData) {
                  final posts = postsData.data?.posts ?? [];

                  if (posts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "No posts found",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: posts.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => CommonFadeAnimation(
                      delay: index * 0.1,
                      child: PostCard(
                        post: posts[index],
                        isMyProfile: true,
                        profileImg: index == 0
                            ? postsData.data?.profilePhoto?.fileUrl
                            : null,
                        firstName: postsData.data?.firstName ?? "",
                        lastName: postsData.data?.lastName ?? "",
                      ),
                    ),
                  );
                },
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
                error: (err, _) => Center(
                  child: Text(
                    "Error loading posts: $err",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }
}
