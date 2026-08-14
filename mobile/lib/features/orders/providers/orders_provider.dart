import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../data/datasources/order_remote_data_source.dart';
import '../data/repositories/order_repository.dart';

// 1. Remote Data Source Provider
final orderRemoteDataSourceProvider = Provider<IOrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource();
});

// 2. Repository Provider
final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  final remote = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepository(remoteDataSource: remote);
});

// 3. Main Orders List FutureProvider
final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  return await repository.getOrders();
});

// 4. Selected Order StateProvider
final selectedOrderProvider = StateProvider<OrderModel?>((ref) => null);

// 5. Order Details FutureProvider Family
final orderDetailsProvider = FutureProvider.family<OrderModel, String>((ref, id) async {
  final repository = ref.watch(orderRepositoryProvider);
  return await repository.getOrderById(id);
});

// 6. Orders Controller / Action Notifier for state mutations (Create, Cancel, Update status)
class OrdersController extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final IOrderRepository _repository;

  OrdersController(this._repository) : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _repository.getOrders();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createOrder(CreateOrderRequest request) async {
    try {
      final newOrder = await _repository.createOrder(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([newOrder, ...currentList]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelOrder(String id) async {
    try {
      await _repository.cancelOrder(id);
      if (state.value != null) {
        final updatedList = state.value!.map((o) {
          if (o.id == id) {
            return o.copyWith(
              status: OrderStatusEnum.Cancelled,
              updatedAt: DateTime.now(),
            );
          }
          return o;
        }).toList();
        state = AsyncValue.data(updatedList);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateOrderStatus(String id, String newStatus) async {
    try {
      await _repository.updateOrderStatus(id, newStatus);
      await fetchOrders();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final ordersControllerProvider = StateNotifierProvider<OrdersController, AsyncValue<List<OrderModel>>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return OrdersController(repo);
});
