import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:we_ads/core/network/api_error_handler.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/network/local_storage_service.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/home/data/modal/feed_model.dart';

final userFeedProvider = FutureProvider<List<FeedUser>>((ref) async {
  final dio = ref.read(dioProvider);

  // final user = await LocalStorageService.getUser();
  final selectedCats = ref.watch(selectedCategoriesProvider);
  try {
    final response = await dio.post(
      ApiEndpoints.userFeed,
      data: {
        "categories": selectedCats, // Pass selected category names here
        "userId": null, // Or the current userId if required
        "city": null, // Optional city filter
      },
    );

    if (response.statusCode == 200) {
      final feedResponse = FeedResponse.fromJson(response.data);
      return feedResponse.data ?? [];
    }
    return [];
  } on DioException catch (e) {
    throw ApiErrorHandler.getErrorMessage(e.response);
  }
});

// Provider to hold selected categories
final selectedFeedUserProvider = StateProvider<FeedUser>((ref) => FeedUser());
