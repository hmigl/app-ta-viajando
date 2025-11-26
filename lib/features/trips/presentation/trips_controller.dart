import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';
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
    Uint8List? coverImageBytes, // <--- Recebe o arquivo físico
  }) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      String? uploadedUrl;
      
      // Se o usuário selecionou foto, faz upload primeiro
      if (coverImageBytes != null) {
        uploadedUrl = await ref.read(tripsRepositoryProvider).uploadCoverImage(coverImageBytes);
      }

      // Cria a viagem passando a URL (ou null se não tiver foto)
      await ref.read(tripsRepositoryProvider).addTrip(
        title: title,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        imageUrl: uploadedUrl,
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