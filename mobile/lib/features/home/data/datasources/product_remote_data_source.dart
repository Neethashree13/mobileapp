import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../models/home_models.dart';

abstract class IProductRemoteDataSource {
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

class ProductRemoteDataSource implements IProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient().http;

@override
Future<List<ProductModel>> getProducts({
  String? category,
  String? query,
  String? sortBy,
  bool? isFeatured,
  bool? isTrending,
  bool? isBestSeller,
  bool? isFlashDeal,
}) async {
  try {
    dev.log(
      'GET /api/v1/products',
      name: 'ProductRemoteDataSource',
    );

    Response response;

    try {
      response = await _dio.get(
        '/api/v1/products',
        queryParameters: {
          if (category != null && category.isNotEmpty)
            'category': category,
          if (query != null && query.isNotEmpty)
            'q': query,
          if (sortBy != null && sortBy.isNotEmpty)
            'sortBy': sortBy,
          if (isFeatured == true)
            'isFeatured': 'true',
          if (isTrending == true)
            'isTrending': 'true',
          if (isBestSeller == true)
            'isBestSeller': 'true',
          if (isFlashDeal == true)
            'isFlashDeal': 'true',
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.get(
          '/products',
          queryParameters: {
            if (category != null && category.isNotEmpty)
              'category': category,
            if (query != null && query.isNotEmpty)
              'q': query,
            if (sortBy != null && sortBy.isNotEmpty)
              'sortBy': sortBy,
            if (isFeatured == true)
              'isFeatured': 'true',
            if (isTrending == true)
              'isTrending': 'true',
            if (isBestSeller == true)
              'isBestSeller': 'true',
            if (isFlashDeal == true)
              'isFlashDeal': 'true',
          },
        );
      } else {
        rethrow;
      }
    }

    dev.log(
      "STATUS CODE : ${response.statusCode}",
      name: "ProductRemoteDataSource",
    );

    dev.log(
      "RAW RESPONSE : ${response.data}",
      name: "ProductRemoteDataSource",
    );

    final dynamic data = response.data;

    List<dynamic> list = [];

    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      if (data['products'] is List) {
        list = data['products'] as List;
      } else if (data['data'] is List) {
        list = data['data'] as List;
      }
    }

    dev.log(
      "LIST LENGTH : ${list.length}",
      name: "ProductRemoteDataSource",
    );

  final products = list.map((item) {

  final product = ProductModel.fromJson(
    item as Map<String, dynamic>,
  );

  dev.log(
    "PRODUCT => ${product.name} | ${product.categoryId} | ${product.imageUrl}",
    name: "PRODUCT_DEBUG",
  );

  return product;

}).toList();

    dev.log(
      "PARSED PRODUCTS : ${products.length}",
      name: "ProductRemoteDataSource",
    );

    if (products.isNotEmpty) {
      dev.log(
        "FIRST PRODUCT : ${products.first.name}",
        name: "ProductRemoteDataSource",
      );

      dev.log(
        "CATEGORY : ${products.first.categoryId}",
        name: "ProductRemoteDataSource",
      );

      dev.log(
        "IMAGE : ${products.first.imageUrl}",
        name: "ProductRemoteDataSource",
      );
    }

    return products;
  } on DioException catch (e) {
    throw _handleDioError('getProducts', e);
  } catch (e, stackTrace) {
    dev.log(
      "UNEXPECTED ERROR : $e",
      name: "ProductRemoteDataSource",
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      dev.log('GET /api/v1/products/$id', name: 'ProductRemoteDataSource');
      Response response;
      try {
        response = await _dio.get('/api/v1/products/$id');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.get('/api/v1/products/$id');
        } else {
          rethrow;
        }
      }

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Invalid product data');
      }
    } on DioException catch (e) {
      throw _handleDioError('getProductById', e);
    }
  }

  Exception _handleDioError(String action, DioException error) {
    dev.log('Product Error [$action]: ${error.type} - ${error.message}', name: 'ProductRemoteDataSource', error: error);

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Exception('Connection timeout while communicating with product service.');
    }
    if (error.type == DioExceptionType.connectionError) {
      return Exception('Network unavailable. Failed to reach product server.');
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 500) {
      return Exception('Internal Server Error: Unable to fetch products.');
    }

    if (error.response?.data != null && error.response?.data is Map) {
      final msg = error.response?.data['error'] ?? error.response?.data['message'];
      if (msg != null) return Exception(msg.toString());
    }

    return Exception(error.message ?? 'Product request failed with status $statusCode');
  }
}
