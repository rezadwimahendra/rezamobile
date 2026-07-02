import 'dart:io';
import 'package:dartz/dartz.dart';
import '../repositories/professional_repository.dart';

class RegisterProfessionalUseCase {
  final ProfessionalRepository repository;

  RegisterProfessionalUseCase(this.repository);

  Future<Either<String, Unit>> call({
    required String userId,
    required String role,
    required String name,
    required String description,
    required int price,
    String? specialty,
    String? location,
    File? avatarFile,
    List<File>? galleryFiles,
  }) {
    return repository.registerProfessional(
      userId: userId,
      role: role,
      name: name,
      description: description,
      price: price,
      specialty: specialty,
      location: location,
      avatarFile: avatarFile,
      galleryFiles: galleryFiles,
    );
  }
}
