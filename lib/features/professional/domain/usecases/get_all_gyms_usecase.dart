import 'package:dartz/dartz.dart';
import '../entities/professional_entity.dart';
import '../repositories/professional_repository.dart';

class GetAllGymsUseCase {
  final ProfessionalRepository repository;

  GetAllGymsUseCase(this.repository);

  Future<Either<String, List<ProfessionalEntity>>> execute() {
    return repository.getAllGyms();
  }
}
