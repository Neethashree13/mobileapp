import '../datasources/product_remote_data_source.dart';
import '../../models/home_models.dart';

abstract class IProductRepository {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    String? sortBy,
    bool? isFeatured,
    bool? isTrending,
    bool? isBestSeller,
    bool? isFlashDeal,
  });
  Future<ProductModel> getProductById(String id);
}

class ProductRepository implements IProductRepository {
  final IProductRemoteDataSource _remoteDataSource;

  ProductRepository({IProductRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProductRemoteDataSource();

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    String? sortBy,
    bool? isFeatured,
    bool? isTrending,
    bool? isBestSeller,
    bool? isFlashDeal,
  }) {
    return _remoteDataSource.getProducts(
      category: category,
      query: query,
      sortBy: sortBy,
      isFeatured: isFeatured,
      isTrending: isTrending,
      isBestSeller: isBestSeller,
      isFlashDeal: isFlashDeal,
    );
  }

  @override
  Future<ProductModel> getProductById(String id) {
    return _remoteDataSource.getProductById(id);
  }
}
