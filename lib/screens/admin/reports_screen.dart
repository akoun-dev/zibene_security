import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rapports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Type de rapport', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: const [
            _ReportChip(icon: Icons.badge_outlined, label: 'Performance des agents', selected: true),
            _ReportChip(icon: Icons.person_outline, label: 'Activité des utilisateurs'),
            _ReportChip(icon: Icons.trending_up_outlined, label: 'Tendances des réservations'),
            _ReportChip(icon: Icons.payments_outlined, label: 'Financier'),
          ]),
          const SizedBox(height: 24),
          const Text('Plage de dates', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: 'Last 30 Days',
            items: const [
              DropdownMenuItem(value: 'Last 7 Days', child: Text('Derniers 7 jours')),
              DropdownMenuItem(value: 'Last 30 Days', child: Text('Derniers 30 jours')),
              DropdownMenuItem(value: 'Last 90 Days', child: Text('Derniers 90 jours')),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          Row(children: const [
            Expanded(child: _DateField(label: 'Date de début')),
            SizedBox(width: 12),
            Expanded(child: _DateField(label: 'Date de fin')),
          ]),
          const SizedBox(height: 24),
          const Text('Options d\'exportation', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 12, children: [
            OutlinedButton(onPressed: () {}, child: const Text('PDF')),
            OutlinedButton(onPressed: () {}, child: const Text('CSV')),
          ]),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final csv = 'report_type,metric,value\nagent_performance,completed_bookings,0';
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Rapport généré'),
                  content: SingleChildScrollView(child: Text(csv)),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Générer un rapport'),
          )
        ],
      ),
    );
  }
}

class _ReportChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _ReportChip({required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 140,
        maxWidth: 180,
      ),
      height: 80,
      decoration: BoxDecoration(
        color: selected ? AppColors.yellow.withValues(alpha: 0.1) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? AppColors.yellow : const Color(0xFF2E2E2E)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: selected ? AppColors.yellow : Colors.white),
          const Spacer(),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  const _DateField({required this.label});
  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
    );
  }
}
