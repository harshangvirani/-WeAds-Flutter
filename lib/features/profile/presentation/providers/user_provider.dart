import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:we_ads/core/network/dio_client.dart';
import 'package:we_ads/core/network/api_error_handler.dart';
import 'package:we_ads/core/providers/api_endpoints.dart';

class UpdateProfileState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  UpdateProfileState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
}

class UpdateProfileNotifier extends StateNotifier<UpdateProfileState> {
  final Dio _dio;
  UpdateProfileNotifier(this._dio) : super(UpdateProfileState());

  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String description,
    required String email,
    required String mobileNo,
    required String pincode,
    required String city,
    String? imagePath,
    String? deleteProfilePhotoOld,
  }) async {
    // Reset state and set loading
    state = UpdateProfileState(isLoading: true);

    try {
      final Map<String, dynamic> data = {
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "description": description,
        "email": email,
        "mobileNo": mobileNo,
        "pincode": pincode,
        "city": city,
      };

      if (imagePath != null && imagePath.isNotEmpty) {
        // Ensure the file exists before trying to upload
        File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          data["addedprofilePhoto"] = await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          );
        }
      }

      if (deleteProfilePhotoOld != null && deleteProfilePhotoOld.isNotEmpty) {
        data["deleteProfilePhotoOld"] = deleteProfilePhotoOld;
      }

      final formData = FormData.fromMap(data);

      // Note: Ensure ApiEndpoints.updateProfile is used if you have it defined
      final response = await _dio.post(
        ApiEndpoints.userProfile,
        data: formData,
      );

      if (response.statusCode == 200) {
        state = UpdateProfileState(isSuccess: true);
      } else {
        state = UpdateProfileState(
          error: "Server returned ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      state = UpdateProfileState(
        error: ApiErrorHandler.getErrorMessage(e.response),
      );
    } catch (e) {
      state = UpdateProfileState(error: e.toString());
    }
  }

  // Helper to reset state when leaving the screen
  void resetState() {
    state = UpdateProfileState();
  }
}

final updateProfileProvider =
    StateNotifierProvider<UpdateProfileNotifier, UpdateProfileState>((ref) {
      return UpdateProfileNotifier(ref.read(dioProvider));
    });
