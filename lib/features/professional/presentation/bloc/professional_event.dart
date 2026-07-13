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
  final int? nonMemberPrice;
  final String? specialty;
  final String? location;
  final File? avatarFile;
  final List<File>? galleryFiles;
  final double? latitude;
  final double? longitude;
  final String? openTime;
  final String? closeTime;
  final String? openDays;

  const ProfessionalRegistered({
    required this.userId,
    required this.role,
    required this.name,
    required this.description,
    required this.price,
    this.nonMemberPrice,
    this.specialty,
    this.location,
    this.avatarFile,
    this.galleryFiles,
    this.latitude,
    this.longitude,
    this.openTime,
    this.closeTime,
    this.openDays,
  });

  @override
  List<Object?> get props => [userId, role, name, description, price, nonMemberPrice, specialty, location, avatarFile, galleryFiles, latitude, longitude, openTime, closeTime, openDays];
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
