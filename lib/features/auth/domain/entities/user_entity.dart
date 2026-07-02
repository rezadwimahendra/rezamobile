import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final int goalCalories;
  final DateTime? birthDate; // Baru
  final int height;
  final double initialWeight;
  final bool isTrainer;
  final bool isGym;
  final String? avatar;

  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isTrainer = false,
    this.isGym = false,
    this.goalCalories = 0,
    this.birthDate,
    this.height = 0,
    this.initialWeight = 0,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, email, name, role, isTrainer, isGym, goalCalories, birthDate, height, initialWeight, avatar];
}
