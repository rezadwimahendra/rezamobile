import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../domain/entities/professional_entity.dart';
import '../../domain/repositories/professional_repository.dart';
import '../datasources/professional_remote_data_source.dart';

class ProfessionalRepositoryImpl implements ProfessionalRepository {
  final ProfessionalRemoteDataSource remoteDataSource;

  ProfessionalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, ProfessionalEntity?>> getProfessionalData(String userId, String role) async {
    try {
      final result = await remoteDataSource.getProfessionalData(userId, role);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> registerProfessional({
    required String userId,
    required String role,
    required String name,
    required String description,
    required int price,
    int? nonMemberPrice,
    String? specialty,
    String? location,
    File? avatarFile,
    List<File>? galleryFiles,
    List<String>? existingGallery,
    double? latitude,
    double? longitude,
    String? openTime,
    String? closeTime,
    String? openDays,
  }) async {
    try {
      await remoteDataSource.registerProfessional(
        userId: userId,
        role: role,
        name: name,
        description: description,
        price: price,
        nonMemberPrice: nonMemberPrice,
        specialty: specialty,
        location: location,
        avatarFile: avatarFile,
        galleryFiles: galleryFiles,
        existingGallery: existingGallery,
        latitude: latitude,
        longitude: longitude,
        openTime: openTime,
        closeTime: closeTime,
        openDays: openDays,
      );
      return const Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> subscribeProfessional({
    required String userId,
    required String roleType,
  }) async {
    try {
      await remoteDataSource.subscribeProfessional(userId, roleType);
      return const Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ProfessionalEntity>>> getAllTrainers() async {
    try {
      final result = await remoteDataSource.getAllTrainers();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ProfessionalEntity>>> getAllGyms() async {
    try {
      final result = await remoteDataSource.getAllGyms();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
