import 'package:equatable/equatable.dart';
import 'food_entity.dart';

class MealEntity extends Equatable {
  final String id;
  final String userId;
  final FoodEntity food;
  final String mealType;
  final int servings;
  final DateTime date;

  const MealEntity({
    required this.id,
    required this.userId,
    required this.food,
    required this.mealType,
    required this.servings,
    required this.date,
  });

  @override
  List<Object?> get props => [id, userId, food, mealType, servings, date];
}
