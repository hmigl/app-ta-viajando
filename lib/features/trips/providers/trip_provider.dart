import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/task.dart';
import '../domain/trip.dart';

part 'trip_provider.g.dart';

@riverpod
class TripDetails extends _$TripDetails {
  @override
  Future<Trip> build(String tripId) async {
    // Mantendo os dados de exemplo por enquanto.
    await Future.delayed(const Duration(seconds: 1));
    return Trip(
      id: tripId,
      title: 'Viagem para a Praia',
      destination: 'Praia de Copacabana, RJ', // Corrigido de 'location' para 'destination'
      ownerId: 'user-123', // Adicionado ownerId obrigatório
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 37)),
      participants: ['Você', 'Amigo 1', 'Amigo 2'],
      tasks: [
        const Task(id: '1', title: 'Comprar passagens aéreas', isCompleted: false),
        const Task(id: '2', title: 'Reservar hotel', isCompleted: true),
        const Task(id: '3', title: 'Alugar um carro', isCompleted: false),
        const Task(id: '4', title: 'Fazer as malas', isCompleted: false),
      ],
    );
  }

  void toggleTaskStatus(String taskId) {
    // Verifica se o estado atual já contém dados
    if (!state.hasValue) return;

    final trip = state.value!;
    final newTasks = trip.tasks.map((task) {
      if (task.id == taskId) {
        // Usa o método copyWith gerado pelo freezed para criar uma nova instância
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    // Atualiza o estado com a nova lista de tarefas
    state = AsyncData(trip.copyWith(tasks: newTasks));
  }
}
