import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';

/// Production Dio Interceptor for Automatic JWT Attachment & Refresh Token Rotation
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService storage;
  final Function()? onUnauthenticated;

  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _failedQueue = [];

  AuthInterceptor({
    required this.dio,
    required this.storage,
    this.onUnauthenticated,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Attach JWT Access Token if available
    final accessToken = await storage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;

    // Handle 401 Unauthorized for automatic token refresh
    if (response?.statusCode == 401 && !err.requestOptions.path.contains('/api/auth/refresh') && !err.requestOptions.path.contains('/api/auth/login')) {
      if (_isRefreshing) {
        // Queue pending requests while refresh is in flight
        _failedQueue.add((options: err.requestOptions, handler: handler));
        return;
      }

      _isRefreshing = true;

      try {
        final refreshToken = await storage.readRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          throw DioException(
            requestOptions: err.requestOptions,
            error: 'No refresh token available',
          );
        }

        // Call backend refresh endpoint
        final refreshDio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
        final refreshResponse = await refreshDio.post(
          '/api/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
          final newAccessToken = refreshResponse.data['accessToken'] as String?;
          final newRefreshToken = refreshResponse.data['refreshToken'] as String?;

          if (newAccessToken != null && newRefreshToken != null) {
            await storage.writeAccessToken(newAccessToken);
            await storage.writeRefreshToken(newRefreshToken);

            // Retry original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retriedResponse = await dio.fetch(err.requestOptions);

            // Resolve queued requests
            for (final request in _failedQueue) {
              request.options.headers['Authorization'] = 'Bearer $newAccessToken';
              try {
                final response = await dio.fetch(request.options);
                request.handler.resolve(response);
              } catch (queueErr) {
                if (queueErr is DioException) {
                  request.handler.reject(queueErr);
                }
              }
            }
            _failedQueue.clear();

            return handler.resolve(retriedResponse);
          }
        }
      } catch (refreshError) {
        debugPrint('⚠️ Token refresh failed: $refreshError');
        // Clear tokens and redirect to login
        await storage.clearAll();
        for (final request in _failedQueue) {
          request.handler.reject(err);
        }
        _failedQueue.clear();
        if (onUnauthenticated != null) {
          onUnauthenticated!();
        }
      } finally {
        _isRefreshing = false;
      }
    }

    return handler.next(err);
  }
}
