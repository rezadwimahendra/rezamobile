import 'package:equatable/equatable.dart';

abstract class StepsState extends Equatable {
  const StepsState();
  
  @override
  List<Object?> get props => [];
}

class StepsInitial extends StepsState {}

class StepsLoading extends StepsState {}

class StepsLoaded extends StepsState {
  final int steps;
  final String status;

  const StepsLoaded({required this.steps, this.status = 'unknown'});

  @override
  List<Object?> get props => [steps, status];
}

class StepsError extends StepsState {
  final String message;
  const StepsError(this.message);

  @override
  List<Object?> get props => [message];
}

class StepsPermissionDenied extends StepsState {}
