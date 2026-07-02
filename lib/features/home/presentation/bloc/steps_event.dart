import 'package:equatable/equatable.dart';

abstract class StepsEvent extends Equatable {
  const StepsEvent();

  @override
  List<Object?> get props => [];
}

class StepsStarted extends StepsEvent {}

class StepsUpdated extends StepsEvent {
  final int steps;
  final String status;

  const StepsUpdated(this.steps, this.status);

  @override
  List<Object?> get props => [steps, status];
}
