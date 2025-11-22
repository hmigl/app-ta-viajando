import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_viajando_app/features/global/configuration_drawer.dart';
import 'package:ta_viajando_app/features/trips/presentation/add_trip_modal.dart';
import 'package:ta_viajando_app/features/trips/presentation/trips_controller.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tá viajando, é?'),
        centerTitle: false,
      ),
      drawer: const ConfigurationDrawer(),
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(child: Text('Nenhuma viagem planejada ainda.'));
          }
          return ListView.builder(
            itemCount: trips.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.flight_takeoff),
                  title: Text(trip.title),
                  subtitle: Text("${trip.destination} - ${trip.startDate?.day}/${trip.startDate?.month}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ref.read(tripsControllerProvider.notifier).deleteTrip(trip.id);
                    },
                  ),
                  onTap: () {
                    // Futuro: Ir para detalhes (Escopo 2)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Abrir viagem: ${trip.title}')),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
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