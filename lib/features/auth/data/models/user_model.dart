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
    super.dbAge,
  });

  factory UserModel.fromRecord(RecordModel record) {
    final email = record.getStringValue('email');
    final isSuperAdmin = email == 'superadmin@fitmotion.com' || record.collectionName == '_superusers';
    
    return UserModel(
      id: record.id,
      email: email,
      name: isSuperAdmin ? 'Super Admin' : record.getStringValue('name'),
      role: isSuperAdmin ? 'admin' : record.getStringValue('role'),
      isTrainer: record.data['is_trainer'] == true,
      isGym: record.data['is_gym'] == true,
      goalCalories: record.getIntValue('goal_calories'),
      birthDate: record.getStringValue('birth_date').isNotEmpty 
          ? DateTime.parse(record.getStringValue('birth_date')) 
          : null,
      height: isSuperAdmin ? 170 : record.getIntValue('height'),
      initialWeight: isSuperAdmin ? 60.0 : record.getDoubleValue('initial_weight'),
      avatar: record.getStringValue('avatar'),
      dbAge: record.data.containsKey('age') ? record.getIntValue('age') : null,
    );
  }
}
