import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';
import '../domain/trip.dart';

part 'trip_provider.g.dart';

@riverpod
Stream<Trip> tripDetails(Ref ref, String tripId) {
  return ref.watch(tripsRepositoryProvider).getTripDetailsStream(tripId);
}