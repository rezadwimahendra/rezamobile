import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/food_entity.dart';

class FoodModel extends FoodEntity {
  const FoodModel({
    required super.id,
    required super.name,
    required super.calories,
    required super.carbs,
    required super.protein,
    required super.fat,
  });

  factory FoodModel.fromRecord(RecordModel record) {
    return FoodModel(
      id: record.id,
      name: record.getStringValue('name'),
      calories: record.getIntValue('calories'),
      carbs: record.getIntValue('carbs'),
      protein: record.getIntValue('protein'),
      fat: record.getIntValue('fat'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
    };
  }
}
