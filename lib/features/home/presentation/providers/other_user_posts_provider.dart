import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:we_ads/core/models/api_response_model.dart';
import 'package:we_ads/core/network/api_error_handler.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/network/local_storage_service.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/home/data/modal/feed_model.dart';
import 'package:we_ads/features/home/presentation/providers/user_feed_provider.dart';
import 'package:we_ads/features/posts/data/modals/other_user_posts_response_model.dart';

final otherUserPostsProvider = FutureProvider<OtherUserPostsResponse>((
  ref,
) async {
  final dio = ref.read(dioProvider);

  // final user = await LocalStorageService.getUser();
  final selectedCats = ref.watch(selectedCategoriesProvider);
  final selectedFeedUser = ref.watch(selectedFeedUserProvider);
  try {
    final response = await dio.post(
      ApiEndpoints.otherUserPosts,
      data: {
        "categories": selectedCats, // Pass selected category names here
        "userId": selectedFeedUser.userId,
        "currentUserId": null,
      },
    );

    if (response.statusCode == 200) {
      final feedResponse = OtherUserPostsResponse.fromJson(response.data);

      return feedResponse;
    }
    throw ('Failed to load posts');
  } on DioException catch (e) {
    throw ApiErrorHandler.getErrorMessage(e.response);
  }
});

final viewPostProvider = FutureProvider<ApiResponse>((ref) async {
  final selectedFeedUser = ref.watch(selectedFeedUserProvider);
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.post(
      ApiEndpoints.viewPost,
      data: {"userId": selectedFeedUser.userId ?? ""},
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(response.data);

      return apiResponse;
    }
    throw ('Failed to load posts');
  } on DioException catch (e) {
    throw ApiErrorHandler.getErrorMessage(e.response);
  }
});
