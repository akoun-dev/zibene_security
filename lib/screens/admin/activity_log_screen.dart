import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const <_Item>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Journal d\'activité')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: const [
            _Filter('Type d\'action'),
            _Filter('Date'),
            _Filter('Administrateur'),
          ]),
          const SizedBox(height: 16),
          const Text('Activité récente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map((e) => Card(
                child: ListTile(
                  title: Text(e.title),
                  subtitle: Text(e.subtitle),
                  trailing: Text(e.time, style: const TextStyle(color: AppColors.textSecondary)),
                ),
              )),
        ],
      ),
    );
  }
}

class _Filter extends StatelessWidget {
  final String label;
  const _Filter(this.label);
  @override
  Widget build(BuildContext context) {
    return InputChip(label: Text(label), onPressed: () {});
  }
}

class _Item {
  final String title;
  final String subtitle;
  final String time;
  const _Item(this.title, this.subtitle, this.time);
}
