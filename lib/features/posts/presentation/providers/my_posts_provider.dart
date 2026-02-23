import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/features/posts/data/modals/post_model.dart';
import 'package:we_ads/features/posts/data/modals/profile_posts_response_model.dart';

final myPostsProvider = FutureProvider<ProfilePostsResponse>((ref) async {
  final dio = ref.read(dioProvider);

  try {
    final response = await dio.get(ApiEndpoints.myPosts);

    if (response.statusCode == 200) {
      final profileResponse = ProfilePostsResponse.fromJson(response.data);
      return profileResponse;
    }
    return ProfilePostsResponse(
      statusValue: "Error",
      statusMessage: "Failed to fetch posts",
    );
  } catch (e) {
    debugPrint("Error fetching my posts: $e");
    return ProfilePostsResponse(
      statusValue: "Error",
      statusMessage: "Failed to fetch posts",
    );
  }
});
