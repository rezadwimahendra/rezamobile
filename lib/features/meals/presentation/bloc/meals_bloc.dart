import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_foods_usecase.dart';
import '../../domain/usecases/get_user_meals_usecase.dart';
import '../../domain/usecases/add_meal_usecase.dart';
import '../../domain/usecases/create_food_usecase.dart';
import 'meals_event.dart';
import 'meals_state.dart';

class MealsBloc extends Bloc<MealsEvent, MealsState> {
  final GetFoodsUseCase getFoodsUseCase;
  final GetUserMealsUseCase getUserMealsUseCase;
  final AddMealUseCase addMealUseCase;
  final CreateFoodUseCase createFoodUseCase;

  MealsBloc({
    required this.getFoodsUseCase,
    required this.getUserMealsUseCase,
    required this.addMealUseCase,
    required this.createFoodUseCase,
  }) : super(const MealsState()) {
    on<FoodsFetched>(_onFoodsFetched);
    on<UserMealsFetched>(_onUserMealsFetched);
    on<MealAdded>(_onMealAdded);
    on<FoodCreated>(_onFoodCreated);
    on<ExerciseAdded>(_onExerciseAdded);
    on<UserExercisesFetched>(_onUserExercisesFetched);
  }

  Future<void> _onExerciseAdded(ExerciseAdded event, Emitter<MealsState> emit) async {
    emit(state.copyWith(status: MealsStatus.loading));
    final result = await getFoodsUseCase.repository.addExercise(
      userId: event.userId,
      name: event.name,
      calories: event.calories,
      date: event.date,
      duration: event.duration,
      distance: event.distance,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: MealsStatus.error, errorMessage: failure)),
      (_) {
        add(UserExercisesFetched(userId: event.userId, date: event.date));
        emit(state.copyWith(status: MealsStatus.success));
      },
    );
  }

  Future<void> _onUserExercisesFetched(UserExercisesFetched event, Emitter<MealsState> emit) async {
    final result = await getFoodsUseCase.repository.getUserExercises(event.userId, event.date);
    result.fold(
      (failure) {
        print("DEBUG: [Gagal ambil latihan] $failure");
        emit(state.copyWith(status: MealsStatus.error, errorMessage: failure));
      },
      (exercises) {
        print("DEBUG: [Latihan Terambil] Jumlah: ${exercises.length}");
        int totalBurned = 0;
        int totalMinutes = 0;
        double totalDist = 0.0;

        for (var ex in exercises) {
          final cals = (ex['calories'] as num?)?.toInt() ?? 0;
          totalBurned += cals;
          
          final dur = (ex['duration'] as num?)?.toInt() ?? 0;
          totalMinutes += dur;

          final dist = (ex['distance'] as num?)?.toDouble() ?? 0.0;
          totalDist += dist;
        }
        print("DEBUG: [Total Latihan] Kalori: $totalBurned, Menit: $totalMinutes, Jarak: $totalDist");
        emit(state.copyWith(
          status: MealsStatus.loaded, 
          totalBurnedCalories: totalBurned,
          totalExerciseMinutes: totalMinutes,
          totalExerciseDistance: totalDist,
        ));
      },
    );
  }

  Future<void> _onFoodsFetched(FoodsFetched event, Emitter<MealsState> emit) async {
    emit(state.copyWith(status: MealsStatus.loading));
    final result = await getFoodsUseCase(query: event.query);
    result.fold(
      (failure) => emit(state.copyWith(status: MealsStatus.error, errorMessage: failure)),
      (foods) => emit(state.copyWith(status: MealsStatus.loaded, foods: foods)),
    );
  }

  Future<void> _onUserMealsFetched(UserMealsFetched event, Emitter<MealsState> emit) async {
    emit(state.copyWith(status: MealsStatus.loading));
    final result = await getUserMealsUseCase(event.userId, event.date);
    result.fold(
      (failure) => emit(state.copyWith(status: MealsStatus.error, errorMessage: failure)),
      (meals) => emit(state.copyWith(status: MealsStatus.loaded, userMeals: meals)),
    );
  }

  Future<void> _onMealAdded(MealAdded event, Emitter<MealsState> emit) async {
    emit(state.copyWith(status: MealsStatus.loading));
    
    String finalFoodId = event.food.id;

    // PocketBase IDs are exactly 15 characters. If longer/shorter, it's likely from an external API.
    // We must ensure the food exists in our local PocketBase collection first.
    if (finalFoodId.length != 15) {
      final createResult = await createFoodUseCase(
        name: event.food.name,
        calories: event.food.calories,
        carbs: event.food.carbs,
        protein: event.food.protein,
        fat: event.food.fat,
      );
      
      bool createError = false;
      String currentError = "";
      
      createResult.fold(
        (failure) {
          createError = true;
          currentError = failure;
        },
        (newFood) {
          finalFoodId = newFood.id;
        }
      );

      if (createError) {
        emit(state.copyWith(status: MealsStatus.error, errorMessage: "Gagal menyimpan data makanan lokal: $currentError"));
        return;
      }
    }

    final result = await addMealUseCase(
      userId: event.userId,
      foodId: finalFoodId,
      mealType: event.mealType,
      servings: event.servings,
      date: event.date,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: MealsStatus.error, errorMessage: failure)),
      (_) {
        // Refresh meals list FIRST
        add(UserMealsFetched(userId: event.userId, date: event.date));
        emit(state.copyWith(status: MealsStatus.success));
      },
    );
  }

  Future<void> _onFoodCreated(FoodCreated event, Emitter<MealsState> emit) async {
    emit(state.copyWith(status: MealsStatus.loading));
    final result = await createFoodUseCase(
      name: event.name,
      calories: event.calories,
      carbs: event.carbs,
      protein: event.protein,
      fat: event.fat,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: MealsStatus.error, errorMessage: failure)),
      (_) {
        emit(state.copyWith(status: MealsStatus.success));
        // Refresh foods list
        add(const FoodsFetched());
      },
    );
  }
}
