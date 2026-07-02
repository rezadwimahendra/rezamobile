import 'package:dartz/dartz.dart';
import '../entities/food_entity.dart';
import '../repositories/meals_repository.dart';

class CreateFoodUseCase {
  final MealsRepository repository;

  CreateFoodUseCase(this.repository);

  Future<Either<String, FoodEntity>> call({
    required String name,
    required int calories,
    required int carbs,
    required int protein,
    required int fat,
  }) {
    return repository.createFood(
      name: name,
      calories: calories,
      carbs: carbs,
      protein: protein,
      fat: fat,
    );
  }
}
