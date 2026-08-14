import '../datasources/cart_remote_data_source.dart';
import '../../models/cart_summary_model.dart';

abstract class ICartRepository {
  Future<CartSummaryModel> getCart({String? couponCode});
  Future<CartSummaryModel> addItem({required String productId, int quantity = 1, String addedBy = 'Self'});
  Future<CartSummaryModel> updateItem({required String productId, required int quantity});
  Future<CartSummaryModel> removeItem({required String productId});
  Future<CartSummaryModel> saveForLater({required String productId, bool isSavedForLater = true});
  Future<CartSummaryModel> syncCart(List<Map<String, dynamic>> items);
  Future<CartSummaryModel> getSummary({String? couponCode});
}

class CartRepository implements ICartRepository {
  final ICartRemoteDataSource _remoteDataSource;

  CartRepository({ICartRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CartRemoteDataSource();

  @override
  Future<CartSummaryModel> getCart({String? couponCode}) {
    return _remoteDataSource.getCart(couponCode: couponCode);
  }

  @override
  Future<CartSummaryModel> addItem({
    required String productId,
    int quantity = 1,
    String addedBy = 'Self',
  }) {
    return _remoteDataSource.addItem(
      productId: productId,
      quantity: quantity,
      addedBy: addedBy,
    );
  }

  @override
  Future<CartSummaryModel> updateItem({
    required String productId,
    required int quantity,
  }) {
    return _remoteDataSource.updateItem(
      productId: productId,
      quantity: quantity,
    );
  }

  @override
  Future<CartSummaryModel> removeItem({required String productId}) {
    return _remoteDataSource.removeItem(productId: productId);
  }

  @override
  Future<CartSummaryModel> saveForLater({
    required String productId,
    bool isSavedForLater = true,
  }) {
    return _remoteDataSource.saveForLater(
      productId: productId,
      isSavedForLater: isSavedForLater,
    );
  }

  @override
  Future<CartSummaryModel> syncCart(List<Map<String, dynamic>> items) {
    return _remoteDataSource.syncCart(items);
  }

  @override
  Future<CartSummaryModel> getSummary({String? couponCode}) {
    return _remoteDataSource.getSummary(couponCode: couponCode);
  }
}
