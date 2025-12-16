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
                  // 1. Fecha o diálogo primeiro para UX fluida
                  Navigator.pop(context); 
                  
                  // 2. Mostra loading visual
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Enviando convite...')),
                    );
                  }

                  // 3. Adiciona no banco
                  await ref.read(tripsRepositoryProvider).addParticipantByEmail(
                        tripId,
                        controller.text.trim(),
                      );
                  
                  // 4. FORÇA A ATUALIZAÇÃO DA TELA
                  ref.invalidate(tripDetailsProvider(tripId));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Participante adicionado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context); // Fecha diálogo

                if (isEditing) {
                  await ref
                      .read(tripsRepositoryProvider)
                      .updateTaskTitle(taskId, controller.text);
                } else {
                  await ref
                      .read(tripsRepositoryProvider)
                      .addTask(tripId, controller.text);
                }
                
                // FORÇA A ATUALIZAÇÃO DA TELA PARA A TAREFA APARECER
                ref.invalidate(tripDetailsProvider(tripId));
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
            onPressed: () async {
              Navigator.pop(context); // Fecha diálogo
              await ref.read(tripsRepositoryProvider).deleteTask(taskId);
              // FORÇA ATUALIZAÇÃO PARA SUMIR DA LISTA
              ref.invalidate(tripDetailsProvider(tripId));
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
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atualizando capa... aguarde.')),
        );
      }

      await ref.read(tripsControllerProvider.notifier).updateImage(tripId, bytes);
      
      // Força refresh para mostrar a nova imagem
      ref.invalidate(tripDetailsProvider(tripId));
    }
  }

  // --- UI ---

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripDetails = ref.watch(tripDetailsProvider(tripId));
    final controllerState = ref.watch(tripsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''), 
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.white), 
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
            // Permite puxar pra baixo para atualizar manualmente também
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
                                  Colors.black.withValues(alpha: 0.3),
                                  BlendMode.darken,
                                ),
                              )
                            : null,
                      ),
                      child: trip.imageUrl == null
                          ? const Center(
                              child: Icon(Icons.flight_takeoff,
                                  size: 60, color: Colors.white24))
                          : null,
                    ),
                    // O Conteúdo sobre a imagem
                    Positioned(
                      bottom: 20, left: 20, right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(trip.destination, style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 40, right: 16,
                      child: controllerState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : IconButton(
                              onPressed: () => _pickAndEditImage(context, ref),
                              icon: const CircleAvatar(
                                backgroundColor: Colors.black45,
                                child: Icon(Icons.edit, color: Colors.white, size: 20),
                              ),
                              tooltip: 'Alterar Capa',
                            ),
                    ),
                  ],
                ),

                if (trip.latitude != null && trip.longitude != null) ...[
                  Padding(
                     padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                     child: Text('Localização', style: Theme.of(context).textTheme.titleLarge), 
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(trip.latitude!, trip.longitude!),
                          initialZoom: 13.0,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                        ),
                        children: [
                          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.app'),
                          MarkerLayer(markers: [
                              Marker(
                                point: LatLng(trip.latitude!, trip.longitude!),
                                width: 80, height: 80,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 40, shadows: [Shadow(blurRadius: 10, color: Colors.black54)]),
                              ),
                          ]),
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
                            const Icon(Icons.calendar_month, color: Colors.blue),
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
                          Text('Participantes', style: Theme.of(context).textTheme.titleLarge),
                          IconButton(
                            icon: const Icon(Icons.person_add_alt_1, color: Colors.blue),
                            onPressed: () => _showAddParticipantDialog(context, ref),
                          )
                        ],
                      ),
                      
                      // --- LISTA DE PARTICIPANTES ATUALIZADA ---
                      if (trip.participants.isEmpty)
                         const Padding(
                           padding: EdgeInsets.all(8.0),
                           child: Text("Nenhum participante além de você.", style: TextStyle(color: Colors.grey)),
                         )
                      else
                        ...trip.participants.map((pString) {
                          // Tentamos quebrar a string "Nome (email)" que criamos no repository
                          // Se não der, mostra a string inteira
                          final parts = pString.split(' (');
                          final name = parts[0];
                          final email = parts.length > 1 ? parts[1].replaceAll(')', '') : '';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(color: Colors.blue.shade800)),
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: email.isNotEmpty ? Text(email) : null,
                            ),
                          );
                        }),
                      // ------------------------------------------

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
                              onChanged: (bool? value) async {
                                await ref.read(tripsRepositoryProvider).toggleTask(task.id, value!);
                                // Atualiza a barra de progresso
                                ref.invalidate(tripDetailsProvider(tripId));
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}