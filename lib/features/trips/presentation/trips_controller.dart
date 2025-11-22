import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';
import 'package:ta_viajando_app/features/trips/domain/trip.dart';

part 'trips_controller.g.dart';

@riverpod
class TripsController extends _$TripsController {
  @override
  FutureOr<List<Trip>> build() async {
    // Ao iniciar, busca os dados no repositório
    return ref.read(tripsRepositoryProvider).getTrips();
  }

  Future<void> addTrip({
    required String title,
    required String destination,
    required DateTime startDate,
  }) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final newTrip = await ref.read(tripsRepositoryProvider).addTrip(
            title: title,
            destination: destination,
            startDate: startDate,
          );
      
      final currentList = state.value ?? [];
      return [...currentList, newTrip];
    });
  }

  Future<void> deleteTrip(String id) async {
    final previousState = state;
    
    state = AsyncValue.data(
      state.value?.where((t) => t.id != id).toList() ?? [],
    );

    try {
      await ref.read(tripsRepositoryProvider).deleteTrip(id);
    } catch (e) {
      // Se der erro no banco, volta o estado anterior
      state = previousState;
      throw e;
    }
  }
}
