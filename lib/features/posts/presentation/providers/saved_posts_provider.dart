import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/core/providers/user_provider.dart';
import 'package:we_ads/features/category/presentation/provider/category_provider.dart';
import 'package:we_ads/features/posts/data/modals/saved_post_response_madel.dart';

final savedPostsProvider =
    AsyncNotifierProvider<SavedPostsNotifier, List<SavedPostResponse>>(
      SavedPostsNotifier.new,
    );

class SavedPostsNotifier extends AsyncNotifier<List<SavedPostResponse>> {
  @override
  Future<List<SavedPostResponse>> build() async {
    return _fetchSavedPosts();
  }

  Future<List<SavedPostResponse>> _fetchSavedPosts() async {
    try {
      final dio = ref.read(dioProvider);
      final user = ref.read(userProvider);
      final selectedCats = ref.watch(selectedCategoriesProvider);

      final requestData = {
        "userId": user?.userId,
        "categories": selectedCats,
      };

      if (kDebugMode) {
        debugPrint("Fetching saved posts: $requestData");
      }

      final response = await dio.post(
        ApiEndpoints.savedPost,
        data: requestData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic root = response.data;

        // Response shape: { "data": [...], "code": 200, ... }
        // Each item in "data" has user info + singular "post" field.
        final dynamic dataList =
            (root is Map<String, dynamic>) ? root['data'] : root;

        if (dataList is List) {
          return dataList.whereType<Map<String, dynamic>>().map((item) {
            final response = SavedPostResponse.fromJson(item);
            // Manually set isSaved to true for UI consistency in Saved screen
            if (response.post != null) {
              return SavedPostResponse(
                userId: response.userId,
                firstName: response.firstName,
                lastName: response.lastName,
                email: response.email,
                mobileNo: response.mobileNo,
                description: response.description,
                pincode: response.pincode,
                city: response.city,
                profilePhotoUrl: response.profilePhotoUrl,
                post: response.post!.copyWith(isSaved: true),
              );
            }
            return response;
          }).where((r) => r.post != null).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint("Saved Posts Dio Error: ${e.message}");
      debugPrint("Response: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("Saved Posts Error: $e");
      rethrow;
    }
  }
}
