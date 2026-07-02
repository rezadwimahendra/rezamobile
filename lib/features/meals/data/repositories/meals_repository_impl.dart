import 'package:dartz/dartz.dart';
import '../../domain/entities/food_entity.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/repositories/meals_repository.dart';
import '../datasources/meals_remote_data_source.dart';
import '../datasources/nutrition_external_data_source.dart';

class MealsRepositoryImpl implements MealsRepository {
  final MealsRemoteDataSource remoteDataSource;
  final NutritionExternalDataSource externalDataSource;

  MealsRepositoryImpl({
    required this.remoteDataSource,
    required this.externalDataSource,
  });

  @override
  Future<Either<String, List<FoodEntity>>> getFoods({String? query}) async {
    List<FoodEntity> results = [];
    
    try {
      // 1. Coba cari di database lokal (PocketBase)
      final localResult = await remoteDataSource.getFoods(query: query);
      results.addAll(localResult);
    } catch (e) {
      // Jika error (misal tabel belum ada), tidak apa-apa, lanjut ke global
      print("Local fetch error (expected if table missing): $e");
    }

    // 2. Jika hasil masih kosong dan ada query, cari di database global (Open Food Facts)
    if (results.isEmpty && query != null && query.isNotEmpty) {
      try {
        final isBarcode = RegExp(r'^[0-9]+$').hasMatch(query);
        
        if (isBarcode && query.length >= 8) {
          final product = await externalDataSource.getProductByBarcode(query);
          if (product != null) return Right([product]);
        }
        
        final remoteResult = await externalDataSource.searchFoods(query);
        return Right(remoteResult);
      } catch (e) {
        return Left("Gagal mengambil data global: $e");
      }
    }

    return Right(results);
  }

  @override
  Future<Either<String, List<MealEntity>>> getUserMeals(String userId, DateTime date) async {
    try {
      final result = await remoteDataSource.getUserMeals(userId, date);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> addMeal({
    required String userId,
    required String foodId,
    required String mealType,
    required int servings,
    required DateTime date,
  }) async {
    try {
      await remoteDataSource.addMeal(
        userId: userId,
        foodId: foodId,
        mealType: mealType,
        servings: servings,
        date: date,
      );
      return const Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, FoodEntity>> createFood({
    required String name,
    required int calories,
    required int carbs,
    required int protein,
    required int fat,
  }) async {
    try {
      final result = await remoteDataSource.createFood(
        name: name,
        calories: calories,
        carbs: carbs,
        protein: protein,
        fat: fat,
      );
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getUserExercises(String userId, DateTime date) async {
    try {
      final result = await remoteDataSource.getUserExercises(userId, date);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> addExercise({
    required String userId,
    required String name,
    required int calories,
    required DateTime date,
    int? duration,
    double? distance,
  }) async {
    try {
      await remoteDataSource.addExercise(
        userId: userId, 
        name: name, 
        calories: calories, 
        date: date,
        duration: duration,
        distance: distance,
      );
      return const Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
