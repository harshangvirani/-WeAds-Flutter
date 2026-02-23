import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/utils/filter_utils.dart';
import 'package:we_ads/core/widgets/category_chip.dart';
import 'package:we_ads/core/widgets/common_fade_animation.dart';
import 'package:we_ads/core/widgets/common_skeleton.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/home/presentation/providers/user_feed_provider.dart';
import 'package:we_ads/features/home/presentation/widgets/feed_user_tile.dart';
import 'package:we_ads/features/search/presentation/providers/search_provider.dart';
import 'package:we_ads/core/widgets/custom_text_field.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _cityController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    
    Future.microtask(() {
      ref.read(selectedCategoriesProvider.notifier).state = [];
      ref.read(searchQueryProvider.notifier).state = "";
    });
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultProvider);
    final selectedCats = ref.watch(selectedCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.backgroundDark,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: SizedBox(
          height: 48.h,
          child: CustomTextField(
            labelText: "",
            hintText: "Search by name or city...",
            autofocus: true,
            controller: _searchController,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: AppColors.surfaceGrey,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.backgroundDark),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = "";
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Category Filter
          _buildCategoryFilter(),

          Expanded(
            child: searchResultsAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      "No user found",
                      style: TextStyle(color: AppColors.mediumGrey),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.lightGrey),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final initials = "${user.firstName?[0] ?? ''}${user.lastName?[0] ?? ''}";
                    
                    final List<Color> avatarColors = [
                      const Color(0xFF7A5421),
                      const Color(0xFF005F73),
                      const Color(0xFFE9C46A),
                      const Color(0xFFF4A261),
                    ];
                    final avatarColor = avatarColors[index % avatarColors.length];

                    return CommonFadeAnimation(
                      delay: index * 0.05,
                      child: FeedUserTile(
                        user: user,
                        avatarColor: avatarColor,
                        initials: initials,
                        onTap: () async {
                          ref.read(selectedFeedUserProvider.notifier).state = user;
                          await context.push('/user-posts-list', extra: user.userId);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (_, __) => CommonSkeleton.box(height: 80.h),
              ),
              error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: AppColors.errorRed))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCats = ref.watch(selectedCategoriesProvider);

    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.lightGrey)),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => FilterUtils.showCategorySheet(context),
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

                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: AnimatedScale(
                      scale: isSelected ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: CategoryChip(
                        label: name,
                        isSelected: isSelected,
                        onTap: () {
                          final current = ref.read(selectedCategoriesProvider);
                          if (isSelected) {
                            ref.read(selectedCategoriesProvider.notifier).state =
                                current.where((e) => e != name).toList();
                          } else {
                            ref.read(selectedCategoriesProvider.notifier).state = [
                              ...current,
                              name,
                            ];
                          }
                        },
                      ),
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
    );
  }
}
