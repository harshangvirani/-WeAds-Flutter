import 'package:we_ads/features/posts/data/modals/post_model.dart';

class OtherUserPostsResponse {
  final OtherUserPostsData? data;
  final int? code;
  final String? statusValue;
  final String? statusMessage;

  OtherUserPostsResponse({
    this.data,
    this.code,
    this.statusValue,
    this.statusMessage,
  });

  OtherUserPostsResponse copyWith({
    OtherUserPostsData? data,
    int? code,
    String? statusValue,
    String? statusMessage,
  }) {
    return OtherUserPostsResponse(
      data: data ?? this.data,
      code: code ?? this.code,
      statusValue: statusValue ?? this.statusValue,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  factory OtherUserPostsResponse.fromJson(Map<String, dynamic> json) {
    return OtherUserPostsResponse(
      data: json['data'] != null
          ? OtherUserPostsData.fromJson(json['data'])
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

class OtherUserPostsData {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobileNo;
  final String? description;
  final String? pincode;
  final String? city;
  final String? profilePhoto;
  final List<PostModel>? posts;

  OtherUserPostsData({
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

  OtherUserPostsData copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNo,
    String? description,
    String? pincode,
    String? city,
    String? profilePhoto,
    List<PostModel>? posts,
  }) {
    return OtherUserPostsData(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobileNo: mobileNo ?? this.mobileNo,
      description: description ?? this.description,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      posts: posts ?? this.posts,
    );
  }

  factory OtherUserPostsData.fromJson(Map<String, dynamic> json) {
    return OtherUserPostsData(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      description: json['description'],
      pincode: json['pincode'],
      city: json['city'],
      profilePhoto: json['profilePhoto'] != null
          ? json['profilePhoto']['fileUrl'] as String?
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
    'profilePhoto': profilePhoto,
    'posts': posts?.map((e) => e.toJson()).toList(),
  };
}
