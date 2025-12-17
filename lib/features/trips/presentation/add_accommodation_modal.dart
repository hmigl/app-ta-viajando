import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ta_viajando_app/features/trips/data/trips_repository.dart';
import 'package:ta_viajando_app/features/trips/domain/accommodation.dart';
import 'package:ta_viajando_app/features/trips/providers/trip_provider.dart';

class AddAccommodationModal extends ConsumerStatefulWidget {
  final String tripId;
  final Accommodation? accommodation; // Parâmetro opcional para edição

  const AddAccommodationModal({
    super.key, 
    required this.tripId, 
    this.accommodation,
  });

  @override
  ConsumerState<AddAccommodationModal> createState() => _AddAccommodationModalState();
}

class _AddAccommodationModalState extends ConsumerState<AddAccommodationModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _bookingRefController;
  late TextEditingController _priceController;

  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.accommodation?.name ?? '');
    _addressController = TextEditingController(text: widget.accommodation?.address ?? '');
    _bookingRefController = TextEditingController(text: widget.accommodation?.bookingReference ?? '');
    _priceController = TextEditingController(
      text: widget.accommodation?.priceTotal?.toStringAsFixed(2) ?? ''
    );
    _checkIn = widget.accommodation?.checkInDate;
    _checkOut = widget.accommodation?.checkOutDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _bookingRefController.dispose();
    _priceController.dispose();
    super.dispose();
  }


  Future<void> _selectDate(bool isCheckIn) async {
    final tripAsync = ref.read(tripDetailsProvider(widget.tripId));
    DateTime? tripStart;
    DateTime? tripEnd;
    tripAsync.when(
      data: (trip) {
        tripStart = trip.startDate;
        tripEnd = trip.endDate;
      },
      loading: () {
      },
      error: (_, __) {
      },
    );
    final DateTime defaultFirstDate = DateTime(2020);
    final DateTime defaultLastDate = DateTime(2030);
    final DateTime firstDate = tripStart ?? defaultFirstDate;
    final DateTime lastDate = tripEnd ?? defaultLastDate;
    DateTime initialDate = DateTime.now();
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    } else if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
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

      if (widget.accommodation != null) {
        await ref.read(tripsRepositoryProvider).updateAccommodation(
          accommodationId: widget.accommodation!.id,
          name: _nameController.text,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          bookingReference: _bookingRefController.text.isEmpty ? null : _bookingRefController.text,
          checkIn: _checkIn,
          checkOut: _checkOut,
          price: price,
        );
      } else {
        await ref.read(tripsRepositoryProvider).addAccommodation(
          tripId: widget.tripId,
          name: _nameController.text,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          bookingReference: _bookingRefController.text.isEmpty ? null : _bookingRefController.text,
          checkIn: _checkIn,
          checkOut: _checkOut,
          price: price,
        );
      }

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