import '../datasources/order_remote_data_source.dart';
import '../../models/shopping_models.dart';

abstract class IOrderRepository {
  Future<List<OrderModel>> getOrders({String? status, String? search});
  Future<OrderModel> getOrderById(String id);
  Future<OrderModel> placeOrder(OrderModel order);
  Future<bool> cancelOrder(String id, {String? reason});
  Future<bool> reorder(String id);
  Future<List<TimelineStep>> getOrderTracking(String id);
}

class OrderRepository implements IOrderRepository {
  final IOrderRemoteDataSource _remoteDataSource;

  OrderRepository({IOrderRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? OrderRemoteDataSource();

  @override
  Future<List<OrderModel>> getOrders({String? status, String? search}) {
    return _remoteDataSource.getOrders(status: status, search: search);
  }

  @override
  Future<OrderModel> getOrderById(String id) {
    return _remoteDataSource.getOrderById(id);
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) {
    return _remoteDataSource.placeOrder(order);
  }

  @override
  Future<bool> cancelOrder(String id, {String? reason}) {
    return _remoteDataSource.cancelOrder(id, reason: reason);
  }

  @override
  Future<bool> reorder(String id) {
    return _remoteDataSource.reorder(id);
  }

  @override
  Future<List<TimelineStep>> getOrderTracking(String id) {
    return _remoteDataSource.getOrderTracking(id);
  }
}
