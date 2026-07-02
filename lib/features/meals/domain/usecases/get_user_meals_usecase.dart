import 'package:dartz/dartz.dart';
import '../entities/meal_entity.dart';
import '../repositories/meals_repository.dart';

class GetUserMealsUseCase {
  final MealsRepository repository;

  GetUserMealsUseCase(this.repository);

  Future<Either<String, List<MealEntity>>> call(String userId, DateTime date) {
    return repository.getUserMeals(userId, date);
  }
}
