import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_viajando_app/features/trips/providers/trips_list_provider.dart';
import 'package:ta_viajando_app/features/trips/screens/trip_details_screen.dart';

class TripsListScreen extends ConsumerWidget {
  const TripsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Viagens'),
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(
              child: Text('Nenhuma viagem encontrada.'),
            );
          }
          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return ListTile(
                title: Text(trip.title),
                subtitle: Text(trip.destination),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailsScreen(tripId: trip.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
