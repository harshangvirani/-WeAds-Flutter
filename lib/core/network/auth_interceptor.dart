import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:we_ads/core/network/local_storage_service.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await LocalStorageService.getToken();

    debugPrint("Interceptor Token: $token");

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = '$token'
          .replaceAll('[', '')
          .replaceAll(']', '');
      print(
        "Added Authorization Header: ${token.replaceAll('[', '').replaceAll(']', '')}",
      );
    }

    return handler.next(options);
  }
}
