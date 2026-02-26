import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_ads/features/admin/presentation/screens/create_notification_screen.dart';
import 'package:we_ads/features/auth/presentation/screens/create_profile_screen.dart';
import 'package:we_ads/features/auth/presentation/screens/register_screen.dart';
import 'package:we_ads/features/auth/presentation/screens/success_screen.dart';
import 'package:we_ads/features/posts/presentation/screens/video_view_screen.dart';
import 'package:we_ads/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:we_ads/features/home/presentation/screens/main_screen.dart';
import 'package:we_ads/features/home/presentation/screens/profile_page.dart';
import 'package:we_ads/features/manageSubscription/presentation/manage_subscription_screen.dart';
import 'package:we_ads/features/noInternet/presentation/no_internet_screen.dart';
import 'package:we_ads/features/posts/data/modals/post_model.dart';
import 'package:we_ads/features/posts/presentation/screens/edit_post_screen.dart';
import 'package:we_ads/features/posts/presentation/screens/new_post_screen.dart';
import 'package:we_ads/features/posts/presentation/screens/user_post_list_screen.dart';
import 'package:we_ads/features/search/presentation/search_screen.dart';
import 'package:we_ads/features/setting/presentation/settings_screen.dart';
import 'package:we_ads/features/user_notification/presentation/user_notification_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // Auth Flow
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Admin Specific Routes
      GoRoute(
        path: '/create-notification',
        builder: (context, state) => const CreateNotificationScreen(),
      ),
      // Registration/Onboarding Flow
      GoRoute(
        path: '/create-profile',

        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return CreateProfileScreen(
            phoneNumber: data['phoneNumber'] ?? '',
            countryText: data['countryText'] ?? 'US',
            fullMobileNumber: data['fullMobileNumber'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => const SuccessScreen(),
      ),

      // Main App
      GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/user-posts-list',
        builder: (context, state) => const UserPostListScreen(),
      ),
      GoRoute(
        path: '/new-post',
        builder: (context, state) => const NewPostScreen(),
      ),
      GoRoute(
        path: '/edit-post',
        builder: (context, state) {
           if(state.extra is PostModel) {
              return EditPostScreen(post: state.extra as PostModel);
           }
           return const Scaffold(body: Center(child: Text("Post data missing")));
        },
      ),
      GoRoute(
        path: '/video-preview',
        builder: (context, state) {
          // Safely check if extra is actually a File
          if (state.extra is File) {
            final videoFile = state.extra as File;
            return VideoViewScreen(videoFile: videoFile);
          }

          // Fallback if data is missing during a refresh/reload
          return const Scaffold(
            body: Center(child: Text("Video file not found")),
          );
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/manage_subscription',
        builder: (context, state) => const ManageSubscriptionScreen(),
      ),
      GoRoute(
        path: '/user_notifications',
        builder: (context, state) => const UserNotificationScreen(),
      ),
      GoRoute(
        path: '/no-internet',
        builder: (context, state) => const NoInternetScreen(),
      ),
    ],
  );
});
