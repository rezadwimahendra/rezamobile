import 'package:equatable/equatable.dart';
import '../../domain/entities/food_entity.dart';

abstract class MealsEvent extends Equatable {
  const MealsEvent();

  @override
  List<Object?> get props => [];
}

class FoodsFetched extends MealsEvent {
  final String? query;
  const FoodsFetched({this.query});

  @override
  List<Object?> get props => [query];
}

class UserMealsFetched extends MealsEvent {
  final String userId;
  final DateTime date;
  const UserMealsFetched({required this.userId, required this.date});

  @override
  List<Object?> get props => [userId, date];
}

class MealAdded extends MealsEvent {
  final String userId;
  final FoodEntity food;
  final String mealType;
  final int servings;
  final DateTime date;

  const MealAdded({
    required this.userId,
    required this.food,
    required this.mealType,
    required this.servings,
    required this.date,
  });

  @override
  List<Object?> get props => [userId, food, mealType, servings, date];
}

class FoodCreated extends MealsEvent {
  final String name;
  final int calories;
  final int carbs;
  final int protein;
  final int fat;

  const FoodCreated({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  List<Object?> get props => [name, calories, carbs, protein, fat];
}

class ExerciseAdded extends MealsEvent {
  final String userId;
  final String name;
  final int calories;
  final DateTime date;
  final int? duration; // Baru
  final double? distance; // Baru

  const ExerciseAdded({
    required this.userId,
    required this.name,
    required this.calories,
    required this.date,
    this.duration,
    this.distance,
  });

  @override
  List<Object?> get props => [userId, name, calories, date, duration, distance];
}

class UserExercisesFetched extends MealsEvent {
  final String userId;
  final DateTime date;

  const UserExercisesFetched({required this.userId, required this.date});

  @override
  List<Object?> get props => [userId, date];
}
