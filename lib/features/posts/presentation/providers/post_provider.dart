import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/features/home/presentation/providers/other_user_posts_provider.dart';
import 'package:we_ads/features/home/presentation/providers/user_feed_provider.dart';
import 'package:we_ads/features/posts/data/modals/add_post_response_model.dart';
import 'package:we_ads/features/posts/presentation/providers/my_posts_provider.dart';
import 'package:we_ads/features/posts/presentation/providers/saved_posts_provider.dart';

final postProvider = AsyncNotifierProvider<PostNotifier, void>(
  PostNotifier.new,
);

class PostNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<AddPostResponse?> addPost({
    required String description,
    required String categories,
    required List<File> mediaFiles,
  }) async {
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioProvider);

      List<MultipartFile> multipartFiles = [];
      for (var file in mediaFiles) {
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }

      final formData = FormData.fromMap({
        'description': description,
        'categories': categories,
        'media': multipartFiles,
      });

      final response = await dio.post(ApiEndpoints.addPost, data: formData);

      // Parse using our new model
      final addPostResponse = AddPostResponse.fromJson(response.data);

      if (addPostResponse.code == 200 &&
          addPostResponse.statusValue == "SUCCESS") {
        ref.invalidate(userFeedProvider);
        ref.invalidate(otherUserPostsProvider);
        ref.invalidate(myPostsProvider);
        state = const AsyncData(null);
        return addPostResponse;
      } else {
        throw Exception(addPostResponse.statusMessage ?? "Failed to add post");
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }
  Future<AddPostResponse?> updatePost({
    required String postId,
    required String description,
    required String categories,
    required List<File> newMediaFiles,
    required List<String> existingMediaUrls,
  }) async {
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioProvider);

      List<MultipartFile> multipartFiles = [];
      for (var file in newMediaFiles) {
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }

      final Map<String, dynamic> dataMap = {
        'postId': postId,
        'description': description,
        'categories': categories,
        'media': multipartFiles,
      };

      // Since update logic can vary, we send existing media back if the API expects it.
      // Often, APIs will either replace all media or diff based on sent URLs.
      if (existingMediaUrls.isNotEmpty) {
        dataMap['existingMedia'] = existingMediaUrls;
      }

      final formData = FormData.fromMap(dataMap);

      // Using addPost endpoint with POST as per common pattern in this app, passing postId to indicate an update.
      final response = await dio.post(ApiEndpoints.addPost, data: formData);

      final addPostResponse = AddPostResponse.fromJson(response.data);

      if (addPostResponse.code == 200 &&
          addPostResponse.statusValue == "SUCCESS") {
        ref.invalidate(userFeedProvider);
        ref.invalidate(otherUserPostsProvider);
        ref.invalidate(myPostsProvider);
        state = const AsyncData(null);
        return addPostResponse;
      } else {
        throw Exception(addPostResponse.statusMessage ?? "Failed to update post");
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }


  Future<bool> toggleSavePost({
    required String postId,
    required String userId,
    required bool isSaved,
  }) async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.post(
        ApiEndpoints.savePost,
        data: {
          "postId": postId,
          "userId": userId,
          "isSaved": isSaved,
        },
      );

      if (response.statusCode == 200) {
        // Invalidate providers to refresh the feed/saved list
        ref.invalidate(userFeedProvider);
        ref.invalidate(otherUserPostsProvider);
        ref.invalidate(savedPostsProvider);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Save Post Error: $e");
      return false;
    }
  }

  Future<bool> deletePost({required String postId}) async {
    final dio = ref.read(dioProvider);
    try {
      // Assuming a standard RESTful delete endpoint like api/posts/{postId}
      // If the API expects the postId in the body or query params, this can be adjusted.
      final response = await dio.delete("${ApiEndpoints.addPost}/$postId");

      if (response.statusCode == 200) {
        ref.invalidate(userFeedProvider);
        ref.invalidate(otherUserPostsProvider);
        ref.invalidate(myPostsProvider);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Delete Post Error: $e");
      return false;
    }
  }
}
