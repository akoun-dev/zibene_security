import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class RolesPermissionsScreen extends StatelessWidget {
  const RolesPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roles & Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Rôles d\'administrateur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _RoleCard(
            title: 'Super Administrateur',
            description: 'Accès complet à toutes les fonctionnalités et paramètres du système.',
            chips: const ['Toutes les permissions'],
          ),
          _RoleCard(
            title: 'Gestionnaire de réservations',
            description: 'Gère les réservations des clients et les affectations de gardes du corps.',
            chips: const ['Gérer les réservations', 'Voir les clients', 'Voir les gardes du corps'],
          ),
          _RoleCard(
            title: 'Gestionnaire d\'utilisateurs',
            description: 'Gère les comptes utilisateurs des gardes du corps et des clients.',
            chips: const ['Gérer les utilisateurs', 'Vérifier les comptes'],
          ),
          const SizedBox(height: 16),
          const Text('Utilisateurs admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.admin_panel_settings)),
              title: Text('Aucun utilisateur admin configuré'),
              subtitle: Text('Ajoutez des utilisateurs admin pour gérer le système'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> chips;
  const _RoleCard({required this.title, required this.description, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in chips)
              Chip(
                label: Text(c),
                backgroundColor: const Color(0xFF1E2A38),
              )
          ]),
        ]),
      ),
    );
  }
}

