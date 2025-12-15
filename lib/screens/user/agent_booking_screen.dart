import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/agent_simple.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class AgentBookingScreen extends StatefulWidget {
  final Agent agent;

  const AgentBookingScreen({super.key, required this.agent});

  @override
  State<AgentBookingScreen> createState() => _AgentBookingScreenState();
}

class _AgentBookingScreenState extends State<AgentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startTime = DateTime.now().add(const Duration(days: 1));
  DateTime _endTime = DateTime.now().add(const Duration(days: 1, hours: 4));
  String _selectedService = '';
  double _cost = 0.0;

  final List<String> _services = [
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
    _selectedService = widget.agent.specialtyDisplay;
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
    setState(() {
      _cost = duration * widget.agent.hourlyRate * 655.957; // Conversion euro vers FCFA
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    // Récupérer l'ID utilisateur réel depuis l'AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: Utilisateur non connecté'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
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
        clientId: currentUser.id,
        agentId: widget.agent.id,
        startTime: _startTime,
        endTime: _endTime,
        location: _locationController.text.trim(),
        serviceType: _selectedService,
        cost: _cost,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialogue de chargement

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation créée avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.of(context).pop(); // Retour à l'écran précédent
      }
    } catch (e) {
      if (mounted) {
        // Fermer le dialogue de chargement s'il est ouvert
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la réservation: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réserver ${widget.agent.name}'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte de l'agent
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: widget.agent.photo.isNotEmpty
                            ? NetworkImage(widget.agent.photo)
                            : null,
                        child: widget.agent.photo.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                      Text(
                        widget.agent.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.agent.specialtyDisplay,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Type de service
              const Text(
                'Type de service',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedService,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: _services.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedService = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Date et heure de début
              const Text(
                'Date et heure de début',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('dd MMM yyyy HH:mm').format(_startTime)),
                trailing: const Icon(Icons.chevron_right),
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
              const Text(
                'Date et heure de fin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('dd MMM yyyy HH:mm').format(_endTime)),
                trailing: const Icon(Icons.chevron_right),
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
              const Text(
                'Lieu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
              const Text(
                'Notes (optionnel)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
                            const Text(
                              'Détails',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Le tarif sera communiqué après validation.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
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
                  label: Text('Confirmer la réservation avec ${widget.agent.name}'),
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
