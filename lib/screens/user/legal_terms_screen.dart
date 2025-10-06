import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d\'utilisation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Conditions d\'utilisation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Sample terms content...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Politique de confidentialité')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Politique de confidentialité', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Sample privacy content...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

