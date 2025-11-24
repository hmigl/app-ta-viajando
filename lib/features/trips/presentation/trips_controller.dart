import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';

part 'trips_controller.g.dart';

@riverpod
class TripsController extends _$TripsController {
  @override
  FutureOr<void> build() {
  }

  Future<void> addTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(tripsRepositoryProvider).addTrip(
      title: title,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
    ));
  }

  Future<void> deleteTrip(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(tripsRepositoryProvider).deleteTrip(id));
  }
}