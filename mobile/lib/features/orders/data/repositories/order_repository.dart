import 'dart:developer' as dev;
import '../datasources/order_remote_data_source.dart';
import '../../models/order_model.dart';

abstract class IOrderRepository {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderById(String id);
  Future<OrderModel> createOrder(CreateOrderRequest request);
  Future<void> cancelOrder(String id);
  Future<void> updateOrderStatus(String id, String status);
}

class OrderRepository implements IOrderRepository {
  final IOrderRemoteDataSource _remoteDataSource;

  OrderRepository({IOrderRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? OrderRemoteDataSource();

  @override
  Future<List<OrderModel>> getOrders() {
    dev.log('Delegating getOrders() to remote data source', name: 'OrderRepository');
    return _remoteDataSource.getOrders();
  }

  @override
  Future<OrderModel> getOrderById(String id) {
    dev.log('Delegating getOrderById($id) to remote data source', name: 'OrderRepository');
    return _remoteDataSource.getOrderById(id);
  }

  @override
  Future<OrderModel> createOrder(CreateOrderRequest request) {
    dev.log('Delegating createOrder() to remote data source', name: 'OrderRepository');
    return _remoteDataSource.createOrder(request);
  }

  @override
  Future<void> cancelOrder(String id) {
    dev.log('Delegating cancelOrder($id) to remote data source', name: 'OrderRepository');
    return _remoteDataSource.cancelOrder(id);
  }

  @override
  Future<void> updateOrderStatus(String id, String status) {
    dev.log('Delegating updateOrderStatus($id, $status) to remote data source', name: 'OrderRepository');
    return _remoteDataSource.updateOrderStatus(id, status);
  }
}
