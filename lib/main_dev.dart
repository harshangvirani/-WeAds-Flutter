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
