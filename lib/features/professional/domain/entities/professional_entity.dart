import 'package:equatable/equatable.dart';

class ProfessionalEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final int price;
  final String? specialty; // Specific to Trainer
  final String? location;  // Specific to Gym
  final String? avatar;    // Profile image filename
  final List<String>? gallery; // List of gallery filenames

  const ProfessionalEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.price,
    this.specialty,
    this.location,
    this.avatar,
    this.gallery,
  });

  @override
  List<Object?> get props => [id, userId, name, description, price, specialty, location, avatar, gallery];
}
