import 'package:we_ads/features/posts/data/modals/post_model.dart';

class ProfilePostsResponse {
  final ProfilePostsData? data;
  final int? code;
  final String? statusValue;
  final String? statusMessage;

  ProfilePostsResponse({
    this.data,
    this.code,
    this.statusValue,
    this.statusMessage,
  });

  ProfilePostsResponse copyWith({
    ProfilePostsData? data,
    int? code,
    String? statusValue,
    String? statusMessage,
  }) {
    return ProfilePostsResponse(
      data: data ?? this.data,
      code: code ?? this.code,
      statusValue: statusValue ?? this.statusValue,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  factory ProfilePostsResponse.fromJson(Map<String, dynamic> json) {
    return ProfilePostsResponse(
      data: json['data'] != null
          ? ProfilePostsData.fromJson(json['data'])
          : null,
      code: json['code'],
      statusValue: json['statusValue'],
      statusMessage: json['statusMessage'],
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data?.toJson(),
    'code': code,
    'statusValue': statusValue,
    'statusMessage': statusMessage,
  };
}

class ProfilePostsData {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobileNo;
  final String? description;
  final String? pincode;
  final String? city;
  final ProfilePhoto? profilePhoto;
  final List<PostModel>? posts;

  ProfilePostsData({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNo,
    this.description,
    this.pincode,
    this.city,
    this.profilePhoto,
    this.posts,
  });

  factory ProfilePostsData.fromJson(Map<String, dynamic> json) {
    return ProfilePostsData(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      description: json['description'],
      pincode: json['pincode'],
      city: json['city'],
      profilePhoto: json['profilePhoto'] != null
          ? ProfilePhoto.fromJson(json['profilePhoto'])
          : null,
      posts: json['posts'] != null
          ? List<PostModel>.from(
              json['posts'].map((x) => PostModel.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'mobileNo': mobileNo,
    'description': description,
    'pincode': pincode,
    'city': city,
    'profilePhoto': profilePhoto?.toJson(),
    'posts': posts?.map((e) => e.toJson()).toList(),
  };
}

class ProfilePhoto {
  final String? mediaId;
  final String? fileName;
  final String? fileUrl;
  final String? contentType;

  ProfilePhoto({this.mediaId, this.fileName, this.fileUrl, this.contentType});

  factory ProfilePhoto.fromJson(Map<String, dynamic> json) {
    return ProfilePhoto(
      mediaId: json['mediaId'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      contentType: json['contentType'],
    );
  }

  Map<String, dynamic> toJson() => {
    'mediaId': mediaId,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'contentType': contentType,
  };
}
