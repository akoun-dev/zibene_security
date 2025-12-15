import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/theme.dart';
import 'package:intl/intl.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startTime = DateTime.now().add(const Duration(days: 1));
  DateTime _endTime = DateTime.now().add(const Duration(days: 1, hours: 4));
  String _selectedServiceType = 'Protection rapprochée';
  double _cost = 0.0;

  final List<String> _serviceTypes = [
    'Protection rapprochée',
    'Sécurité événementielle',
    'Surveillance résidentielle',
    'Transport de valeurs',
    'Sécurité corporate',
    'Gestion des accès',
    'Protection de site',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _calculateCost();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateCost() {
    final duration = _endTime.difference(_startTime).inHours;
    final hourlyRate = _getHourlyRateForService(_selectedServiceType);
    setState(() {
      _cost = duration * hourlyRate;
    });
  }

  double _getHourlyRateForService(String serviceType) {
    final rates = {
      'Protection rapprochée': 75.0,
      'Sécurité événementielle': 50.0,
      'Surveillance résidentielle': 40.0,
      'Transport de valeurs': 80.0,
      'Sécurité corporate': 65.0,
      'Gestion des accès': 45.0,
      'Protection de site': 55.0,
      'Autre': 60.0,
    };
    return rates[serviceType] ?? 60.0;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.utilisateurActuel;
    final clientId = currentUser?.id ?? FirebaseService.currentUserId;
    final roleName = currentUser?.role.name ?? 'client';

    if (clientId == null || clientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de créer la réservation : utilisateur non authentifié'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Création de la réservation...'),
            ],
          ),
        ),
      );

      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.createBooking(
        clientId: clientId,
        agentId: 'agent_default',
        startTime: _startTime,
        endTime: _endTime,
        location: _locationController.text.trim(),
        serviceType: _selectedServiceType,
        cost: _cost,
        notes: _notesController.text.trim(),
      );
      await bookingProvider.fetchUserBookings(clientId, roleName);

      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer le dialogue de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation créée avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(); // Retour à l'écran précédent
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer le dialogue de chargement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la réservation: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver un service'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type de service
              const Text('Type de service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: _serviceTypes.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedServiceType = value!;
                    _calculateCost();
                  });
                },
                validator: (value) => value == null ? 'Veuillez sélectionner un service' : null,
              ),
              const SizedBox(height: 20),

              // Date et heure de début
              const Text('Date et heure de début', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                title: Text('Début: ${DateFormat('dd MMM yyyy HH:mm').format(_startTime)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_startTime),
                    );
                    if (time != null) {
                      setState(() {
                        _startTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                        // Assurer que l'heure de fin est après l'heure de début
                        if (_endTime.isBefore(_startTime)) {
                          _endTime = _startTime.add(const Duration(hours: 4));
                        }
                        _calculateCost();
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              // Date et heure de fin
              const Text('Date et heure de fin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                title: Text('Fin: ${DateFormat('dd MMM yyyy HH:mm').format(_endTime)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endTime,
                    firstDate: _startTime,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_endTime),
                    );
                    if (time != null) {
                      setState(() {
                        _endTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                        _calculateCost();
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              // Lieu
              const Text('Lieu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Adresse complète',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Notes
              const Text('Notes (optionnel)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Informations supplémentaires...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Coût estimé
              Card(
                color: AppColors.yellow.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, color: AppColors.yellow),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Coût estimé', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${_cost.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 18, color: AppColors.yellow)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitBooking,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirmer la réservation'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.yellow,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
