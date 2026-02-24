import 'package:we_ads/features/posts/data/modals/post_model.dart';

/// Represents one entry in the savedpost API response list.
/// Each entry = one user + one saved post.
class SavedPostResponse {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobileNo;
  final String? description;
  final String? pincode;
  final String? city;
  final String? profilePhotoUrl; // extracted from profilePhoto.fileUrl
  final PostModel? post;         // singular "post" field

  SavedPostResponse({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNo,
    this.description,
    this.pincode,
    this.city,
    this.profilePhotoUrl,
    this.post,
  });

  factory SavedPostResponse.fromJson(Map<String, dynamic> json) {
    return SavedPostResponse(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      description: json['description'],
      pincode: json['pincode'],
      city: json['city'],
      profilePhotoUrl: json['profilePhoto'] != null
          ? (json['profilePhoto'] as Map<String, dynamic>)['fileUrl'] as String?
          : null,
      post: json['post'] != null
          ? PostModel.fromJson(json['post'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MediaModel {
  final String? mediaId;
  final String? fileName;
  final String? fileUrl;
  final String? contentType;

  MediaModel({this.mediaId, this.fileName, this.fileUrl, this.contentType});

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      mediaId: json['mediaId'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      contentType: json['contentType'],
    );
  }

  bool get isImage => contentType?.startsWith('image') ?? false;
  bool get isVideo => contentType?.startsWith('video') ?? false;
  bool get isAudio => contentType?.startsWith('audio') ?? false;
}
