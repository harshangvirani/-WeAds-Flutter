import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:we_ads/core/network/api_error_handler.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:we_ads/features/home/data/modal/feed_model.dart';

/// Provider for the unified search query (mapped from CustomTextField)
final searchQueryProvider = StateProvider<String>((ref) => "");

/// FutureProvider that fetches search results:
/// 1. Fetches ALL users from API (with category filter)
/// 2. Filters locally by firstName/lastName match
/// 3. If no name matches, filters locally by city match
/// 4. If nothing matches, returns empty list -> "No user found"
final searchResultProvider = FutureProvider<List<FeedUser>>((ref) async {
  final dio = ref.read(dioProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final selectedCats = ref.watch(selectedCategoriesProvider);

  // Don't search on empty query
  if (query.isEmpty) {
    // Show all users when no query is entered
    try {
      final response = await dio.post(
        ApiEndpoints.userFeed,
        data: {
          "categories": selectedCats,
          "userId": null,
          "city": null,
        },
      );
      if (response.statusCode == 200) {
        return FeedResponse.fromJson(response.data).data ?? [];
      }
      return [];
    } on DioException catch (e) {
      throw ApiErrorHandler.getErrorMessage(e.response);
    }
  }

  // Debounce the search to avoid too many API calls while typing
  await Future.delayed(const Duration(milliseconds: 400));

  try {
    // Fetch ALL users from the API (the API does NOT support firstName/lastName filters)
    final response = await dio.post(
      ApiEndpoints.userFeed,
      data: {
        "categories": selectedCats,
        "userId": null,
        "city": null,
      },
    );

    if (response.statusCode != 200) return [];

    final allUsers = FeedResponse.fromJson(response.data).data ?? [];

    if (kDebugMode) {
      debugPrint("Fetched ${allUsers.length} total users. Filtering by query: '$query'");
    }

    // --- STAGE 1: Filter by firstName or lastName (client-side) ---
    final nameMatches = allUsers.where((user) {
      final first = (user.firstName ?? '').toLowerCase();
      final last = (user.lastName ?? '').toLowerCase();
      final fullName = '$first $last';

      return first.contains(query) ||
             last.contains(query) ||
             fullName.contains(query);
    }).toList();

    if (kDebugMode) {
      debugPrint("Name matches: ${nameMatches.length}");
    }

    if (nameMatches.isNotEmpty) {
      return nameMatches;
    }

    // --- STAGE 2: Filter by city (client-side) ---
    final cityMatches = allUsers.where((user) {
      final city = (user.city ?? '').toLowerCase();
      return city.contains(query);
    }).toList();

    if (kDebugMode) {
      debugPrint("City matches: ${cityMatches.length}");
    }

    return cityMatches; // May be empty -> shows "No user found"
  } on DioException catch (e) {
    throw ApiErrorHandler.getErrorMessage(e.response);
  }
});
