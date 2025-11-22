import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_viajando_app/core/services/supabase_provider.dart';
import 'package:ta_viajando_app/features/trips/domain/trip.dart';

// provider manual, sem codegen
final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return TripsRepository(supabase);
});

class TripsRepository {
  final SupabaseClient _supabase;

  TripsRepository(this._supabase);

  Future<List<Trip>> getTrips() async {
    final data = await _supabase
        .from('trips')
        .select()
        .order('start_date', ascending: true);

    return (data as List).map((e) => Trip.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<Trip> addTrip({
    required String title,
    required String destination,
    required DateTime startDate,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase.from('trips').insert({
      'title': title,
      'destination': destination,
      'start_date': startDate.toIso8601String(),
      'owner_id': userId,
    }).select().single();

    return Trip.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> deleteTrip(String id) async {
    await _supabase.from('trips').delete().eq('id', id);
  }
}
