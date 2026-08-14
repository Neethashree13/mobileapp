import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../models/wishlist_response_model.dart';

abstract class IWishlistRemoteDataSource {
  Future<WishlistResponseModel> getWishlist();
  Future<WishlistResponseModel> addItem(String productId);
  Future<WishlistResponseModel> removeItem(String productId);
  Future<WishlistResponseModel> toggleWishlist(String productId);
}

class WishlistRemoteDataSource implements IWishlistRemoteDataSource {
  final Dio _dio;

  WishlistRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient().http;

  @override
  Future<WishlistResponseModel> getWishlist() async {
    try {
      dev.log('GET /api/wishlist', name: 'WishlistRemoteDataSource');
      final response = await _dio.get('/api/wishlist');
      return WishlistResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError('getWishlist', e);
    }
  }

  @override
  Future<WishlistResponseModel> addItem(String productId) async {
    try {
      dev.log('POST /api/wishlist/items productId: $productId', name: 'WishlistRemoteDataSource');
      final response = await _dio.post(
        '/api/wishlist/items',
        data: {'productId': productId},
      );
      return WishlistResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError('addItem', e);
    }
  }

  @override
  Future<WishlistResponseModel> removeItem(String productId) async {
    try {
      dev.log('DELETE /api/wishlist/items/$productId', name: 'WishlistRemoteDataSource');
      final response = await _dio.delete('/api/wishlist/items/$productId');
      return WishlistResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError('removeItem', e);
    }
  }

  @override
  Future<WishlistResponseModel> toggleWishlist(String productId) async {
    try {
      dev.log('POST /api/wishlist/toggle productId: $productId', name: 'WishlistRemoteDataSource');
      final response = await _dio.post(
        '/api/wishlist/toggle',
        data: {'productId': productId},
      );
      return WishlistResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError('toggleWishlist', e);
    }
  }

  Exception _handleDioError(String action, DioException error) {
    dev.log('Wishlist Error [$action]: ${error.type} - ${error.message}', name: 'WishlistRemoteDataSource', error: error);

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Exception('Connection timeout while communicating with wishlist service.');
    }
    if (error.type == DioExceptionType.connectionError) {
      return Exception('Network unavailable. Failed to reach wishlist server.');
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return Exception('Unauthorized: Please log in to manage your wishlist.');
    }
    if (statusCode == 500) {
      return Exception('Internal Server Error: Unable to process wishlist request.');
    }

    if (error.response?.data != null && error.response?.data is Map) {
      final msg = error.response?.data['error'] ?? error.response?.data['message'];
      if (msg != null) return Exception(msg.toString());
    }

    return Exception(error.message ?? 'Wishlist request failed with status $statusCode');
  }
}
