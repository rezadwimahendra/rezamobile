import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../data/models/weight_model.dart';
import './weight_bloc_state.dart';

class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final PocketBase pb;

  WeightBloc({required this.pb}) : super(WeightInitial()) {
    on<LatestWeightFetched>((event, emit) async {
      emit(WeightLoading());
      try {
        print('DEBUG: [Mencoba ambil data terbaru tanpa filter untuk tes]');
        
        final records = await pb.collection('weights').getList(
          page: 1,
          perPage: 1,
          sort: '-created', // Ambil yang paling baru dibuat
          filter: 'user = "${event.userId}"',
        );

        if (records.items.isNotEmpty) {
          final firstRecord = records.items.first;
          print('DEBUG: Data ditemukan! ID: ${firstRecord.id}, Nilai: ${firstRecord.data['weights']}');
          
          final model = WeightModel.fromRecord(firstRecord);
          emit(WeightLoaded(model));
        } else {
          print('DEBUG: Database benar-benar kosong.');
          emit(const WeightLoaded(null));
        }
      } catch (e) {
        print('DEBUG: ERROR: $e');
        emit(WeightError(e.toString()));
      }
    });
  }
}
