import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ta_viajando_app/features/trips/providers/trip_provider.dart';

class TripDetailsScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripDetails = ref.watch(tripDetailsProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: tripDetails.when(
          data: (trip) => Text(trip.title),
          loading: () => const Text(''),
          error: (e, s) => const Text('Erro'),
        ),
      ),
      body: tripDetails.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (trip) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                trip.destination,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              if (trip.startDate != null && trip.endDate != null)
                Text(
                  '${DateFormat.yMd().format(trip.startDate!)} - ${DateFormat.yMd().format(trip.endDate!)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 24),
              Text(
                'Participantes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: trip.participants
                    .map((name) => Chip(label: Text(name)))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Checklist de Tarefas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              ...trip.tasks.map((task) {
                return CheckboxListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    ref
                        .read(tripDetailsProvider(tripId).notifier)
                        .toggleTaskStatus(task.id);
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
