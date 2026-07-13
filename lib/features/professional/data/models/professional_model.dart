import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/professional_entity.dart';

class ProfessionalModel extends ProfessionalEntity {
  const ProfessionalModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.description,
    required super.price,
    super.nonMemberPrice,
    super.specialty,
    super.location,
    super.avatar,
    super.gallery,
    super.latitude,
    super.longitude,
    super.openTime,
    super.closeTime,
    super.openDays,
  });

  factory ProfessionalModel.fromRecord(RecordModel record) {
    return ProfessionalModel(
      id: record.id,
      userId: record.getStringValue('user'),
      name: record.getStringValue('name'),
      description: record.getStringValue('description'),
      price: record.getIntValue('price'),
      nonMemberPrice: record.data.containsKey('non_member_price') ? record.getIntValue('non_member_price') : null,
      specialty: record.getStringValue('specialty'),
      location: record.getStringValue('location'),
      avatar: record.getStringValue('avatar'),
      gallery: record.getListValue<String>('gallery'),
      latitude: record.data.containsKey('latitude') ? record.getDoubleValue('latitude') : null,
      longitude: record.data.containsKey('longitude') ? record.getDoubleValue('longitude') : null,
      openTime: record.data.containsKey('open_time') ? record.getStringValue('open_time') : null,
      closeTime: record.data.containsKey('close_time') ? record.getStringValue('close_time') : null,
      openDays: record.data.containsKey('open_days') ? record.getStringValue('open_days') : null,
    );
  }
}
