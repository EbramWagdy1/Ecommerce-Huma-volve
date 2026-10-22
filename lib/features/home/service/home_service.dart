import 'package:ecommerce_app_huma_volve/core/constants/api_endpoint.dart';
import 'package:ecommerce_app_huma_volve/core/network/api_client.dart';
import 'package:ecommerce_app_huma_volve/features/home/models/categories_model.dart';
import 'package:ecommerce_app_huma_volve/features/home/models/product_model.dart';

class HomeService {
  final ApiClient apiClient;

  HomeService(this.apiClient);
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoint.categories);
      return (response.data as List<dynamic>)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<ProductModel>> getProducts({int? categoryId}) async {
    try {
      if(categoryId!=null){
      final response = await apiClient.dio.get("${ApiEndpoint.categories}/$categoryId/${ApiEndpoint.products}");
      return (response.data as List<dynamic>)
          .map((json) => ProductModel.fromJson(json))
          .toList();
      }
      else{
        final response = await apiClient.dio.get(ApiEndpoint.products);
        return (response.data as List<dynamic>)
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
