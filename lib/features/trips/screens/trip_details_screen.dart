import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';
import 'package:ta_viajando_app/features/trips/domain/trip.dart';
import 'package:ta_viajando_app/features/trips/presentation/trips_controller.dart';
import 'package:ta_viajando_app/features/trips/providers/trip_provider.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  Trip? _localTrip;

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  Navigator.pop(context);
                  await ref
                      .read(tripsRepositoryProvider)
                      .addParticipantByEmail(
                        widget.tripId,
                        controller.text.trim(),
                      );
                  ref.invalidate(tripDetailsProvider(widget.tripId));
                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Convite enviado!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erro: ${e.toString().replaceAll("Exception:", "")}',
                        ),
                        backgroundColor: Colors.red,
                      ),
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

  void _showTaskDialog(
    BuildContext context,
    WidgetRef ref, {
    String? taskId,
    String? currentTitle,
  }) {
    final controller = TextEditingController(text: currentTitle);
    final isEditing = taskId != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ex: Comprar protetor solar',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  if (isEditing) {
                    await ref
                        .read(tripsRepositoryProvider)
                        .updateTaskTitle(taskId, controller.text);
                  } else {
                    await ref
                        .read(tripsRepositoryProvider)
                        .addTask(widget.tripId, controller.text);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing ? 'Tarefa Atualizada!' : 'Tarefa criada!',
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erro: ${e.toString().replaceAll("Exception:", "")}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tripsRepositoryProvider).deleteTask(taskId);
              ref.invalidate(tripDetailsProvider(widget.tripId));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndEditImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      ref
          .read(tripsControllerProvider.notifier)
          .updateImage(widget.tripId, bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atualizando capa... aguarde.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripDetails = ref.watch(tripDetailsProvider(widget.tripId));
    final controllerState = ref.watch(tripsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context, ref),
        child: const Icon(Icons.add_task),
      ),
      body: tripDetails.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar: $err')),
        data: (tripFromProvider) {
          _localTrip ??= tripFromProvider;
          final currentTrip = _localTrip!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _localTrip = null);
              ref.invalidate(tripDetailsProvider(widget.tripId));
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Stack(
                  children: [
                    // A Imagem de Fundo
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade800,
                        image: currentTrip.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(currentTrip.imageUrl!),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken,
                                ),
                              )
                            : null,
                      ),
                      child: currentTrip.imageUrl == null
                          ? const Center(
                              child: Icon(
                                Icons.flight_takeoff,
                                size: 60,
                                color: Colors.white24,
                              ),
                            )
                          : null,
                    ),
                    // O Conteúdo sobre a imagem (Título e Datas)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrip.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black45, blurRadius: 10),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currentTrip.destination,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 40, // Espaço da StatusBar
                      right: 16,
                      child: controllerState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : IconButton(
                              onPressed: () => _pickAndEditImage(context, ref),
                              icon: const CircleAvatar(
                                backgroundColor: Colors.black45,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              tooltip: 'Alterar Capa',
                            ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Data
                      if (currentTrip.startDate != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(currentTrip.startDate!)} até ${currentTrip.endDate != null ? DateFormat('dd/MM/yyyy').format(currentTrip.endDate!) : '?'}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Participantes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.person_add_alt_1,
                              color: Colors.blue,
                            ),
                            onPressed: () =>
                                _showAddParticipantDialog(context, ref),
                            tooltip: "Adicionar participante",
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ...currentTrip.participants.map(
                            (name) => Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              label: Text(name),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Checklist',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${currentTrip.tasks.where((t) => t.isCompleted).length}/${currentTrip.tasks.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),

                      if (currentTrip.tasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.checklist_rtl,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text('Nenhuma tarefa ainda.'),
                              ],
                            ),
                          ),
                        ),

                      ...currentTrip.tasks.map((task) {
                        return Dismissible(
                          key: Key(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            _confirmDeleteTask(context, ref, task.id);
                            return false;
                          },
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (bool? value) {
                                if (value == null) return;

                                setState(() {
                                  final newTasks = currentTrip.tasks.map((t) {
                                    if (t.id == task.id) {
                                      return t.copyWith(isCompleted: value);
                                    }
                                    return t;
                                  }).toList();
                                  _localTrip = currentTrip.copyWith(
                                    tasks: newTasks,
                                  );
                                });

                                ref
                                    .read(tripsRepositoryProvider)
                                    .toggleTask(task.id, value);
                              },
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.isCompleted ? Colors.grey : null,
                              ),
                            ),
                            onLongPress: () => _showTaskDialog(
                              context,
                              ref,
                              taskId: task.id,
                              currentTitle: task.title,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  _confirmDeleteTask(context, ref, task.id),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
