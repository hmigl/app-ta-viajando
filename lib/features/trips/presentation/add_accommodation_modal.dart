import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';
import 'package:ta_viajando_app/features/trips/providers/trip_provider.dart';

class AddAccommodationModal extends ConsumerStatefulWidget {
  final String tripId;
  const AddAccommodationModal({super.key, required this.tripId});

  @override
  ConsumerState<AddAccommodationModal> createState() => _AddAccommodationModalState();
}

class _AddAccommodationModalState extends ConsumerState<AddAccommodationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _bookingRefController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isLoading = false;

  Future<void> _selectDate(bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final price = _priceController.text.isNotEmpty 
          ? double.tryParse(_priceController.text.replaceAll(',', '.')) 
          : null;

      await ref.read(tripsRepositoryProvider).addAccommodation(
        tripId: widget.tripId,
        name: _nameController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        bookingReference: _bookingRefController.text.isEmpty ? null : _bookingRefController.text,
        checkIn: _checkIn,
        checkOut: _checkOut,
        price: price,
      );

      // Invalida o provider para atualizar a tela anterior
      ref.invalidate(tripDetailsProvider(widget.tripId));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospedagem adicionada!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Adicionar Hospedagem', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Hotel / Local *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Endereço', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined)),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.login),
                      label: Text(_checkIn == null ? 'Check-in' : DateFormat('dd/MM/yy').format(_checkIn!)),
                      onPressed: () => _selectDate(true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: Text(_checkOut == null ? 'Check-out' : DateFormat('dd/MM/yy').format(_checkOut!)),
                      onPressed: () => _selectDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bookingRefController,
                      decoration: const InputDecoration(labelText: 'Cód. Reserva', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Preço Total', prefixText: 'R\$ ', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Salvar Hospedagem'),
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