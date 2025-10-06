import 'package:flutter/material.dart';

class NotificationsComposeScreen extends StatefulWidget {
  const NotificationsComposeScreen({super.key});

  @override
  State<NotificationsComposeScreen> createState() => _NotificationsComposeScreenState();
}

class _NotificationsComposeScreenState extends State<NotificationsComposeScreen> {
  String type = 'Promotional';
  String recipients = 'All Users';
  String schedule = 'Send Immediately';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle notification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Titre'),
          const SizedBox(height: 6),
          const TextField(decoration: InputDecoration(hintText: 'ex: Urgent: Mise à jour de sécurité')),
          const SizedBox(height: 12),
          const Text('Message'),
          const SizedBox(height: 6),
          const TextField(maxLines: 5, decoration: InputDecoration(hintText: 'Rédigez votre message ici...')),
          const SizedBox(height: 12),
          const Text('Type de notification'),
          DropdownButtonFormField<String>(
            initialValue: type,
            items: const [
              DropdownMenuItem(value: 'Promotional', child: Text('Promotionnel')),
              DropdownMenuItem(value: 'Transactional', child: Text('Transactionnel')),
              DropdownMenuItem(value: 'System', child: Text('Système')),
            ],
            onChanged: (v) => setState(() => type = v ?? type),
          ),
          const SizedBox(height: 12),
          const Text('Destinataires'),
          DropdownButtonFormField<String>(
            initialValue: recipients,
            items: const [
              DropdownMenuItem(value: 'All Users', child: Text('Tous les utilisateurs')),
              DropdownMenuItem(value: 'Clients', child: Text('Clients')),
              DropdownMenuItem(value: 'Agents', child: Text('Agents')),
            ],
            onChanged: (v) => setState(() => recipients = v ?? recipients),
          ),
          const SizedBox(height: 12),
          const Text('Programmation'),
          DropdownButtonFormField<String>(
            initialValue: schedule,
            items: const [
              DropdownMenuItem(value: 'Send Immediately', child: Text('Envoyer immédiatement')),
              DropdownMenuItem(value: 'Schedule...', child: Text('Programmer...')),
            ],
            onChanged: (v) => setState(() => schedule = v ?? schedule),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('Envoyer la notification')),
        ],
      ),
    );
  }
}

