import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:we_ads/core/models/api_response_model.dart';
import 'package:we_ads/core/network/api_error_handler.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/network/local_storage_service.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';
import 'package:we_ads/core/providers/user_provider.dart';
import 'package:we_ads/core/utils/app_toast.dart';
import 'package:we_ads/features/auth/data/modals/login_response_model.dart';
import 'package:we_ads/features/auth/data/modals/profile_request.dart';
import 'package:we_ads/features/auth/presentation/screens/login_screen.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, void>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> sendOtp(
    BuildContext context,
    String phoneNumber,
    String otpFor, // e.g., "login", "register",updatemobileno
    String? userId,
  ) async {
    state = const AsyncLoading();
    final body = {'mobileNo': phoneNumber, 'type': otpFor, 'userId': userId};
    print("Sending OTP with body: $body");
    final result = await AsyncValue.guard(() async {
      final response = await ref
          .read(dioProvider)
          .post(
            ApiEndpoints.register,
            data: {'mobileNo': phoneNumber, 'type': otpFor, 'userId': userId},
          );

      final apiResponse = ApiResponse.fromJson(response.data);

      // Business Logic check (Success is 200 or 201)
      if ((apiResponse.code == 200 || apiResponse.code == 201) &&
          apiResponse.statusValue == "SUCCESS") {
        ref.read(otpVisibilityProvider.notifier).state = true;
        if (context.mounted) {
          AppToast.show(
            context: context,
            message: apiResponse.statusMessage ?? "Success",
            type: ToastType.success,
          );
        }
      } else {
        throw Exception(apiResponse.statusMessage ?? "Failed to send OTP");
      }
    });

    if (result.hasError && context.mounted) {
      state = AsyncError(result.error!, result.stackTrace!);
      AppToast.show(
        context: context,
        message: ApiErrorHandler.getErrorMessage(result.error),
        type: ToastType.error,
      );
    } else {
      state = const AsyncData(null);
    }
  }

  Future<bool> verifyOtp(
    BuildContext context,
    String phoneNumber,
    String otp,
    String otpFor, // e.g., "login", "register", "update mobile no."
    String countryIso,
    String dialCode,
  ) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final dio = ref.read(dioProvider);
      print("Verifying OTP for $phoneNumber with OTP: $otp");
      final response = await dio.post(
        ApiEndpoints.verifyOtp,
        data: {'mobileNo': phoneNumber, 'otp': otp, "type": otpFor},
      );

      if (otpFor == "register") {
        final apiResponse = ApiResponse.fromJson(response.data);

        if ((apiResponse.code == 200 || apiResponse.code == 201) &&
            apiResponse.statusValue == "SUCCESS") {
          if (context.mounted) {
            AppToast.show(
              context: context,
              message:
                  apiResponse.statusMessage ?? "Account verified successfully!",
              type: ToastType.success,
            );
            state = const AsyncData(null);
          }
          return true;
        } else {
          throw Exception(apiResponse.statusMessage ?? "Verification failed");
        }
      } else {
        final loginResponse = OtpVerifyResponse.fromJson(response.data);

        if (loginResponse.code == 200 &&
            loginResponse.data != null &&
            response.headers['Authorization'] != null) {
          await LocalStorageService.saveUser(loginResponse.data!);
          print("*******$countryIso");
          print("*******$dialCode");
          await LocalStorageService.saveCountryData(countryIso, dialCode);
          Object token = response.headers['Authorization'] ?? "";

          await LocalStorageService.saveToken(token.toString());

          ref.read(userProvider.notifier).state = loginResponse.data;

          if (context.mounted) context.go('/home');
        } else {
          throw Exception(loginResponse.statusMessage ?? "Login failed");
        }
      }
    });

    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);

      if (context.mounted) {
        AppToast.show(
          context: context,
          message: ApiErrorHandler.getErrorMessage(result.error),
          type: ToastType.error,
        );
      }
      return false;
    }

    state = const AsyncData(null);
    return true;
  }

  Future<void> createProfile(
    BuildContext context,
    ProfileRequest request,
  ) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final dio = ref.read(dioProvider);
      late FormData formData;
      // Create multipart form data
      if (request.filePath != null) {
        formData = FormData.fromMap({
          'firstName': request.firstName,
          'lastName': request.lastName,
          'description': request.description,
          'email': request.email,
          'mobileNo': request.mobileNo,
          'pincode': request.pincode,
          // 'city': request.city,
          'city':
              'Vadodara', // dummy / static fro now because do not have any field on screen
          'profilePhoto': await MultipartFile.fromFile(
            request.filePath ?? "",
            filename: request.filePath?.split('/').last,
          ),
        });
        print("With image");
      } else {
        formData = FormData.fromMap({
          'firstName': request.firstName,
          'lastName': request.lastName,
          'description': request.description,
          'email': request.email,
          'mobileNo': request.mobileNo,
          'pincode': request.pincode,
          // 'city': request.city,
          'city':
              'Vadodara', // dummy / static fro now because do not have any field on screen
        });
        print("no image");
      }

      for (var element in formData.fields) {
        debugPrint("KEY: ${element.key} | VALUE: ${element.value}");
      }

      final response = await dio.post(
        ApiEndpoints.createProfile,
        data: formData,
      );
      final apiResponse = ApiResponse.fromJson(response.data);

      if (apiResponse.code == 200 || apiResponse.code == 201) {
        if (context.mounted) {
          AppToast.show(
            context: context,
            message: "Profile created!",
            type: ToastType.success,
          );
          state = const AsyncData(null);
          context.go('/success');
        }
      } else {
        throw Exception(
          apiResponse.statusMessage ?? "Failed to create profile",
        );
      }
    });

    if (result.hasError && context.mounted) {
      state = AsyncError(result.error!, result.stackTrace!);
      AppToast.show(
        context: context,
        message: ApiErrorHandler.getErrorMessage(result.error),
        type: ToastType.error,
      );
    }

    state = const AsyncData(null);
  }

  // Future<void> login(BuildContext context, String phoneNumber) async {
  //   state = const AsyncLoading();

  //   final result = await AsyncValue.guard(() async {
  //     final response = await ref
  //         .read(dioProvider)
  //         .post(ApiEndpoints.login, data: {'mobileNo': phoneNumber});

  //     final loginResponse = LoginResponse.fromJson(response.data);

  //     if (loginResponse.code == 200 &&
  //         loginResponse.data != null &&
  //         response.headers['Authorization'] != null) {
  //       await LocalStorageService.saveUser(loginResponse.data!);

  //       Object token = response.headers['Authorization'] ?? "";

  //       await LocalStorageService.saveToken(token.toString());

  //       ref.read(userProvider.notifier).state = loginResponse.data;

  //       if (context.mounted) context.go('/home');
  //     } else {
  //       throw Exception(loginResponse.statusMessage ?? "Login failed");
  //     }
  //   });
  //   if (result.hasError && context.mounted) {
  //     state = AsyncError(result.error!, result.stackTrace!);
  //     AppToast.show(
  //       context: context,
  //       message: ApiErrorHandler.getErrorMessage(result.error),
  //       type: ToastType.error,
  //     );
  //   }
  // }

  Future<void> logout(BuildContext context) async {
    state = const AsyncLoading();

    try {
      final result = await AsyncValue.guard(() async {
        final dio = ref.read(dioProvider);

        final response = await dio.post(ApiEndpoints.logout);

        final apiResponse = ApiResponse.fromJson(response.data);

        if (apiResponse.code == 200 && apiResponse.statusValue == "SUCCESS") {
          await _performLocalLogout(context);
        } else {
          throw Exception(
            apiResponse.statusMessage ?? "Logout failed on server",
          );
        }
      });

      if (result.hasError) {
        debugPrint("Logout API Error: ${result.error}");
        await _performLocalLogout(context);

        state = const AsyncData(null);
      }
    } catch (e) {
      state = const AsyncData(null);
      print("error in api ${e}");
    }
  }

  Future<void> _performLocalLogout(BuildContext context) async {
    await LocalStorageService.clearAll();
    ref.read(userProvider.notifier).state = null;

    if (context.mounted) {
      context.go('/login');
      AppToast.show(
        context: context,
        message: "Logged out successfully",
        type: ToastType.success,
      );
    }
  }
}
