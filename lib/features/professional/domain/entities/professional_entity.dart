import 'package:equatable/equatable.dart';

class ProfessionalEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final int price;
  final int? nonMemberPrice;
  final String? specialty; // Specific to Trainer
  final String? location;  // Specific to Gym
  final String? avatar;    // Profile image filename
  final List<String>? gallery; // List of gallery filenames
  final double? latitude;
  final double? longitude;
  final String? openTime;
  final String? closeTime;
  final String? openDays;

  const ProfessionalEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.price,
    this.nonMemberPrice,
    this.specialty,
    this.location,
    this.avatar,
    this.gallery,
    this.latitude,
    this.longitude,
    this.openTime,
    this.closeTime,
    this.openDays,
  });

  @override
  List<Object?> get props => [id, userId, name, description, price, nonMemberPrice, specialty, location, avatar, gallery, latitude, longitude, openTime, closeTime, openDays];
}
