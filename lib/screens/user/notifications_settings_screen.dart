import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool bookingUpdates = true;
  bool recommendations = true;
  bool promotions = false;
  bool appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SwitchTile(
            title: 'Mises à jour de réservation',
            subtitle: 'Recevez des notifications sur les confirmations, changements et rappels de réservation.',
            value: bookingUpdates,
            onChanged: (v) => setState(() => bookingUpdates = v),
          ),
          _SwitchTile(
            title: 'Nouvelles recommandations d\'agents',
            subtitle: 'Recevez des alertes lorsque de nouveaux agents bien notés sont disponibles.',
            value: recommendations,
            onChanged: (v) => setState(() => recommendations = v),
          ),
          _SwitchTile(
            title: 'Promotions & Offres',
            subtitle: 'Recevez des réductions spéciales et offres promotionnelles.',
            value: promotions,
            onChanged: (v) => setState(() => promotions = v),
          ),
          _SwitchTile(
            title: 'Mises à jour de l\'application',
            subtitle: 'Soyez informé des nouvelles fonctionnalités et améliorations de l\'application.',
            value: appUpdates,
            onChanged: (v) => setState(() => appUpdates = v),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
        value: value,
        onChanged: onChanged,
        secondary: const Icon(Icons.check_circle, color: AppColors.yellow),
      ),
    );
  }
}

