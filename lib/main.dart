// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/providers/connectivity_provider.dart';
import 'package:we_ads/core/providers/flavor_provider.dart';
import 'package:we_ads/features/noInternet/presentation/no_internet_screen.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // await Firebase.initializeApp();
//   runApp(const ProviderScope(child: WeAdsApp()));
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_ads/core/providers/flavor_provider.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load the font to prevent the "Bad state" crash on cold start
  // try {
  //   final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  //   final loader = FontLoader('Roboto');
  //   loader.addFont(Future.value(fontData));
  //   await loader.load();
  //   debugPrint("Font 'Roboto' loaded successfully");
  // } catch (e) {
  //   debugPrint("Font loading failed: $e");
  // }
  runApp(
    ProviderScope(
      overrides: [
        flavorProvider.overrideWithValue(
          FlavorConfig(
            flavor: 'dev',
            apiBaseUrl:
                'http://weaddswebapi-env.eba-4minhvmy.us-west-1.elasticbeanstalk.com/',
          ),
        ),
      ],
      child: const WeAdsApp(),
    ),
  );
}

class WeAdsApp extends ConsumerWidget {
  const WeAdsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final config = ref.watch(flavorProvider);

    // Watch the status instead of listening to it for navigation
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          // debugShowCheckedModeBanner: config.flavor == 'dev',
          builder: (context, child) {
            return connectivityAsync.when(
              data: (status) {
                if (status == ConnectivityStatus.isDisconnected) {
                  return const NoInternetScreen();
                }
                return child!; // Show the actual app/router content
              },
              // Handle loading/initial state during Hot Restart
              loading: () =>
                  child ??
                  const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
              // Default to child if stream fails
              error: (_, __) => child!,
            );
          },
        );
      },
    );
  }
}
