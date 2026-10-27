import 'package:ecommerce_app_huma_volve/core/constants/api_endpoint.dart';
import 'package:ecommerce_app_huma_volve/core/errors/error_handling.dart';
import 'package:ecommerce_app_huma_volve/core/network/api_client.dart';
import 'package:ecommerce_app_huma_volve/features/home/data/data_source/home_remote_data_source.dart';
import 'package:ecommerce_app_huma_volve/features/home/data/models/categories_model.dart';
import 'package:ecommerce_app_huma_volve/features/home/data/models/product_model.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiService;
  HomeRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiService.dio.get(ApiEndpoint.categories);
      final dynamic data = response.data;
      final List rawList = data is List
          ? data
          : (data is Map && data['categories'] is List)
              ? data['categories'] as List
              : [];

      return rawList
          .whereType<Map>()
          .map((json) {
            try {
              return CategoryModel.fromJson(json);
            } catch (_) {
              return null;
            }
          })
          .whereType<CategoryModel>()
          .toList();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<List<ProductModel>> getProducts({
    int? categoryId,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final String path = categoryId != null
          ? "${ApiEndpoint.categories}/$categoryId/${ApiEndpoint.products}"
          : ApiEndpoint.products;

      final response = await apiService.dio.get(
        path,
        queryParameters: {
          'offset': offset,
          'limit': limit,
        },
      );
      final dynamic data = response.data;
      final List rawList = data is List
          ? data
          : (data is Map && data['products'] is List)
              ? data['products'] as List
              : [];

      return rawList
          .whereType<Map>()
          .map((json) {
            try {
              return ProductModel.fromJson(json);
            } catch (_) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .where((product) =>
              product.images != null &&
              product.images!.isNotEmpty &&
              product.images!.any((img) => img.trim().startsWith('http')))
          .toList();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await apiService.dio.get('${ApiEndpoint.products}/$id');
      final dynamic data = response.data;
      if (data is Map) {
        return ProductModel.fromJson(data);
      }
      throw ErrorHandler.handleException('Invalid product data');
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
