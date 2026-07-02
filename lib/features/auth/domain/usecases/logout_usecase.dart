import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<String, Unit>> call() {
    return repository.logout();
  }
}
