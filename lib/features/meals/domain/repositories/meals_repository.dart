import 'package:dartz/dartz.dart';
import '../entities/food_entity.dart';
import '../entities/meal_entity.dart';

abstract class MealsRepository {
  Future<Either<String, List<FoodEntity>>> getFoods({String? query});
  Future<Either<String, List<MealEntity>>> getUserMeals(String userId, DateTime date);
  Future<Either<String, Unit>> addMeal({
    required String userId,
    required String foodId,
    required String mealType,
    required int servings,
    required DateTime date,
  });
  Future<Either<String, FoodEntity>> createFood({
    required String name,
    required int calories,
    required int carbs,
    required int protein,
    required int fat,
  });
  Future<Either<String, List<Map<String, dynamic>>>> getUserExercises(String userId, DateTime date);
  Future<Either<String, Unit>> addExercise({
    required String userId,
    required String name,
    required int calories,
    required DateTime date,
    int? duration,
    double? distance,
  });
}
