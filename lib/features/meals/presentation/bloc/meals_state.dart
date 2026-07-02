import 'package:equatable/equatable.dart';
import '../../domain/entities/food_entity.dart';
import '../../domain/entities/meal_entity.dart';

enum MealsStatus { initial, loading, loaded, success, error }

class MealsState extends Equatable {
  final MealsStatus status;
  final List<FoodEntity> foods;
  final List<MealEntity> userMeals;
  final int totalBurnedCalories;
  final int totalExerciseMinutes; // Baru
  final double totalExerciseDistance; // Baru
  final String? errorMessage;

  const MealsState({
    this.status = MealsStatus.initial,
    this.foods = const [],
    this.userMeals = const [],
    this.totalBurnedCalories = 0,
    this.totalExerciseMinutes = 0,
    this.totalExerciseDistance = 0.0,
    this.errorMessage,
  });

  MealsState copyWith({
    MealsStatus? status,
    List<FoodEntity>? foods,
    List<MealEntity>? userMeals,
    int? totalBurnedCalories,
    int? totalExerciseMinutes,
    double? totalExerciseDistance,
    String? errorMessage,
  }) {
    return MealsState(
      status: status ?? this.status,
      foods: foods ?? this.foods,
      userMeals: userMeals ?? this.userMeals,
      totalBurnedCalories: totalBurnedCalories ?? this.totalBurnedCalories,
      totalExerciseMinutes: totalExerciseMinutes ?? this.totalExerciseMinutes,
      totalExerciseDistance: totalExerciseDistance ?? this.totalExerciseDistance,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, foods, userMeals, totalBurnedCalories, totalExerciseMinutes, totalExerciseDistance, errorMessage];
}
