import 'package:equatable/equatable.dart';

class FoodEntity extends Equatable {
  final String id;
  final String name;
  final int calories;
  final int carbs;
  final int protein;
  final int fat;

  const FoodEntity({
    required this.id,
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  List<Object?> get props => [id, name, calories, carbs, protein, fat];
}
