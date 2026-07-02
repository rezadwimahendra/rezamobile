import 'package:equatable/equatable.dart';
import '../../domain/entities/professional_entity.dart';

enum ProfessionalStatus { initial, loading, success, error }

class ProfessionalState extends Equatable {
  final ProfessionalStatus status;
  final ProfessionalEntity? professional;
  final List<ProfessionalEntity> trainers;
  final List<ProfessionalEntity> gyms;
  final String? errorMessage;

  const ProfessionalState({
    this.status = ProfessionalStatus.initial,
    this.professional,
    this.trainers = const [],
    this.gyms = const [],
    this.errorMessage,
  });

  ProfessionalState copyWith({
    ProfessionalStatus? status,
    ProfessionalEntity? professional,
    List<ProfessionalEntity>? trainers,
    List<ProfessionalEntity>? gyms,
    String? errorMessage,
  }) {
    return ProfessionalState(
      status: status ?? this.status,
      professional: professional ?? this.professional,
      trainers: trainers ?? this.trainers,
      gyms: gyms ?? this.gyms,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, professional, trainers, gyms, errorMessage];
}
