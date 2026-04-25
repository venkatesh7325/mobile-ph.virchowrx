import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, ProductEntity>> getProductById(String id);

  Future<Either<Failure, List<String>>> getCategories();
}
