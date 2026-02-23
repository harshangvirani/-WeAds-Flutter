import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          if (statusCode == 400) {
            return _parseValidationError(responseData);
          } else if (statusCode == 401) {
            return "Session expired. Please login again.";
          } else if (statusCode == 404) {
            return "Requested resource not found (404).";
          } else if (statusCode == 500) {
            return "Server error. Please try again later.";
          } else if (statusCode == 413) {
            return "The image file is too large. Please pick a smaller photo.";
          }
          return "Server error: $statusCode";

        case DioExceptionType.connectionTimeout:
          return "Connection timed out. Check your internet.";
        case DioExceptionType.receiveTimeout:
          return "Server is taking too long to respond.";
        case DioExceptionType.sendTimeout:
          return "Request send timeout. Please try again.";
        case DioExceptionType.cancel:
          return "Request was cancelled.";
        case DioExceptionType.connectionError:
          return "No internet connection. Please check your network.";
        case DioExceptionType.badCertificate:
          return "Secure connection failed (Bad Certificate).";
        default:
          return "Something went wrong. Please try again.";
      }
    }
    // Handle manual exceptions thrown via 'throw Exception()'
    return error.toString().replaceAll('Exception: ', '');
  }

  static String _parseValidationError(dynamic data) {
    try {
      if (data is Map && data.containsKey('errors')) {
        final errors = data['errors'] as Map;
        // Extracts the first error message from the first key found
        final firstErrorList = errors.values.first;
        if (firstErrorList is List && firstErrorList.isNotEmpty) {
          return firstErrorList.first.toString();
        }
      }
      if (data is Map && data.containsKey('statusMessage')) {
        return data['statusMessage']?.toString() ?? "Validation failed";
      }
    } catch (e) {
      return "Invalid request format.";
    }
    return "Invalid request. Please check your input.";
  }
}
