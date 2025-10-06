import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class SystemMonitorScreen extends StatelessWidget {
  const SystemMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moniteur système')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Statut du serveur',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const _MetricCard(title: 'Utilisation CPU', value: '0%', trend: '0%', trendColor: AppColors.success),
          const _MetricCard(title: 'Utilisation mémoire', value: '0%', trend: '0%', trendColor: AppColors.success),
          const _MetricCard(title: 'Latence réseau', value: '0ms', trend: '0ms', trendColor: AppColors.success),
          const SizedBox(height: 16),
          Text(
            'Sessions actives',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const _ListCard(icon: Icons.shield_outlined, title: 'Sessions gardes du corps', value: '0'),
          const _ListCard(icon: Icons.person_outline, title: 'Sessions clients', value: '0'),
          const SizedBox(height: 16),
          Text(
            'Problèmes potentiels',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const _AlertItem(color: AppColors.success, title: 'Système OK', desc: 'Aucun problème détecté'),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final Color trendColor;
  const _MetricCard({required this.title, required this.value, required this.trend, required this.trendColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ]),
            ),
            Text(trend, style: TextStyle(color: trendColor)),
          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _ListCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.yellow),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final Color color;
  final String title;
  final String desc;
  const _AlertItem({required this.color, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.08),
      child: ListTile(
        leading: Icon(Icons.error_outline, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        subtitle: Text(desc),
      ),
    );
  }
}
