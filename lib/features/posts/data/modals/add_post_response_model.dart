class AddPostResponse {
  final String? data; // This holds the postId
  final int? code;
  final String? statusValue;
  final String? statusMessage;

  AddPostResponse({this.data, this.code, this.statusValue, this.statusMessage});

  factory AddPostResponse.fromJson(Map<String, dynamic> json) {
    return AddPostResponse(
      data: json['data'],
      code: json['code'],
      statusValue: json['statusValue'],
      statusMessage: json['statusMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'code': code,
      'statusValue': statusValue,
      'statusMessage': statusMessage,
    };
  }

  AddPostResponse copyWith({
    String? data,
    int? code,
    String? statusValue,
    String? statusMessage,
  }) {
    return AddPostResponse(
      data: data ?? this.data,
      code: code ?? this.code,
      statusValue: statusValue ?? this.statusValue,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
