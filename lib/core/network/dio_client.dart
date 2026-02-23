import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_ads/core/network/auth_interceptor.dart';
import 'package:we_ads/core/network/local_storage_service.dart';
import 'package:we_ads/core/providers/flavor_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ref.watch(flavorProvider).apiBaseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor());

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
