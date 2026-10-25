import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/home_catagory_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/home_product_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/use_cases/get_categories_use_case.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/use_cases/get_product_use_case.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsUseCase getProductsUseCase;

  List<CategoryEntity> categories = [];
  List<ProductEntity> products = [];

  int offset = 0;
  static const int limit = 10;
  bool hasMore = true;
  bool isLoadingMore = false;
  int? currentCategoryId;

  HomeCubit({
    required this.getCategoriesUseCase,
    required this.getProductsUseCase,
  }) : super(HomeInitial());

  Future<void> getCategories() async {
    emit(CategoryLoading());
    final result = await getCategoriesUseCase.invoke();
    result.fold(
      (failure) => emit(CategoryError(message: failure.message)),
      (data) {
        categories = data;
        emit(CategorySuccess(categories: categories));
      },
    );
  }

  Future<void> getProducts({int? categoryId, bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadingMore || !hasMore) return;
      isLoadingMore = true;
      emit(ProductsPaginationLoading());

      final result = await getProductsUseCase.invoke(
        categoryId: currentCategoryId,
        offset: offset,
        limit: limit,
      );

      result.fold(
        (failure) {
          isLoadingMore = false;
          emit(ProductsPaginationError(message: failure.message));
        },
        (data) {
          isLoadingMore = false;
          products.addAll(data);
          offset += data.length;
          if (data.length < limit) {
            hasMore = false;
          }
          emit(ProductsSuccess(products: List.of(products), hasMore: hasMore));
        },
      );
    } else {
      currentCategoryId = categoryId;
      offset = 0;
      hasMore = true;
      isLoadingMore = false;
      products = [];
      emit(ProductsLoading());

      final result = await getProductsUseCase.invoke(
        categoryId: currentCategoryId,
        offset: offset,
        limit: limit,
      );

      result.fold(
        (failure) => emit(ProductsError(message: failure.message)),
        (data) {
          products = data;
          offset = data.length;
          if (data.length < limit) {
            hasMore = false;
          }
          emit(ProductsSuccess(products: List.of(products), hasMore: hasMore));
        },
      );
    }
  }
}
