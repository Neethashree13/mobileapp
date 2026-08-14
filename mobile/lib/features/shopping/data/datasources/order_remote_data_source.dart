import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../models/shopping_models.dart';

abstract class IOrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({String? status, String? search});
  Future<OrderModel> getOrderById(String id);
  Future<OrderModel> placeOrder(OrderModel order);
  Future<bool> cancelOrder(String id, {String? reason});
  Future<bool> reorder(String id);
  Future<List<TimelineStep>> getOrderTracking(String id);
}

class OrderRemoteDataSource implements IOrderRemoteDataSource {
  final Dio _dio;

  OrderRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient().http;

  @override
  Future<List<OrderModel>> getOrders({String? status, String? search}) async {
    try {
      dev.log('GET /api/orders status=$status, search=$search', name: 'OrderRemoteDataSource');
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/orders',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final List<dynamic> data = response.data is List ? response.data : (response.data['orders'] ?? []);
      return data.map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError('getOrders', e);
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      dev.log('GET /api/orders/$id', name: 'OrderRemoteDataSource');
      final response = await _dio.get('/api/orders/$id');
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? (response.data['order'] is Map<String, dynamic> ? response.data['order'] : response.data)
          : {};
      return OrderModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError('getOrderById', e);
    }
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    try {
      dev.log('POST /api/orders', name: 'OrderRemoteDataSource');
      final response = await _dio.post('/api/orders', data: order.toJson());
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? (response.data['order'] is Map<String, dynamic> ? response.data['order'] : response.data)
          : {};
      return OrderModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError('placeOrder', e);
    }
  }

  @override
  Future<bool> cancelOrder(String id, {String? reason}) async {
    try {
      dev.log('PUT /api/orders/$id/cancel', name: 'OrderRemoteDataSource');
      final response = await _dio.put(
        '/api/orders/$id/cancel',
        data: {'reason': reason ?? 'Customer requested cancellation'},
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw _handleDioError('cancelOrder', e);
    }
  }

  @override
  Future<bool> reorder(String id) async {
    try {
      dev.log('PUT /api/orders/$id/reorder', name: 'OrderRemoteDataSource');
      final response = await _dio.put('/api/orders/$id/reorder', data: {});
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw _handleDioError('reorder', e);
    }
  }

  @override
  Future<List<TimelineStep>> getOrderTracking(String id) async {
    try {
      dev.log('GET /api/orders/$id/tracking', name: 'OrderRemoteDataSource');
      final response = await _dio.get('/api/orders/$id/tracking');
      final List<dynamic> data = response.data is List ? response.data : (response.data['timeline'] ?? []);
      return data.map((e) {
        final Map<String, dynamic> map = e as Map<String, dynamic>;
        final status = map['status'] as String? ?? '';
        final title = map['title'] as String? ?? status;
        final timestamp = map['timestamp'] as String? ?? '';
        final completed = map['completed'] as bool? ?? false;
        final notes = map['notes'] as String? ?? '';
        return TimelineStep(
          title: title,
          subtitle: notes.isNotEmpty ? notes : title,
          time: timestamp != 'Pending' ? timestamp : null,
          isCompleted: completed,
          isActive: completed && timestamp != 'Pending',
          icon: completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        );
      }).toList();
    } on DioException catch (e) {
      throw _handleDioError('getOrderTracking', e);
    }
  }

  Exception _handleDioError(String method, DioException e) {
    dev.log('Error in $method: ${e.message}', name: 'OrderRemoteDataSource', error: e);
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      final msg = e.response?.data['error'] ?? e.response?.data['message'];
      if (msg != null) return Exception(msg.toString());
    }
    return Exception(e.message ?? 'Network error occurred in $method');
  }
}
