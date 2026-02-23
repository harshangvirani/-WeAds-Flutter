class FeedResponse {
  final List<FeedUser>? data;
  final int? code;
  final String? statusValue;
  final String? statusMessage;

  FeedResponse({this.data, this.code, this.statusValue, this.statusMessage});

  FeedResponse copyWith({
    List<FeedUser>? data,
    int? code,
    String? statusValue,
    String? statusMessage,
  }) {
    return FeedResponse(
      data: data ?? this.data,
      code: code ?? this.code,
      statusValue: statusValue ?? this.statusValue,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      data: json['data'] != null
          ? List<FeedUser>.from(json['data'].map((x) => FeedUser.fromJson(x)))
          : null,
      code: json['code'],
      statusValue: json['statusValue'],
      statusMessage: json['statusMessage'],
    );
  }

  get firstName => null;

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
      'code': code,
      'statusValue': statusValue,
      'statusMessage': statusMessage,
    };
  }
}
class FeedUser {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? description;
  final String? email;
  final String? mobileNo;
  final String? pincode;
  final String? city;
  final int? unReadPostCount;

  FeedUser({
    this.userId,
    this.firstName,
    this.lastName,
    this.description,
    this.email,
    this.mobileNo,
    this.pincode,
    this.city,
    this.unReadPostCount,
  });

  FeedUser copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? description,
    String? email,
    String? mobileNo,
    String? pincode,
    String? city,
    int? unReadPostCount,
  }) {
    return FeedUser(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      description: description ?? this.description,
      email: email ?? this.email,
      mobileNo: mobileNo ?? this.mobileNo,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      unReadPostCount: unReadPostCount ?? this.unReadPostCount,
    );
  }

  factory FeedUser.fromJson(Map<String, dynamic> json) {
    return FeedUser(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      description: json['description'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      pincode: json['pincode'],
      city: json['city'],
      unReadPostCount: json['unReadPostCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'description': description,
      'email': email,
      'mobileNo': mobileNo,
      'pincode': pincode,
      'city': city,
      'unReadPostCount': unReadPostCount,
    };
  }
}
