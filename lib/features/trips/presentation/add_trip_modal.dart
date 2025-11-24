import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ta_viajando_app/features/trips/presentation/trips_controller.dart';

class AddTripModal extends ConsumerStatefulWidget {
  const AddTripModal({super.key});

  @override
  ConsumerState<AddTripModal> createState() => _AddTripModalState();
}

class _AddTripModalState extends ConsumerState<AddTripModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime? _endDate; // Pode ser nulo se não definido

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Se a data fim for menor que a nova data inicio, reseta ou ajusta
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa o estado do controller para mostrar loading ou erro
    final state = ref.watch(tripsControllerProvider);
    final isLoading = state.isLoading;

    // Escuta mudanças para fechar o modal em caso de sucesso
    ref.listen(tripsControllerProvider, (previous, next) {
      if (!next.isLoading && !next.hasError && next.hasValue) {
        Navigator.of(context).pop(); // Fecha o modal apenas se deu certo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viagem criada com sucesso!'), backgroundColor: Colors.green),
        );
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${next.error}'), backgroundColor: Colors.red),
        );
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nova Viagem', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _destController,
                decoration: const InputDecoration(labelText: 'Destino', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat('dd/MM/yy').format(_startDate)),
                      onPressed: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.event),
                      label: Text(_endDate == null ? 'Fim?' : DateFormat('dd/MM/yy').format(_endDate!)),
                      onPressed: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      ref.read(tripsControllerProvider.notifier).addTrip(
                        title: _titleController.text,
                        destination: _destController.text,
                        startDate: _startDate,
                        endDate: _endDate,
                      );
                    }
                  },
                  child: isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text('Criar Viagem'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}