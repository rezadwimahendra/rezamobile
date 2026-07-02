import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/weight_entity.dart';

class WeightModel extends WeightEntity {
  const WeightModel({
    required super.id,
    required super.userId,
    required super.weight,
    required super.date,
  });

  factory WeightModel.fromRecord(RecordModel record) {
    return WeightModel(
      id: record.id,
      userId: record.getStringValue('user'),
      weight: record.getDoubleValue('weights'),
      date: DateTime.parse(record.getStringValue('date')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'weights': weight,
      'date': date.toIso8601String(),
    };
  }
}
