import 'package:we_ads/features/posts/data/modals/post_model.dart';

class SavedPostResponse {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final List<PostModel>? posts;

  SavedPostResponse({this.userId, this.firstName, this.lastName, this.posts});

  factory SavedPostResponse.fromJson(Map<String, dynamic> json) {
    return SavedPostResponse(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      posts: json['posts'] != null
          ? List<PostModel>.from(
              json['posts'].map((x) => PostModel.fromJson(x)),
            )
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

  // Helper getters to identify media types
  bool get isImage => contentType?.startsWith('image') ?? false;
  bool get isVideo => contentType?.startsWith('video') ?? false;
  bool get isAudio => contentType?.startsWith('audio') ?? false;
}
