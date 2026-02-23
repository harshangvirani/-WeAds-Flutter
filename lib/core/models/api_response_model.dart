class ApiResponse {
  final int? code;
  final String? statusValue;
  final String? statusMessage;

  ApiResponse({this.code, this.statusValue, this.statusMessage});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] as int?,
      statusValue: json['statusValue'] as String?,
      statusMessage: json['statusMessage'] as String?,
    );
  }
}
