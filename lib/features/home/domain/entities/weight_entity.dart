import 'package:equatable/equatable.dart';

class WeightEntity extends Equatable {
  final String id;
  final String userId;
  final double weight;
  final DateTime date;

  const WeightEntity({
    required this.id,
    required this.userId,
    required this.weight,
    required this.date,
  });

  @override
  List<Object?> get props => [id, userId, weight, date];
}
