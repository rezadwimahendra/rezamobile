import '../../domain/entities/user_entity.dart';
import 'package:pocketbase/pocketbase.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.isTrainer = false,
    super.isGym = false,
    super.goalCalories = 0,
    super.birthDate,
    super.height = 0,
    super.initialWeight = 0.0,
    super.avatar,
  });

  factory UserModel.fromRecord(RecordModel record) {
    return UserModel(
      id: record.id,
      email: record.getStringValue('email'),
      name: record.getStringValue('name'),
      role: record.getStringValue('role'),
      isTrainer: record.data['is_trainer'] == true,
      isGym: record.data['is_gym'] == true,
      goalCalories: record.getIntValue('goal_calories'),
      birthDate: record.getStringValue('birth_date').isNotEmpty 
          ? DateTime.parse(record.getStringValue('birth_date')) 
          : null,
      height: record.getIntValue('height'),
      initialWeight: record.getDoubleValue('initial_weight'),
      avatar: record.getStringValue('avatar'),
    );
  }
}
