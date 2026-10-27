import 'package:dartz/dartz.dart';
import 'package:ecommerce_app_huma_volve/core/failure/failure.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/home_product_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/repositories/home_repositry.dart';

class GetProductByIdUseCase {
  final HomeRepository homeRepository;

  GetProductByIdUseCase(this.homeRepository);

  Future<Either<Failure, ProductEntity>> invoke(int id) =>
      homeRepository.getProductById(id);
}
