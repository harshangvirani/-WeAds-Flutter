import 'package:we_ads/features/auth/data/modals/user_model.dart';

class OtpVerifyResponse {
  final int? code;
  final String? statusValue;
  final String? statusMessage;
  final UserData? data;

  OtpVerifyResponse({
    this.code,
    this.statusValue,
    this.statusMessage,
    this.data,
  });

  OtpVerifyResponse copyWith({
    int? code,
    String? statusValue,
    String? statusMessage,
    UserData? data,
  }) {
    return OtpVerifyResponse(
      code: code ?? this.code,
      statusValue: statusValue ?? this.statusValue,
      statusMessage: statusMessage ?? this.statusMessage,
      data: data ?? this.data,
    );
  }

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      code: json['code'],
      statusValue: json['statusValue'],
      statusMessage: json['statusMessage'],
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'statusValue': statusValue,
      'statusMessage': statusMessage,
      'data': data?.toJson(),
    };
  }
}
