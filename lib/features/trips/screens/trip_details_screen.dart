import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';
import 'package:ta_viajando_app/features/trips/presentation/trips_controller.dart'; 
import 'package:ta_viajando_app/features/trips/providers/trip_provider.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';      

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  Navigator.pop(
                      context); // Fecha antes para evitar travamento visual
                  await ref.read(tripsRepositoryProvider).addParticipantByEmail(
                        tripId,
                        controller.text.trim(),
                      );
                  if (context.mounted) {
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
                            'Erro: ${e.toString().replaceAll("Exception:", "")}'),
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

  void _showTaskDialog(BuildContext context, WidgetRef ref,
      {String? taskId, String? currentTitle}) {
    final controller = TextEditingController(text: currentTitle);
    final isEditing = taskId != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'Ex: Comprar protetor solar'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                if (isEditing) {
                  ref
                      .read(tripsRepositoryProvider)
                      .updateTaskTitle(taskId, controller.text);
                } else {
                  ref
                      .read(tripsRepositoryProvider)
                      .addTask(tripId, controller.text);
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
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

  Future<void> _pickAndEditImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      // Chama o controller para atualizar
      ref.read(tripsControllerProvider.notifier).updateImage(tripId, bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atualizando capa... aguarde.')),
        );
      }
    }
  }

  // --- UI ---

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripDetails = ref.watch(tripDetailsProvider(tripId));
    final controllerState = ref.watch(tripsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // Título vazio pois vai estar na capa
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.white), // Seta branca para voltar
      ),
      extendBodyBehindAppBar: true,
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
                        image: trip.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(trip.imageUrl!),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withValues(alpha: 0.3), // Escurece um pouco para ler o texto
                                  BlendMode.darken,
                                ),
                              )
                            : null,
                      ),
                      // Se não tiver imagem, mostra um ícone padrão
                      child: trip.imageUrl == null
                          ? const Center(
                              child: Icon(Icons.flight_takeoff,
                                  size: 60, color: Colors.white24))
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
                            trip.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black45, blurRadius: 10)
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                trip.destination,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // O Botão de Editar Imagem (Canto superior direito)
                    Positioned(
                      top: 40, // Espaço da StatusBar
                      right: 16,
                      child: controllerState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : IconButton(
                              onPressed: () => _pickAndEditImage(context, ref),
                              icon: const CircleAvatar(
                                backgroundColor: Colors.black45,
                                child: Icon(Icons.edit,
                                    color: Colors.white, size: 20),
                              ),
                              tooltip: 'Alterar Capa',
                            ),
                    ),
                  ],
                ),

                if (trip.latitude != null && trip.longitude != null) ...[
                  Padding(
                     padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                     child: Text('Localização', style: Theme.of(context).textTheme.titleLarge), ),
                     Container(
                      margin: const EdgeInsets.all(16),
                      height: 200, // Altura do mapa
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                          ],
                      ),
                      // O Widget do Mapa vem aqui
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(trip.latitude!, trip.longitude!),
                            initialZoom: 13.0,
                            interactionOptions: const InteractionOptions(
                              // Bloqueia rotação para não confundir o usuário, mas permite zoom/pan
                              flags: InteractiveFlag.all & ~InteractiveFlag.rotate, 
                            ),
                        ),
                        children: [
                          TileLayer(
                            // Usa os tiles gratuitos do OpenStreetMap
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app', // Padrão
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(trip.latitude!, trip.longitude!),
                                width: 80,
                                height: 80,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red, 
                                  size: 40,
                                  shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Data
                      if (trip.startDate != null)
                        Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(trip.startDate!)} até ${trip.endDate != null ? DateFormat('dd/MM/yyyy').format(trip.endDate!) : '?'}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Participantes',
                              style: Theme.of(context).textTheme.titleLarge),
                          IconButton(
                            icon: const Icon(Icons.person_add_alt_1,
                                color: Colors.blue),
                            onPressed: () =>
                                _showAddParticipantDialog(context, ref),
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
                                  child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(fontSize: 12)),
                                ),
                                label: Text(name),
                              )),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Checklist',
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            '${trip.tasks.where((t) => t.isCompleted).length}/${trip.tasks.length}',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold),
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
                                Icon(Icons.checklist_rtl,
                                    size: 48, color: Colors.grey),
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
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            _confirmDeleteTask(context, ref, task.id);
                            return false;
                          },
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (bool? value) {
                                ref
                                    .read(tripsRepositoryProvider)
                                    .toggleTask(task.id, value!);
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
                            onLongPress: () => _showTaskDialog(context, ref,
                                taskId: task.id, currentTitle: task.title),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 20, color: Colors.grey),
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