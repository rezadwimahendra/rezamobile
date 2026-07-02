import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<String, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    required String role,
    DateTime? birthDate, // Baru
  }) {
    return repository.register(
      name: name,
      email: email,
      password: password,
      role: role,
      birthDate: birthDate,
    );
  }
}
