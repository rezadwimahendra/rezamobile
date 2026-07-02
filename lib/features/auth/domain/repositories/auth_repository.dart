import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity>> login(String email, String password);
  Future<Either<String, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    DateTime? birthDate, // Baru
  });
  Future<Either<String, Unit>> logout();
}
