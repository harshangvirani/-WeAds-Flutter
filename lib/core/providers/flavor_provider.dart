import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlavorConfig {
  final String flavor;
  final String apiBaseUrl;

  FlavorConfig({required this.flavor, required this.apiBaseUrl});
}

// This provider should be overridden in the main.dart file based on the build flavor
final flavorProvider = Provider<FlavorConfig>((ref) {
  throw UnimplementedError();
});
