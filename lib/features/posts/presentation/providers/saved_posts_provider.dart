import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/features/posts/data/modals/post_model.dart';
import 'package:we_ads/features/posts/data/modals/saved_post_response_madel.dart';

final savedPostsProvider =
    AsyncNotifierProvider<SavedPostsNotifier, List<PostModel>>(
      SavedPostsNotifier.new,
    );
// features/posts/presentation/providers/saved_posts_provider.dart

class SavedPostsNotifier extends AsyncNotifier<List<PostModel>> {
  @override
  Future<List<PostModel>> build() async {
    return _fetchSavedPosts();
  }

  Future<List<PostModel>> _fetchSavedPosts() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.savedPosts);

      if (response.statusCode == 200 && response.data['data'] != null) {
        // Correct path: response.data['data']['posts']
        final savedData = SavedPostResponse.fromJson(response.data['data']);
        return savedData.posts ?? [];
      }
      return [];
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      return [];
    } catch (e) {
      debugPrint("Unexpected Error: $e");
      rethrow;
    }
  }
}
