import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../models/cart_response_model.dart';
import '../../models/cart_summary_model.dart';

abstract class ICartRemoteDataSource {
  Future<CartSummaryModel> getCart({String? couponCode});
  Future<CartSummaryModel> addItem({required String productId, int quantity = 1, String addedBy = 'Self'});
  Future<CartSummaryModel> updateItem({required String productId, required int quantity});
  Future<CartSummaryModel> removeItem({required String productId});
  Future<CartSummaryModel> saveForLater({required String productId, bool isSavedForLater = true});
  Future<CartSummaryModel> syncCart(List<Map<String, dynamic>> items);
  Future<CartSummaryModel> getSummary({String? couponCode});
}

class CartRemoteDataSource implements ICartRemoteDataSource {
  final Dio _dio;

  CartRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient().http;

  @override
  Future<CartSummaryModel> getCart({String? couponCode}) async {
    try {
      dev.log('GET /api/cart params: $couponCode', name: 'CartRemoteDataSource');
      final response = await _dio.get(
        '/api/cart',
        queryParameters: couponCode != null && couponCode.isNotEmpty ? {'couponCode': couponCode} : null,
      );
      final parsed = CartResponseModel.fromJson(response.data as Map<String, dynamic>);
      return parsed.summary ?? CartSummaryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError('getCart', e);
    }
  }

  @override
  Future<CartSummaryModel> addItem({
    required String productId,
    int quantity = 1,
    String addedBy = 'Self',
  }) async {
    try {
      dev.log('POST /api/cart/items product: $productId, qty: $quantity', name: 'CartRemoteDataSource');
      final response = await _dio.post(
        '/api/cart/items',
        data: {'productId': productId, 'quantity': quantity, 'addedBy': addedBy},
      );
      final parsed = CartResponseModel.fromJson(response.data as Map<String, dynamic>);
      return parsed.summary ?? await getCart();
    } on DioException catch (e) {
      throw _handleDioError('addItem', e);
    }
  }

  @override
  Future<CartSummaryModel> updateItem({
    required String productId,
    required int quantity,
  }) async {
    try {
      dev.log('PUT /api/cart/items/$productId qty: $quantity', name: 'CartRemoteDataSource');
      final response = await _dio.put(
        '/api/cart/items/$productId',
        data: {'quantity': quantity},
      );
      final parsed = CartResponseModel.fromJson(response.data as Map<String, dynamic>);
      return parsed.summary ?? await getCart();
    } on DioException catch (e) {
      throw _handleDioError('updateItem', e);
    }
  }

  @override
  Future<CartSummaryModel> removeItem({required String productId}) async {
    try {
      dev.log('DELETE /api/cart/items/$productId', name: 'CartRemoteDataSource');
      final response = await _dio.delete('/api/cart/items/$productId');
      final parsed = CartResponseModel.fromJson(response.data as Map<String, dynamic>);
      return parsed.summary ?? await getCart();
    } on DioException catch (e) {
      throw _handleDioError('removeItem', e);
    }
  }

  @override
  Future<CartSummaryModel> saveForLater({
    required String productId,
    bool isSavedForLater = true,
  }) async {
    try {
      dev.log('POST /api/cart/save-for-later product: $productId', name: 'CartRemoteDataSource');
      final response = await _dio.post(
        '/api/cart/save-for-later',
        data: {'productId': productId, 'isSavedForLater': isSavedForLater},
      );
      final parsed = CartResponseModel.fromJson(response.data as Map<String, dynamic>);
      return parsed.summary ?? await getCart();
    } on DioException catch (e) {
      throw _handleDioError('saveForLater', e);
    }
  }

  @override
  Future<CartSummaryModel> syncCart(List<Map<String, dynamic>> items) async {
    try {
      dev.log('POST /api/cart/sync count: ${items.length}', name: 'CartRemoteDataSource');
      await _dio.post('/api/cart/sync', data: {'cart': items});
      return await getCart();
    } on DioException catch (e) {
      throw _handleDioError('syncCart', e);
    }
  }

  @override
  Future<CartSummaryModel> getSummary({String? couponCode}) async {
    return getCart(couponCode: couponCode);
  }

  Exception _handleDioError(String action, DioException error) {
    dev.log('Cart Error [$action]: ${error.type} - ${error.message}', name: 'CartRemoteDataSource', error: error);

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Exception('Connection timeout while communicating with cart service.');
    }
    if (error.type == DioExceptionType.connectionError) {
      return Exception('Network unavailable. Failed to reach cart server.');
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return Exception('Unauthorized: Please log in to update your cart.');
    }
    if (statusCode == 500) {
      return Exception('Internal Server Error: Unable to process cart request.');
    }

    if (error.response?.data != null && error.response?.data is Map) {
      final msg = error.response?.data['error'] ?? error.response?.data['message'];
      if (msg != null) return Exception(msg.toString());
    }

    return Exception(error.message ?? 'Cart request failed with status $statusCode');
  }
}
