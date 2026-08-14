import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../models/order_model.dart';

abstract class IOrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderById(String id);
  Future<OrderModel> createOrder(CreateOrderRequest request);
  Future<void> cancelOrder(String id);
  Future<void> updateOrderStatus(String id, String status);
}

class OrderRemoteDataSource implements IOrderRemoteDataSource {
  final Dio _dio;

  OrderRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient().http;

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      dev.log('GET /api/v1/orders', name: 'OrderRemoteDataSource');
      Response response;
      try {
        response = await _dio.get('/api/v1/orders');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          // Fallback to legacy endpoint if /api/v1/orders is not found
          dev.log('Fallback to GET /api/orders', name: 'OrderRemoteDataSource');
          response = await _dio.get('/api/orders');
        } else {
          rethrow;
        }
      }

      final dynamic responseData = response.data;
      List<dynamic> list;
      if (responseData is List) {
        list = responseData;
      } else if (responseData is Map<String, dynamic> && responseData.containsKey('orders')) {
        list = responseData['orders'] as List<dynamic>;
      } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        list = responseData['data'] as List<dynamic>;
      } else {
        list = [];
      }

      dev.log('Fetched ${list.length} orders successfully', name: 'OrderRemoteDataSource');
      return list.map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError('getOrders', e);
    } catch (e, stackTrace) {
      dev.log('Unexpected error in getOrders', name: 'OrderRemoteDataSource', error: e, stackTrace: stackTrace);
      throw Exception('Unexpected error loading orders: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      dev.log('GET /api/v1/orders/$id', name: 'OrderRemoteDataSource');
      Response response;
      try {
        response = await _dio.get('/api/v1/orders/$id');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          dev.log('Fallback to GET /api/orders/$id', name: 'OrderRemoteDataSource');
          response = await _dio.get('/api/orders/$id');
        } else {
          rethrow;
        }
      }

      final dynamic responseData = response.data;
      Map<String, dynamic> data;
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('order') && responseData['order'] is Map<String, dynamic>) {
          data = responseData['order'] as Map<String, dynamic>;
        } else if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          data = responseData['data'] as Map<String, dynamic>;
        } else {
          data = responseData;
        }
      } else {
        throw Exception('Invalid order response structure');
      }

      dev.log('Fetched order details for ID: $id', name: 'OrderRemoteDataSource');
      return OrderModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError('getOrderById', e);
    } catch (e, stackTrace) {
      dev.log('Unexpected error in getOrderById', name: 'OrderRemoteDataSource', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch order details: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    try {
      dev.log('POST /api/v1/orders payload: ${request.toJson()}', name: 'OrderRemoteDataSource');
      Response response;
      try {
        response = await _dio.post('/api/v1/orders', data: request.toJson());
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          dev.log('Fallback to POST /api/orders', name: 'OrderRemoteDataSource');
          response = await _dio.post('/api/orders', data: request.toJson());
        } else {
          rethrow;
        }
      }

      final dynamic responseData = response.data;
      Map<String, dynamic> data;
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('order') && responseData['order'] is Map<String, dynamic>) {
          data = responseData['order'] as Map<String, dynamic>;
        } else {
          data = responseData;
        }
      } else {
        throw Exception('Invalid create order response');
      }

      dev.log('Successfully created order: ${data['id']}', name: 'OrderRemoteDataSource');
      return OrderModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError('createOrder', e);
    } catch (e, stackTrace) {
      dev.log('Unexpected error in createOrder', name: 'OrderRemoteDataSource', error: e, stackTrace: stackTrace);
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelOrder(String id) async {
    try {
      dev.log('DELETE /api/v1/orders/$id', name: 'OrderRemoteDataSource');
      try {
        await _dio.delete('/api/v1/orders/$id');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
          dev.log('Fallback to PUT /api/orders/$id/cancel', name: 'OrderRemoteDataSource');
          await _dio.put('/api/orders/$id/cancel', data: {'reason': 'User requested cancellation'});
        } else {
          rethrow;
        }
      }
      dev.log('Order $id cancelled successfully', name: 'OrderRemoteDataSource');
    } on DioException catch (e) {
      throw _handleDioError('cancelOrder', e);
    } catch (e, stackTrace) {
      dev.log('Unexpected error in cancelOrder', name: 'OrderRemoteDataSource', error: e, stackTrace: stackTrace);
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    try {
      dev.log('PUT /api/v1/orders/$id/status status=$status', name: 'OrderRemoteDataSource');
      try {
        await _dio.put('/api/v1/orders/$id/status', data: {'status': status});
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          dev.log('Fallback to PATCH /api/orders/$id/status', name: 'OrderRemoteDataSource');
          await _dio.patch('/api/orders/$id/status', data: {'status': status});
        } else {
          rethrow;
        }
      }
      dev.log('Order $id status updated to $status', name: 'OrderRemoteDataSource');
    } on DioException catch (e) {
      throw _handleDioError('updateOrderStatus', e);
    } catch (e, stackTrace) {
      dev.log('Unexpected error in updateOrderStatus', name: 'OrderRemoteDataSource', error: e, stackTrace: stackTrace);
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  Exception _handleDioError(String method, DioException e) {
    dev.log('DioException in $method [${e.type}]: ${e.message}', name: 'OrderRemoteDataSource', error: e);
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your network and try again.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return Exception('Network connection error. Please ensure you are connected to the internet.');
    }
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final dynamic body = e.response?.data;
      String errorMsg = '';
      if (body is Map<String, dynamic>) {
        errorMsg = body['error'] ?? body['message'] ?? body['detail'] ?? '';
      }

      switch (statusCode) {
        case 401:
          return Exception('Session expired (401). Please log in again.');
        case 404:
          return Exception(errorMsg.isNotEmpty ? errorMsg : 'Order not found (404).');
        case 500:
          return Exception(errorMsg.isNotEmpty ? errorMsg : 'Server error (500). Please try again later.');
        default:
          return Exception(errorMsg.isNotEmpty ? errorMsg : 'HTTP Error $statusCode in $method.');
      }
    }
    return Exception(e.message ?? 'Network error occurred in $method.');
  }
}
