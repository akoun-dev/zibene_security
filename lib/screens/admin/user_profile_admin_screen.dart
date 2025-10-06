import 'package:flutter/material.dart';
import '../../models/user_unified.dart';
import '../../utils/theme.dart';
import 'user_form_screen.dart';

class UserProfileAdminScreen extends StatefulWidget {
  final User user;
  const UserProfileAdminScreen({super.key, required this.user});

  @override
  State<UserProfileAdminScreen> createState() => _UserProfileAdminScreenState();
}

class _UserProfileAdminScreenState extends State<UserProfileAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil utilisateur')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(radius: 36, child: Text(widget.user.name.substring(0, 1))),
          ),
          const SizedBox(height: 8),
          Center(child: Text(widget.user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Center(
            child: Text(
              widget.user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 10, color: widget.user.isActive ? AppColors.success : AppColors.danger),
                const SizedBox(width: 6),
                Text(
                  widget.user.isActive ? 'Actif' : 'Inactif',
                  style: TextStyle(color: widget.user.isActive ? AppColors.success : AppColors.danger)
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(children: const [
            Expanded(child: _Metric(title: 'Réservations totales', value: '0')),
            SizedBox(width: 12),
            Expanded(child: _Metric(title: 'Réservations actives', value: '0')),
          ]),
          const SizedBox(height: 16),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historique des réservations'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _viewBookingHistory(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Modifier le profil'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editProfile(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Envoyer un message'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _sendMessage(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                title: Text(widget.user.isActive ? 'Désactiver l\'utilisateur' : 'Réactiver l\'utilisateur',
                    style: const TextStyle(color: AppColors.danger)),
                onTap: () => _confirmToggleActive(context),
              ),
            ]),
          )
        ],
      ),
    );
  }

  void _viewBookingHistory() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Historique des réservations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Text('Aucune réservation trouvée'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserFormScreen(user: widget.user),
      ),
    );
    if (result != null && mounted) {
      // In a real app, update the user data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
    }
  }

  void _sendMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Envoyer un message à ${widget.user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Tapez votre message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message envoyé avec succès')),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _confirmToggleActive(BuildContext context) async {
    final action = widget.user.isActive ? 'désactiver' : 'réactiver';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${action[0].toUpperCase()}${action.substring(1)} l\'utilisateur'),
        content: Text('Êtes-vous sûr de vouloir $action ${widget.user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action[0].toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      // In a real app, call API here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur $action avec succès')),
      );
      Navigator.pop(context);
    }
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  const _Metric({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
