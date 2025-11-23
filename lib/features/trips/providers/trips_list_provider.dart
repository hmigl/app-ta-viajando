import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/trip.dart';

final tripsListProvider = FutureProvider<List<Trip>>((ref) async {
  // No futuro, você buscará a lista de viagens do Supabase aqui.
  // Por enquanto, retornamos uma lista de exemplo.
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    const Trip(
      id: 'trip-01',
      title: 'Fim de semana no Rio',
      destination: 'Rio de Janeiro, RJ',
      ownerId: 'user-123',
    ),
    const Trip(
      id: 'trip-02',
      title: 'Feriado em São Paulo',
      destination: 'São Paulo, SP',
      ownerId: 'user-123',
    ),
    const Trip(
      id: 'trip-03',
      title: 'Férias na Bahia',
      destination: 'Salvador, BA',
      ownerId: 'user-123',
    ),
  ];
});
