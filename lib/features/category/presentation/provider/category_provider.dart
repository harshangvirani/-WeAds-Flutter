import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/features/category/data/modal/category_response_model.dart';

// Provider to fetch categories from the API
final categoriesProvider = FutureProvider<List<CategoryData>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(ApiEndpoints.categories);

    if (response.statusCode == 200) {
      // Use the model to parse the Map response
      final categoryResponse = CategoryResponse.fromJson(response.data);
      return categoryResponse.data ?? [];
    } else {
      throw Exception("Failed to load categories");
    }
  } catch (e) {
    debugPrint("Category Fetch Error: $e");
    rethrow;
  }
});
// Provider to hold selected categories
final selectedCategoriesProvider = StateProvider<List<String>>((ref) => []);

// Provider for the search text
final categorySearchProvider = StateProvider<String>((ref) => "");

// Provider that returns filtered data based on search text
final filteredCategoriesProvider = Provider<AsyncValue<List<CategoryData>>>((
  ref,
) {
  final categoriesAsync = ref.watch(categoriesProvider);
  final searchQuery = ref.watch(categorySearchProvider).toLowerCase();

  return categoriesAsync.whenData((list) {
    if (searchQuery.isEmpty) return list;
    return list
        .where(
          (cat) => (cat.categoryName ?? "").toLowerCase().contains(searchQuery),
        )
        .toList();
  });
});
