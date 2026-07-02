import 'package:dartz/dartz.dart';
import '../repositories/professional_repository.dart';

class SubscribeProfessionalUseCase {
  final ProfessionalRepository repository;

  SubscribeProfessionalUseCase(this.repository);

  Future<Either<String, Unit>> call({
    required String userId,
    required String roleType,
  }) {
    return repository.subscribeProfessional(
      userId: userId,
      roleType: roleType,
    );
  }
}
