import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'steps_event.dart';
import 'steps_state.dart';

class StepsBloc extends Bloc<StepsEvent, StepsState> {
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  StepsBloc() : super(StepsInitial()) {
    on<StepsStarted>(_onStarted);
    on<StepsUpdated>(_onUpdated);
  }

  Future<void> _onStarted(StepsStarted event, Emitter<StepsState> emit) async {
    emit(StepsLoading());

    try {
      // 1. Cek dan minta izin Physical Activity
      var status = await Permission.activityRecognition.request();
      
      if (status.isPermanentlyDenied) {
        emit(const StepsError('Izin ditolak secara permanen. Silakan aktifkan di Pengaturan.'));
        return;
      }

      if (status.isGranted) {
        // 2. Jika diizinkan, mulai dengarkan sensor
        await _stepCountSubscription?.cancel();
        await _pedestrianStatusSubscription?.cancel();
        
        _startListening();
      } else {
        emit(StepsPermissionDenied());
      }
    } catch (e) {
      emit(StepsError('Gagal mengakses sensor: $e'));
    }
  }

  void _startListening() {
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        add(StepsUpdated(event.steps, 'walking'));
      },
      onError: (error) {
        add(const StepsUpdated(0, 'stopped'));
      },
    );

    _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
      (PedestrianStatus event) {
        // Bisa digunakan jika ingin menampilkan status 'Jalan' atau 'Diam'
      },
      onError: (error) {},
    );
  }

  void _onUpdated(StepsUpdated event, Emitter<StepsState> emit) {
    emit(StepsLoaded(steps: event.steps, status: event.status));
  }

  @override
  Future<void> close() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    return super.close();
  }
}
