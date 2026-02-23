// features/auth/data/modals/update_profile_request.dart
class UpdateProfileRequest {
  final String userId;
  final String firstName;
  final String lastName;
  final String description;
  final String email;
  final String mobileNo;
  final String pincode;
  final String city;
  final String? addedProfilePhotoPath; // Local path for the new image
  final String? deleteProfilePhotoId; // ID of the old photo to delete

  UpdateProfileRequest({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.description,
    required this.email,
    required this.mobileNo,
    required this.pincode,
    required this.city,
    this.addedProfilePhotoPath,
    this.deleteProfilePhotoId,
  });
}
