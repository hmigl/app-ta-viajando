import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding para o teclado não cobrir os campos
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nova Viagem',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título da Viagem'),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _destController,
              decoration: const InputDecoration(labelText: 'Destino'),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Data: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      initialDate: _selectedDate,
                    );
                    if (d != null) setState(() => _selectedDate = d);
                  },
                  child: const Text('Alterar Data'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Chama o Controller
                  ref
                      .read(tripsControllerProvider.notifier)
                      .addTrip(
                        title: _titleController.text,
                        destination: _destController.text,
                        startDate: _selectedDate,
                      );
                  Navigator.of(context).pop(); // Fecha o modal
                }
              },
              child: const Text('Criar Viagem'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
