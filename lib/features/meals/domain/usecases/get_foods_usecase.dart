import 'package:dartz/dartz.dart';
import '../entities/food_entity.dart';
import '../repositories/meals_repository.dart';

class GetFoodsUseCase {
  final MealsRepository repository;

  GetFoodsUseCase(this.repository);

  Future<Either<String, List<FoodEntity>>> call({String? query}) {
    return repository.getFoods(query: query);
  }
}
