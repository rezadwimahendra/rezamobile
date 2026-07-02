import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/professional_entity.dart';

abstract class ProfessionalRepository {
  Future<Either<String, ProfessionalEntity>> getProfessionalData(String userId, String role);
  
  Future<Either<String, Unit>> registerProfessional({
    required String userId,
    required String role,
    required String name,
    required String description,
    required int price,
    String? specialty,
    String? location,
    File? avatarFile,
    List<File>? galleryFiles,
  });

  Future<Either<String, Unit>> subscribeProfessional({
    required String userId,
    required String roleType,
  });

  Future<Either<String, List<ProfessionalEntity>>> getAllTrainers();
  Future<Either<String, List<ProfessionalEntity>>> getAllGyms();
}
