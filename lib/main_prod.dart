import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_ads/core/providers/flavor_provider.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        flavorProvider.overrideWithValue(
          FlavorConfig(flavor: 'prod', apiBaseUrl: ''),
        ),
      ],
      child: const WeAdsApp(),
    ),
  );
}
