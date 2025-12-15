import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';
import 'package:ta_viajando_app/core/services/geocoding_service.dart';
import 'dart:typed_data';

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
    Uint8List? coverImageBytes,
  }) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      String? uploadedUrl;
      double? lat;
      double? long;

      // 1. Tenta buscar as coordenadas do destino automaticamente
      final coordinates = await GeocodingService.getCoordinates(destination);
      if (coordinates != null) {
        lat = coordinates.latitude;
        long = coordinates.longitude;
      }
      
      // 2. Faz o upload da imagem (se houver)
      if (coverImageBytes != null) {
        uploadedUrl = await ref.read(tripsRepositoryProvider).uploadCoverImage(coverImageBytes);
      }

      // 3. Salva tudo no banco
      await ref.read(tripsRepositoryProvider).addTrip(
        title: title,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        imageUrl: uploadedUrl,
        latitude: lat,   // <--- Passa pro repo
        longitude: long, // <--- Passa pro repo
      );
    });
  }

  Future<void> updateImage(String tripId, Uint8List newImageBytes) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
     
      final newUrl = await ref.read(tripsRepositoryProvider).uploadCoverImage(newImageBytes);
      
      if (newUrl != null) {
        await ref.read(tripsRepositoryProvider).updateTripImage(tripId, newUrl);
      } else {
        throw Exception("Não foi possível fazer o upload da imagem.");
      }
    });
  }

  Future<void> deleteTrip(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(tripsRepositoryProvider).deleteTrip(id));
  }
}