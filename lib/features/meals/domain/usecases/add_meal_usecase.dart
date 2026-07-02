import 'package:dartz/dartz.dart';
import '../repositories/meals_repository.dart';

class AddMealUseCase {
  final MealsRepository repository;

  AddMealUseCase(this.repository);

  Future<Either<String, Unit>> call({
    required String userId,
    required String foodId,
    required String mealType,
    required int servings,
    required DateTime date,
  }) {
    return repository.addMeal(
      userId: userId,
      foodId: foodId,
      mealType: mealType,
      servings: servings,
      date: date,
    );
  }
}
