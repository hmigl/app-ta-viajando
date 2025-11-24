import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_viajando_app/core/services/supabase_provider.dart';
import 'package:ta_viajando_app/features/trips/domain/trip.dart';

final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return TripsRepository(supabase);
});

class TripsRepository {
  final SupabaseClient _supabase;

  TripsRepository(this._supabase);

  Stream<List<Trip>> getTripsStream() {
    try {
      return _supabase
          .from('trips')
          .stream(primaryKey: ['id'])
          .order('start_date', ascending: true)
          .map((data) => data.map((e) => Trip.fromJson(e)).toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> addTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime? endDate,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('trips').insert({
      'title': title,
      'destination': destination,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'owner_id': userId,
    });
  }

  Stream<Trip> getTripDetailsStream(String tripId) {
    return _supabase
        .from('trips')
        .stream(primaryKey: ['id'])
        .eq('id', tripId)
        .asyncMap((event) async {
            if (event.isEmpty) throw Exception('Viagem deletada');
            
            final response = await _supabase.from('trips').select('''
              *,
              tasks (*),
              trip_participants (
                profiles (full_name, email) 
              )
            ''').eq('id', tripId).single();
            
            return Trip.fromJson(response);
        });
  }

  Future<void> addParticipantByEmail(String tripId, String email) async {
    final response = await _supabase
        .from('profiles')
        .select('id')
        .eq('email', email)
        .maybeSingle(); 

    if (response == null) {
      throw Exception('Usuário não encontrado com este email.');
    }

    final userIdToAdd = response['id'];

    await _supabase.from('trip_participants').insert({
      'trip_id': tripId,
      'user_id': userIdToAdd,
      'role': 'member', 
    });
  }

  Future<void> removeParticipant(String tripId, String userId) async {
     await _supabase.from('trip_participants')
       .delete()
       .match({'trip_id': tripId, 'user_id': userId});
  }

  Future<void> addTask(String tripId, String title) async {
    await _supabase.from('tasks').insert({
      'trip_id': tripId,
      'title': title,
      'is_completed': false,
    });
  }

  Future<void> toggleTask(String taskId, bool isCompleted) async {
    await _supabase.from('tasks').update({
      'is_completed': isCompleted
    }).eq('id', taskId);
  }

  Future<void> updateTaskTitle(String taskId, String newTitle) async {
    await _supabase.from('tasks').update({
      'title': newTitle
    }).eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }
  
  Future<void> deleteTrip(String id) async {
    await _supabase.from('trips').delete().eq('id', id);
  }
}