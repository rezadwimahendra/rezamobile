import 'package:pocketbase/pocketbase.dart';
import '../models/food_model.dart';
import '../models/meal_model.dart';

abstract class MealsRemoteDataSource {
  Future<List<FoodModel>> getFoods({String? query});
  Future<List<MealModel>> getUserMeals(String userId, DateTime date);
  Future<void> addMeal({
    required String userId,
    required String foodId,
    required String mealType,
    required int servings,
    required DateTime date,
  });
  Future<FoodModel> createFood({
    required String name,
    required int calories,
    required int carbs,
    required int protein,
    required int fat,
  });
  Future<List<Map<String, dynamic>>> getUserExercises(String userId, DateTime date);
  Future<void> addExercise({
    required String userId,
    required String name,
    required int calories,
    required DateTime date,
    int? duration, // Baru
    double? distance, // Baru
  });
}

class MealsRemoteDataSourceImpl implements MealsRemoteDataSource {
  final PocketBase pb;

  MealsRemoteDataSourceImpl({required this.pb});

  @override
  Future<List<FoodModel>> getFoods({String? query}) async {
    final filter = query != null && query.isNotEmpty ? 'name ~ "$query" || barcode = "$query"' : '';
    final result = await pb.collection('foods').getList(
      page: 1,
      perPage: 50,
      sort: 'name',
      filter: filter,
    );
    return result.items.map((item) => FoodModel.fromRecord(item)).toList();
  }

  @override
  Future<List<MealModel>> getUserMeals(String userId, DateTime date) async {
    // Format date for filter (usually just the day)
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await pb.collection('user_meals').getList(
      filter: 'user = "$userId" && date ~ "$dateStr"',
      expand: 'food',
    );
    return result.items.map((item) => MealModel.fromRecord(item)).toList();
  }

  @override
  Future<void> addMeal({
    required String userId,
    required String foodId,
    required String mealType,
    required int servings,
    required DateTime date,
  }) async {
    await pb.collection('user_meals').create(body: {
      'user': userId,
      'food': foodId,
      'meal_type': mealType,
      'servings': servings,
      'date': date.toIso8601String(),
    });
  }

  @override
  Future<FoodModel> createFood({
    required String name,
    required int calories,
    required int carbs,
    required int protein,
    required int fat,
  }) async {
    final record = await pb.collection('foods').create(body: {
      'name': name,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
    });
    return FoodModel.fromRecord(record);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserExercises(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    try {
      final result = await pb.collection('user_exercises').getList(
        filter: 'user = "$userId" && date ~ "$dateStr"',
      );
      return result.items.map((item) => item.toJson()).toList();
    } catch (e) {
      print("DEBUG: [PocketBase Error] Fetch Exercise: $e");
      return [];
    }
  }

  @override
  Future<void> addExercise({
    required String userId,
    required String name,
    required int calories,
    required DateTime date,
    int? duration,
    double? distance,
  }) async {
    await pb.collection('user_exercises').create(body: {
      'user': userId,
      'name': name,
      'calories': calories,
      'date': date.toIso8601String(),
      'duration': duration, // Baru
      'distance': distance, // Baru
    });
  }
}
