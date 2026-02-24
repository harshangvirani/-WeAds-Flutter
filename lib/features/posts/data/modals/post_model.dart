import 'package:we_ads/features/posts/data/modals/post_media_model.dart';

class PostModel {
  final String? postId;
  final String? userId;
  final String? description;
  final String? categories;
  final DateTime? enteredOn;
  final List<PostMedia>? media;
  final bool? isSaved;
  final int? savedCount;
  final int? viewCount;

  PostModel({
    this.postId,
    this.userId,
    this.description,
    this.categories,
    this.enteredOn,
    this.media,
    this.isSaved,
    this.savedCount,
    this.viewCount,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'],
      userId: json['userId'],
      description: json['description'],
      categories: json['categories'],
      enteredOn: json['enteredOn'] != null
          ? DateTime.parse(json['enteredOn'])
          : null,
      media: json['media'] != null
          ? List<PostMedia>.from(
              json['media'].map((x) => PostMedia.fromJson(x)),
            )
          : null,
      isSaved: json['isSaved'],
      savedCount: json['savedCount'],
      viewCount: json['viewCount'],
    );
  }

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'userId': userId,
    'description': description,
    'categories': categories,
    'enteredOn': enteredOn?.toIso8601String(),
    'media': media?.map((e) => e.toJson()).toList(),
    'isSaved': isSaved,
    'savedCount': savedCount,
    'viewCount': viewCount,
  };

  PostModel copyWith({
    String? postId,
    String? userId,
    String? description,
    String? categories,
    DateTime? enteredOn,
    List<PostMedia>? media,
    bool? isSaved,
    int? savedCount,
    int? viewCount,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      enteredOn: enteredOn ?? this.enteredOn,
      media: media ?? this.media,
      isSaved: isSaved ?? this.isSaved,
      savedCount: savedCount ?? this.savedCount,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
