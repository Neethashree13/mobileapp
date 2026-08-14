import 'package:dio/dio.dart';

/// Standardized API Exception for FlashCart AI Mobile
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Network timeout. Please check your internet connection and try again.',
        statusCode: 408,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Unable to connect to server. Please check your internet or offline mode.',
        statusCode: 503,
      );
    }

    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      String errorMessage = 'An unexpected server error occurred ($statusCode)';

      if (data is Map<String, dynamic>) {
        if (data['error'] != null && data['error'].toString().isNotEmpty) {
          errorMessage = data['error'].toString();
        } else if (data['message'] != null && data['message'].toString().isNotEmpty) {
          errorMessage = data['message'].toString();
        } else if (data['details'] != null && data['details'].toString().isNotEmpty) {
          errorMessage = data['details'].toString();
        }
      } else if (data is String && data.isNotEmpty) {
        errorMessage = data;
      }

      return ApiException(
        message: errorMessage,
        statusCode: statusCode,
        details: data,
      );
    }

    return ApiException(
      message: error.message ?? 'A network communication error occurred',
    );
  }

  @override
  String toString() => message;
}
