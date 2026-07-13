import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/meals/data/datasources/meals_remote_data_source.dart';
import 'features/meals/data/repositories/meals_repository_impl.dart';
import 'features/meals/domain/repositories/meals_repository.dart';
import 'features/meals/domain/usecases/get_foods_usecase.dart';
import 'features/meals/domain/usecases/add_meal_usecase.dart';
import 'features/meals/domain/usecases/get_user_meals_usecase.dart';
import 'features/meals/domain/usecases/create_food_usecase.dart';
import 'features/meals/presentation/bloc/meals_bloc.dart';
import 'features/meals/data/datasources/nutrition_external_data_source.dart';
import 'features/meals/data/services/gemini_service.dart';
import 'package:http/http.dart' as http;

import 'features/professional/data/datasources/professional_remote_data_source.dart';
import 'features/professional/data/repositories/professional_repository_impl.dart';
import 'features/professional/domain/repositories/professional_repository.dart';
import 'features/professional/domain/usecases/get_all_gyms_usecase.dart';
import 'features/professional/domain/usecases/get_all_trainers_usecase.dart';
import 'features/professional/domain/usecases/get_professional_data_usecase.dart';
import 'features/professional/domain/usecases/register_professional_usecase.dart';
import 'features/professional/domain/usecases/subscribe_professional_usecase.dart';
import 'features/professional/presentation/bloc/professional_bloc.dart';
import 'features/home/presentation/bloc/weight_bloc.dart';
import 'features/chat/data/datasources/chat_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      pb: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => MealsBloc(
      getFoodsUseCase: sl(),
      getUserMealsUseCase: sl(),
      addMealUseCase: sl(),
      createFoodUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ProfessionalBloc(
      getProfessionalDataUseCase: sl(),
      registerProfessionalUseCase: sl(),
      subscribeProfessionalUseCase: sl(),
      getAllTrainersUseCase: sl(),
      getAllGymsUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => WeightBloc(pb: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetFoodsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserMealsUseCase(sl()));
  sl.registerLazySingleton(() => AddMealUseCase(sl()));
  sl.registerLazySingleton(() => CreateFoodUseCase(sl()));
  sl.registerLazySingleton(() => GetProfessionalDataUseCase(sl()));
  sl.registerLazySingleton(() => RegisterProfessionalUseCase(sl()));
  sl.registerLazySingleton(() => SubscribeProfessionalUseCase(sl()));
  sl.registerLazySingleton(() => GetAllTrainersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetAllGymsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MealsRepository>(
    () => MealsRepositoryImpl(remoteDataSource: sl(), externalDataSource: sl()),
  );
  sl.registerLazySingleton<ProfessionalRepository>(
    () => ProfessionalRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(pb: sl()),
  );
  sl.registerLazySingleton<MealsRemoteDataSource>(
    () => MealsRemoteDataSourceImpl(pb: sl()),
  );
  sl.registerLazySingleton<ProfessionalRemoteDataSource>(
    () => ProfessionalRemoteDataSourceImpl(pb: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton(() => NutritionExternalDataSource(client: sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final store = AsyncAuthStore(
    save: (String data) async => sharedPreferences.setString('pb_auth', data),
    initial: sharedPreferences.getString('pb_auth'),
    clear: () async => sharedPreferences.remove('pb_auth'),
  );

  final url = kIsWeb ? 'http://127.0.0.1:8090' : 'http://10.249.128.252:8090';
  sl.registerLazySingleton(() => PocketBase(url, authStore: store));
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(
    () => GeminiService(
      apiKey: const String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'PLACEHOLDER_GEMINI_KEY'),
    ),
  );
}
