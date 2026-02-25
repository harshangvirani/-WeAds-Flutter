import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/posts/data/modals/post_model.dart';
import 'package:we_ads/features/posts/data/modals/profile_posts_response_model.dart';

final myPostsProvider = FutureProvider<ProfilePostsResponse>((ref) async {
  final dio = ref.read(dioProvider);
  final selectedCats = ref.watch(selectedCategoriesProvider);

  try {
    final response = await dio.get(ApiEndpoints.myPosts);

    if (response.statusCode == 200) {
      final profileResponse = ProfilePostsResponse.fromJson(response.data);

      if (selectedCats.isEmpty) {
        return profileResponse;
      }

      // Client-side filtering
      final filteredPosts = profileResponse.data?.posts?.where((post) {
        if (post.categories == null) return false;
        // The categories field in PostModel is a comma-separated string or a single string
        final postCats = post.categories!.split(',').map((e) => e.trim());
        return selectedCats.any((selected) => postCats.contains(selected));
      }).toList();

      return profileResponse.copyWith(
        data: ProfilePostsData(
          userId: profileResponse.data?.userId,
          firstName: profileResponse.data?.firstName,
          lastName: profileResponse.data?.lastName,
          email: profileResponse.data?.email,
          mobileNo: profileResponse.data?.mobileNo,
          description: profileResponse.data?.description,
          pincode: profileResponse.data?.pincode,
          city: profileResponse.data?.city,
          profilePhoto: profileResponse.data?.profilePhoto,
          posts: filteredPosts,
        ),
      );
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
