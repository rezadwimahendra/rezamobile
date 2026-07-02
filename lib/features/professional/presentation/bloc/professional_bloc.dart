import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_gyms_usecase.dart';
import '../../domain/usecases/get_all_trainers_usecase.dart';
import '../../domain/usecases/get_professional_data_usecase.dart';
import '../../domain/usecases/register_professional_usecase.dart';
import '../../domain/usecases/subscribe_professional_usecase.dart';
import 'professional_event.dart';
import 'professional_state.dart';

class ProfessionalBloc extends Bloc<ProfessionalEvent, ProfessionalState> {
  final GetProfessionalDataUseCase getProfessionalDataUseCase;
  final RegisterProfessionalUseCase registerProfessionalUseCase;
  final SubscribeProfessionalUseCase subscribeProfessionalUseCase;
  final GetAllTrainersUseCase getAllTrainersUseCase;
  final GetAllGymsUseCase getAllGymsUseCase;

  ProfessionalBloc({
    required this.getProfessionalDataUseCase,
    required this.registerProfessionalUseCase,
    required this.subscribeProfessionalUseCase,
    required this.getAllTrainersUseCase,
    required this.getAllGymsUseCase,
  }) : super(const ProfessionalState()) {
    on<ProfessionalDataRequested>(_onProfessionalDataRequested);
    on<ProfessionalRegistered>(_onProfessionalRegistered);
    on<ProfessionalSubscribed>(_onProfessionalSubscribed);
    on<TrainersListRequested>(_onTrainersListRequested);
    on<GymsListRequested>(_onGymsListRequested);
  }

  Future<void> _onProfessionalDataRequested(ProfessionalDataRequested event, Emitter<ProfessionalState> emit) async {
    emit(state.copyWith(status: ProfessionalStatus.loading));
    final result = await getProfessionalDataUseCase(event.userId, event.role);
    result.fold(
      (failure) => emit(state.copyWith(status: ProfessionalStatus.error, errorMessage: failure)),
      (professional) => emit(state.copyWith(status: ProfessionalStatus.success, professional: professional)),
    );
  }

  Future<void> _onProfessionalRegistered(ProfessionalRegistered event, Emitter<ProfessionalState> emit) async {
    emit(state.copyWith(status: ProfessionalStatus.loading));
    final result = await registerProfessionalUseCase(
      userId: event.userId,
      role: event.role,
      name: event.name,
      description: event.description,
      price: event.price,
      specialty: event.specialty,
      location: event.location,
      avatarFile: event.avatarFile,
      galleryFiles: event.galleryFiles,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: ProfessionalStatus.error, errorMessage: failure)),
      (_) => emit(state.copyWith(status: ProfessionalStatus.success)),
    );
  }

  Future<void> _onProfessionalSubscribed(ProfessionalSubscribed event, Emitter<ProfessionalState> emit) async {
    debugPrint("DEBUG: ProfessionalBloc: Menjalankan Subscribe Usecase untuk ${event.userId}");
    emit(state.copyWith(status: ProfessionalStatus.loading));
    final result = await subscribeProfessionalUseCase(
      userId: event.userId,
      roleType: event.roleType,
    );
    result.fold(
      (failure) {
        debugPrint("DEBUG: ProfessionalBloc: GAGAL Finalisasi: $failure");
        emit(state.copyWith(status: ProfessionalStatus.error, errorMessage: failure));
      },
      (_) {
        debugPrint("DEBUG: ProfessionalBloc: BERHASIL Finalisasi! Mengirim status success...");
        emit(state.copyWith(status: ProfessionalStatus.success));
      },
    );
  }

  Future<void> _onTrainersListRequested(TrainersListRequested event, Emitter<ProfessionalState> emit) async {
    print('DEBUG: Bloc: Menerima TrainersListRequested');
    emit(state.copyWith(status: ProfessionalStatus.loading));
    final result = await getAllTrainersUseCase();
    result.fold(
      (failure) {
        print('DEBUG: Bloc: Gagal mengambil data: $failure');
        emit(state.copyWith(status: ProfessionalStatus.error, errorMessage: failure));
      },
      (trainers) {
        print('DEBUG: Bloc: Berhasil! Jumlah pelatih: ${trainers.length}');
        emit(state.copyWith(status: ProfessionalStatus.success, trainers: trainers));
      },
    );
  }

  Future<void> _onGymsListRequested(GymsListRequested event, Emitter<ProfessionalState> emit) async {
    print('DEBUG: Bloc: Menerima GymsListRequested');
    emit(state.copyWith(status: ProfessionalStatus.loading));
    final result = await getAllGymsUseCase.execute();
    result.fold(
      (failure) {
        print('DEBUG: Bloc: Gagal mengambil gyms: $failure');
        emit(state.copyWith(status: ProfessionalStatus.error, errorMessage: failure));
      },
      (gyms) {
        print('DEBUG: Bloc: Berhasil! Jumlah gyms: ${gyms.length}');
        emit(state.copyWith(status: ProfessionalStatus.success, gyms: gyms));
      },
    );
  }
}
