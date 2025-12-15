import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/agent_name_service.dart';
import '../../utils/theme.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  String? _agentName;

  @override
  void initState() {
    super.initState();
    _loadAgentName();
  }

  Future<void> _loadAgentName() async {
    final name = await AgentNameService.getAgentNameWithFallback(widget.booking.agentId);
    if (mounted) {
      setState(() {
        _agentName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la réservation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.yellow.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: AppColors.yellow),
              ),
              title: Text(_agentName ?? 'Chargement...'),
              subtitle: Text(
                widget.booking.agent != null && widget.booking.agent!.matricule.isNotEmpty
                    ? 'Matricule: ${widget.booking.agent!.matricule}'
                    : 'ID agent: ${widget.booking.agentId}',
              ),
              trailing: _StatusChip(status: widget.booking.status),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Détails de la réservation', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _Row('Début', _formatDateTime(widget.booking.startTime)),
                  _Row('Fin', _formatDateTime(widget.booking.endTime)),
                  _Row('Lieu', widget.booking.location),
                  _Row('Service', widget.booking.serviceType),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Chronologie', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _TimelineItem(label: 'Créé', time: 'Il y a 2 jours', done: true),
                _TimelineItem(label: 'Confirmé', time: 'Il y a 1 jour', done: true),
                _TimelineItem(label: 'En cours', time: 'Demain 22:00', done: false),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Annuler la réservation'))),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité désactivée')),
                  );
                },
                child: const Text('Contacter le support'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité désactivée')),
              );
            },
            child: const Text('Évaluer et commenter'),
          )
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case BookingStatus.pending:
        color = AppColors.warning; text = 'Pending'; break;
      case BookingStatus.confirmed:
        color = AppColors.success; text = 'Confirmed'; break;
      case BookingStatus.inProgress:
        color = AppColors.info; text = 'In Progress'; break;
      case BookingStatus.completed:
        color = AppColors.success; text = 'Completed'; break;
      case BookingStatus.cancelled:
        color = AppColors.danger; text = 'Cancelled'; break;
      case BookingStatus.rejected:
        color = AppColors.danger; text = 'Rejected'; break;
    }
    return Chip(label: Text(text), backgroundColor: color.withValues(alpha: 0.2), labelStyle: TextStyle(color: color));
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ]),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label; final String time; final bool done;
  const _TimelineItem({required this.label, required this.time, this.done = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(children: [
        Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? AppColors.success : AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(time, style: const TextStyle(color: AppColors.textSecondary)),
      ]),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
