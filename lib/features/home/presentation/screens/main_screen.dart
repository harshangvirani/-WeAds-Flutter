import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:we_ads/core/providers/user_provider.dart';
import 'package:we_ads/features/admin/presentation/screens/admin_home_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/nav_provider.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'saved_page.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final selectedIndex = ref.watch(navIndexProvider);

    // Define pages for each role
    final List<Widget> normalPages = [
      HomePage(),
      const SavedPage(),
      const ProfilePage(),
    ];
    final List<Widget> adminPages = [
      const AdminHomePage(),
      const ProfilePage(),
    ];

    final List<Widget> currentPages = role == UserRole.admin
        ? adminPages
        : normalPages;
    final int safeIndex = selectedIndex >= currentPages.length
        ? 0
        : selectedIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (safeIndex != 0) {
          ref.read(navIndexProvider.notifier).state = 0;
        } else {
          _showExitDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.mainBg,
        body: currentPages[safeIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.lightGrey, width: 0.5.w),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: safeIndex,
            onTap: (index) => ref.read(navIndexProvider.notifier).state = index,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.mediumGrey,
            type: BottomNavigationBarType.fixed,
            items: role == UserRole.admin
                ? const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.branding_watermark_outlined),
                      label: 'Notifications',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      label: 'Profile',
                    ),
                  ]
                : const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.inbox),
                      label: 'For you',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bookmark_border_rounded),
                      label: 'Saved',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      label: 'Profile',
                    ),
                  ],
          ),
        ),

        floatingActionButton: (role == UserRole.admin && safeIndex == 0)
            ? FloatingActionButton(
                onPressed: () => context.push('/create-notification'),
                backgroundColor: AppColors.surfaceBlue,
                child: const Icon(Icons.add, color: AppColors.primary),
              )
            : (role == UserRole.normal && safeIndex == 0)
            ? FloatingActionButton(
                onPressed: () => context.push('/new-post'),
                backgroundColor: AppColors.surfaceBlue,
                child: const Icon(Icons.add, color: AppColors.primary),
              )
            : null,
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
