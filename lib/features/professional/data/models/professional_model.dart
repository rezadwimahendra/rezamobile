import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/professional_entity.dart';

class ProfessionalModel extends ProfessionalEntity {
  const ProfessionalModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.description,
    required super.price,
    super.specialty,
    super.location,
    super.avatar,
    super.gallery,
  });

  factory ProfessionalModel.fromRecord(RecordModel record) {
    return ProfessionalModel(
      id: record.id,
      userId: record.getStringValue('user'),
      name: record.getStringValue('name'),
      description: record.getStringValue('description'),
      price: record.getIntValue('price'),
      specialty: record.getStringValue('specialty'),
      location: record.getStringValue('location'),
      avatar: record.getStringValue('avatar'),
      gallery: record.getListValue<String>('gallery'),
    );
  }
}
