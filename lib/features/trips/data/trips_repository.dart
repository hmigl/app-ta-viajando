import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_viajando_app/core/services/supabase_provider.dart';
import 'package:ta_viajando_app/features/trips/domain/trip.dart';
import 'dart:typed_data';

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

  Future<String?> uploadCoverImage(Uint8List imageBytes) async {
    //trazer o try catch dnv, para ver qual erro ta dando
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'covers/$fileName';
    
    await _supabase.storage.from('trip_covers').uploadBinary(
      path,
      imageBytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false, contentType: 'image/jpeg'),
    );

    return _supabase.storage.from('trip_covers').getPublicUrl(path);
    
  }

  Future<void> updateTripImage(String tripId, String newImageUrl) async {
    await _supabase.from('trips').update({
      'image_url': newImageUrl
    }).eq('id', tripId);
  }

  Future<void> addTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime? endDate,
    String? imageUrl,
    double? latitude,  
    double? longitude, 
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('trips').insert({
      'title': title,
      'destination': destination,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'owner_id': userId,
      'image_url': imageUrl, 
      'latitude': latitude,   
      'longitude': longitude, 
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
              accommodations (*),
              trip_participants (
                profiles (id, full_name, email, avatar_url) 
              )
            ''').eq('id', tripId).single();
            
            final List<dynamic> rawParticipants = response['trip_participants'] ?? [];
            
            final List<Map<String, dynamic>> formattedParticipants = rawParticipants.map((item) {
              final profile = item['profiles'];
              if (profile == null) return null;
              
              return {
                'name': profile['full_name'] ?? 'Sem Nome',
                'email': profile['email'] ?? '',
                'id': profile['id'],
                'avatar_url': profile['avatar_url'],
              };
            }).whereType<Map<String, dynamic>>().toList(); // Remove nulos

            final Map<String, dynamic> data = Map<String, dynamic>.from(response);
            data['participants'] = formattedParticipants;
            
            return Trip.fromJson(data);
        });
  }

  Future<void> addAccommodation({
    required String tripId,
    required String name,
    String? address,
    DateTime? checkIn,
    DateTime? checkOut,
    String? bookingReference,
    double? price,
  }) async {
    await _supabase.from('accommodations').insert({
      'trip_id': tripId,
      'name': name,
      'address': address,
      'check_in_date': checkIn?.toIso8601String(),
      'check_out_date': checkOut?.toIso8601String(),
      'booking_reference': bookingReference,
      'price_total': price,
    });
  }

  Future<void> deleteAccommodation(String accommodationId) async {
    await _supabase.from('accommodations').delete().eq('id', accommodationId);
  }

  Future<void> updateAccommodation({
    required String accommodationId,
    required String name,
    String? address,
    DateTime? checkIn,
    DateTime? checkOut,
    String? bookingReference,
    double? price,
  }) async {
    await _supabase.from('accommodations').update({
      'name': name,
      'address': address,
      'check_in_date': checkIn?.toIso8601String(),
      'check_out_date': checkOut?.toIso8601String(),
      'booking_reference': bookingReference,
      'price_total': price,
    }).eq('id', accommodationId);
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