import '../datasources/wishlist_remote_data_source.dart';
import '../../models/wishlist_response_model.dart';

abstract class IWishlistRepository {
  Future<WishlistResponseModel> getWishlist();
  Future<WishlistResponseModel> addItem(String productId);
  Future<WishlistResponseModel> removeItem(String productId);
  Future<WishlistResponseModel> toggleWishlist(String productId);
}

class WishlistRepository implements IWishlistRepository {
  final IWishlistRemoteDataSource _remoteDataSource;

  WishlistRepository({IWishlistRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? WishlistRemoteDataSource();

  @override
  Future<WishlistResponseModel> getWishlist() {
    return _remoteDataSource.getWishlist();
  }

  @override
  Future<WishlistResponseModel> addItem(String productId) {
    return _remoteDataSource.addItem(productId);
  }

  @override
  Future<WishlistResponseModel> removeItem(String productId) {
    return _remoteDataSource.removeItem(productId);
  }

  @override
  Future<WishlistResponseModel> toggleWishlist(String productId) {
    return _remoteDataSource.toggleWishlist(productId);
  }
}
