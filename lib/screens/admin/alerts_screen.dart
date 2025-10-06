import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/main_provider.dart';
import '../../utils/theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertes Système')),
      body: FutureBuilder(
        future: _getSystemAlerts(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final alerts = snapshot.data as List<Map<String, dynamic>>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionTitle('Alertes Critiques'),
              ...alerts.where((a) => a['severity'] == 'critical').map((alert) =>
                _AlertCard(
                  color: _getSeverityColor(alert['severity']),
                  title: alert['title'],
                  subtitle: alert['subtitle'],
                  actions: true,
                )
              ),

              const SizedBox(height: 16),
              _SectionTitle('Avertissements'),
              ...alerts.where((a) => a['severity'] == 'warning').map((alert) =>
                _AlertCard(
                  color: _getSeverityColor(alert['severity']),
                  title: alert['title'],
                  subtitle: alert['subtitle'],
                )
              ),

              const SizedBox(height: 16),
              _SectionTitle('Alertes Résolues'),
              ...alerts.where((a) => a['severity'] == 'resolved').map((alert) =>
                _AlertCard(
                  color: _getSeverityColor(alert['severity']),
                  title: alert['title'],
                  subtitle: alert['subtitle'],
                )
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getSystemAlerts(BuildContext context) async {
    try {
      final mainProvider = Provider.of<MainProvider>(context, listen: false);
      final stats = await mainProvider.getSystemStats();

      final List<Map<String, dynamic>> alerts = [];

      // Check for high booking rates
      if (stats['totalBookings'] > 50) {
        alerts.add({
          'severity': 'warning',
          'title': 'Volume de réservations élevé',
          'subtitle': '${stats['totalBookings']} réservations actives',
        });
      }

      // Check for low agent availability
      if (stats['totalAgents'] < 10) {
        alerts.add({
          'severity': 'critical',
          'title': 'Penurie d\'agents',
          'subtitle': 'Seulement ${stats['totalAgents']} agents disponibles',
        });
      }

      // Check revenue thresholds
      if (stats['totalRevenue'] > 10000) {
        alerts.add({
          'severity': 'warning',
          'title': 'Seuil de revenu dépassé',
          'subtitle': 'Revenus totaux: ${stats['totalRevenue']}€',
        });
      }

      // Add system info as resolved alerts
      alerts.add({
        'severity': 'resolved',
        'title': 'Système opérationnel',
        'subtitle': '${stats['totalUsers']} utilisateurs, ${stats['totalAgents']} agents',
      });

      return alerts;
    } catch (e) {
      return [{
        'severity': 'critical',
        'title': 'Erreur de connexion',
        'subtitle': 'Impossible de récupérer les données système',
      }];
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      case 'resolved':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final bool actions;
  const _AlertCard({required this.color, required this.title, required this.subtitle, this.actions = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.warning_amber_outlined, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color))),
          ]),
          const SizedBox(height: 8),
          Text(subtitle),
          if (actions) ...[
            const SizedBox(height: 12),
            Row(children: [
              OutlinedButton(onPressed: () {}, child: const Text('Rejeter')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
                child: const Text('Enquêter'),
              ),
            ]),
          ]
        ]),
      ),
    );
  }
}

