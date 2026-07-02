import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/meal_entity.dart';
import 'food_model.dart';

class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.userId,
    required super.food,
    required super.mealType,
    required super.servings,
    required super.date,
  });

  factory MealModel.fromRecord(RecordModel record) {
    return MealModel(
      id: record.id,
      userId: record.getStringValue('user'),
      food: FoodModel.fromRecord(record.expand['food']![0]),
      mealType: record.getStringValue('meal_type'),
      servings: record.getIntValue('servings'),
      date: DateTime.parse(record.getStringValue('date')),
    );
  }
}
