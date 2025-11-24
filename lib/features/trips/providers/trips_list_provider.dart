import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';
import '../domain/trip.dart';

final tripsListProvider = StreamProvider<List<Trip>>((ref) {
  final repository = ref.watch(tripsRepositoryProvider);
  return repository.getTripsStream();
});