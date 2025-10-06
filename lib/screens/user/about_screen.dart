import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos de nous')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 16),
          Center(child: Icon(Icons.shield, size: 72, color: AppColors.yellow)),
          SizedBox(height: 16),
          Center(
            child: Text('ZIBENE SÉCURITÉ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 8),
          Center(child: Text('Votre sécurité, notre priorité.', style: TextStyle(color: AppColors.yellow))),
          SizedBox(height: 24),
          Text('Notre mission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Text(
            'Fournir des services de sécurité inégalés avec le plus grand professionnalisme et discrétion. Nous assurons sécurité et tranquillité d\'esprit grâce à des gardes du corps hautement formés et certifiés, disponibles à tout moment, n\'importe où.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 24),
          Text('Nos valeurs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          _ValueItem(icon: Icons.verified_user, title: 'Intégrité', desc: 'Nous opérons avec honnêteté et de solides principes moraux.'),
          _ValueItem(icon: Icons.star_rate, title: 'Excellence', desc: 'Nous visons les plus hauts standards dans tous les aspects de notre service.'),
          _ValueItem(icon: Icons.groups_2, title: 'Engagement', desc: 'Nous sommes dédiés à la sécurité et à la satisfaction de nos clients.'),
          SizedBox(height: 24),
          Text('Informations de contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Card(child: ListTile(leading: Icon(Icons.email_outlined), title: Text('contact@zibenesecurity.com'))),
          SizedBox(height: 8),
          Card(child: ListTile(leading: Icon(Icons.phone_outlined), title: Text('+1 (234) 567-890'))),
          SizedBox(height: 8),
          Card(child: ListTile(leading: Icon(Icons.location_on_outlined), title: Text('123 Security Avenue, Suite 100, Metropolis, ST 12345'))),
        ],
      ),
    );
  }
}

class _ValueItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _ValueItem({required this.icon, required this.title, required this.desc});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.yellow),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

