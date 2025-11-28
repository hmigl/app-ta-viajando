import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_viajando_app/features/global/configuration_drawer.dart';
import 'package:ta_viajando_app/features/trips/presentation/add_trip_modal.dart';
import 'package:ta_viajando_app/features/trips/providers/trips_list_provider.dart';
import 'package:ta_viajando_app/features/trips/screens/trip_details_screen.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tá viajando, é?'),
      ),
      drawer: const ConfigurationDrawer(),
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(
              child: Text('Nenhuma viagem encontrada.\nCrie uma nova abaixo!', textAlign: TextAlign.center),
            );
          }
          return ListView.builder(
            itemCount: trips.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: trip.imageUrl != null
                    ? CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(trip.imageUrl!),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(trip.destination[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                      ),
                  title: Text(trip.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${trip.destination} • ${trip.startDate != null ? '${trip.startDate!.day}/${trip.startDate!.month}' : 'Sem data'}",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripDetailsScreen(tripId: trip.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          debugPrint('Erro na Home: $err');
          return Center(child: Text('Erro ao carregar viagens: $err'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddTripModal(),
          );
        },
        label: const Text('Nova Viagem'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}