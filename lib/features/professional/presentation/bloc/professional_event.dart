import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfessionalEvent extends Equatable {
  const ProfessionalEvent();

  @override
  List<Object?> get props => [];
}

class ProfessionalDataRequested extends ProfessionalEvent {
  final String userId;
  final String role;
  const ProfessionalDataRequested({required this.userId, required this.role});

  @override
  List<Object?> get props => [userId, role];
}

class ProfessionalRegistered extends ProfessionalEvent {
  final String userId;
  final String role;
  final String name;
  final String description;
  final int price;
  final String? specialty;
  final String? location;
  final File? avatarFile;
  final List<File>? galleryFiles;

  const ProfessionalRegistered({
    required this.userId,
    required this.role,
    required this.name,
    required this.description,
    required this.price,
    this.specialty,
    this.location,
    this.avatarFile,
    this.galleryFiles,
  });

  @override
  List<Object?> get props => [userId, role, name, description, price, specialty, location, avatarFile, galleryFiles];
}

class ProfessionalSubscribed extends ProfessionalEvent {
  final String userId;
  final String roleType;
  const ProfessionalSubscribed({required this.userId, required this.roleType});

  @override
  List<Object?> get props => [userId, roleType];
}

class TrainersListRequested extends ProfessionalEvent {}
class GymsListRequested extends ProfessionalEvent {}
