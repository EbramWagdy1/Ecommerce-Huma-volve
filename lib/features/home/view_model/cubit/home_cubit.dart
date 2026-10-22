import 'package:ecommerce_app_huma_volve/features/home/service/home_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app_huma_volve/features/home/models/categories_model.dart';
import 'package:ecommerce_app_huma_volve/features/home/models/product_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeService homeService;
  List<CategoryModel> categories = [];
  List<ProductModel> products = [];

  HomeCubit(this.homeService) : super(HomeInitial());

  Future<void> getCategories() async {
    emit(CategoryLoading());
    try {
      categories = await homeService.getCategories();
      emit(CategorySuccess(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> getProducts({int? categoryId}) async {
    emit(ProductsLoading());
    try {
      products = await homeService.getProducts(categoryId: categoryId);
      emit(ProductsSuccess(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }
}
