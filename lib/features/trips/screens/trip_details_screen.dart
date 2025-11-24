import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';
import 'package:ta_viajando_app/features/trips/providers/trip_provider.dart';

class TripDetailsScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailsScreen({super.key, required this.tripId});


  void _showAddParticipantDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convidar Amigo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Email do usuário',
            hintText: 'exemplo@email.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  Navigator.pop(context); // Fecha antes para evitar travamento visual
                  await ref.read(tripsRepositoryProvider).addParticipantByEmail(
                    tripId, 
                    controller.text.trim()
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Convite enviado!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro: ${e.toString().replaceAll("Exception:", "")}'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text('Convidar'),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog(BuildContext context, WidgetRef ref, {String? taskId, String? currentTitle}) {
    final controller = TextEditingController(text: currentTitle);
    final isEditing = taskId != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Ex: Comprar protetor solar'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                if (isEditing) {
                  ref.read(tripsRepositoryProvider).updateTaskTitle(taskId, controller.text);
                } else {
                  ref.read(tripsRepositoryProvider).addTask(tripId, controller.text);
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Salvar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTask(BuildContext context, WidgetRef ref, String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(tripsRepositoryProvider).deleteTask(taskId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripDetails = ref.watch(tripDetailsProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: tripDetails.when(
          data: (trip) => Text(trip.title),
          loading: () => const Text(''),
          error: (_, __) => const Text('Detalhes'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context, ref),
        child: const Icon(Icons.add_task),
      ),
      body: tripDetails.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar: $err')),
        data: (trip) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(tripDetailsProvider(tripId)),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(trip.destination, style: Theme.of(context).textTheme.headlineMedium),
                if (trip.startDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${DateFormat('dd/MM').format(trip.startDate!)} - ${trip.endDate != null ? DateFormat('dd/MM/yyyy').format(trip.endDate!) : '?'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Participantes', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1, color: Colors.blue),
                      onPressed: () => _showAddParticipantDialog(context, ref),
                      tooltip: "Adicionar participante",
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ...trip.participants.map((name) => Chip(
                          avatar: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 12)),
                          ),
                          label: Text(name),
                        )),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Checklist', style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      '${trip.tasks.where((t) => t.isCompleted).length}/${trip.tasks.length}',
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(),
                
                if (trip.tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.checklist_rtl, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Nenhuma tarefa ainda.'),
                        ],
                      ),
                    ),
                  ),

                ...trip.tasks.map((task) {
                  return Dismissible(
                    key: Key(task.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      _confirmDeleteTask(context, ref, task.id);
                      return false; 
                    },
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          ref.read(tripsRepositoryProvider).toggleTask(task.id, value!);
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          color: task.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      onLongPress: () => _showTaskDialog(context, ref, taskId: task.id, currentTitle: task.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                        onPressed: () => _confirmDeleteTask(context, ref, task.id),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}