import 'package:equatable/equatable.dart';
import '../../domain/entities/weight_entity.dart';

abstract class WeightEvent extends Equatable {
  const WeightEvent();
  @override
  List<Object?> get props => [];
}

class LatestWeightFetched extends WeightEvent {
  final String userId;
  const LatestWeightFetched(this.userId);
  @override
  List<Object?> get props => [userId];
}

abstract class WeightState extends Equatable {
  const WeightState();
  @override
  List<Object?> get props => [];
}

class WeightInitial extends WeightState {}
class WeightLoading extends WeightState {}
class WeightLoaded extends WeightState {
  final WeightEntity? latestWeight;
  const WeightLoaded(this.latestWeight);
  @override
  List<Object?> get props => [latestWeight];
}
class WeightError extends WeightState {
  final String message;
  const WeightError(this.message);
  @override
  List<Object?> get props => [message];
}
