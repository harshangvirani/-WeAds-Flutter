class UserData {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobileNo;
  final String? pincode;
  final String? city;
  final String? description;
  final int? enteredBy;
  final DateTime? enteredOn;
  final int? modifiedBy;
  final DateTime? modifiedOn;
  final Media? profilePhoto;

  UserData({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNo,
    this.pincode,
    this.city,
    this.description,
    this.enteredBy,
    this.enteredOn,
    this.modifiedBy,
    this.modifiedOn,
    this.profilePhoto,
  });

  UserData copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNo,
    String? pincode,
    String? city,
    String? description,
    int? enteredBy,
    DateTime? enteredOn,
    int? modifiedBy,
    DateTime? modifiedOn,
    Media? profilePhoto,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobileNo: mobileNo ?? this.mobileNo,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      description: description ?? this.description,
      enteredBy: enteredBy ?? this.enteredBy,
      enteredOn: enteredOn ?? this.enteredOn,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      pincode: json['pincode'],
      city: json['city'],
      description: json['description'],
      enteredBy: json['enteredBy'],
      enteredOn: json['enteredOn'] != null
          ? DateTime.parse(json['enteredOn'])
          : null,
      modifiedBy: json['modifiedBy'],
      modifiedOn: json['modifiedOn'] != null
          ? DateTime.parse(json['modifiedOn'])
          : null,
      profilePhoto: json['profilePhoto'] != null
          ? Media.fromJson(json['profilePhoto'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileNo': mobileNo,
      'pincode': pincode,
      'city': city,
      'description': description,
      'enteredBy': enteredBy,
      'enteredOn': enteredOn?.toIso8601String(),
      'modifiedBy': modifiedBy,
      'modifiedOn': modifiedOn?.toIso8601String(),
      'profilePhoto': profilePhoto?.toJson(),
    };
  }
}

enum MediaType { image, video, audio, unknown }

class Media {
  final String? mediaId;
  final String? fileName;
  final String? fileUrl;
  final String? contentType;

  Media({this.mediaId, this.fileName, this.fileUrl, this.contentType});

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
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

  MediaType get mediaType {
    if (contentType == null) return MediaType.unknown;
    if (contentType!.startsWith('image')) return MediaType.image;
    if (contentType!.startsWith('video')) return MediaType.video;
    if (contentType!.startsWith('audio')) return MediaType.audio;
    return MediaType.unknown;
  }

  bool get isImage => mediaType == MediaType.image;
}
