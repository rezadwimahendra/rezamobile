import 'package:dartz/dartz.dart';
import '../entities/professional_entity.dart';
import '../repositories/professional_repository.dart';

class GetProfessionalDataUseCase {
  final ProfessionalRepository repository;

  GetProfessionalDataUseCase(this.repository);

  Future<Either<String, ProfessionalEntity?>> call(String userId, String role) {
    return repository.getProfessionalData(userId, role);
  }
}
