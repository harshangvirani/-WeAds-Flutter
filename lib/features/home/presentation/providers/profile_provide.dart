import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_ads/core/network/api_error_handler.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/network/local_storage_service.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/core/providers/user_provider.dart';
import 'package:we_ads/features/auth/data/modals/login_response_model.dart';

final userProfileDataProvider = FutureProvider<OtpVerifyResponse>((ref) async {
  final dio = ref.read(dioProvider);

  try {
    final response = await dio.get(ApiEndpoints.userProfile);

    final userData = OtpVerifyResponse.fromJson(response.data);

    if (userData.code == 200 && userData.data != null) {
      await LocalStorageService.saveUser(userData.data!);

      ref.read(userProvider.notifier).state = userData.data;
      return userData;
    }
    return OtpVerifyResponse();
  } on DioException catch (e) {
    throw ApiErrorHandler.getErrorMessage(e.response);
  }
});
