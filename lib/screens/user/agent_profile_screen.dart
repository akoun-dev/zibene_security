import 'package:flutter/material.dart';
import '../../models/agent_model.dart';
import '../../utils/theme.dart';
import 'booking_confirm_screen.dart';

class AgentProfileScreen extends StatelessWidget {
  final Agent agent;
  const AgentProfileScreen({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil de l\'agent')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Semantics(
                    image: true,
                    label: 'Photo de profil de ${agent.name}',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.yellow,
                        size: 40,
                        semanticLabel: 'Photo de profil',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    agent.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Agent de sécurité',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        container: true,
                        label: agent.available ? 'Statut disponible' : 'Statut occupé',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: agent.available ? AppColors.success.withValues(alpha: 0.15) : AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: agent.available ? AppColors.success : AppColors.danger,
                                size: 8,
                                semanticLabel: agent.available ? 'Disponible' : 'Occupé',
                              ),
                              const SizedBox(width: 4),
                              Text(
                                agent.available ? 'Available' : 'Busy',
                                style: TextStyle(
                                  color: agent.available ? AppColors.success : AppColors.danger,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Semantics(
                        label: 'Taux horaire',
                        value: '${agent.hourlyRate.toStringAsFixed(2)} euros par heure',
                        child: Row(
                          children: [
                            const Icon(Icons.euro, color: AppColors.success, size: 16, semanticLabel: 'Euro'),
                            const SizedBox(width: 4),
                            Text(
                              '${agent.hourlyRate.toStringAsFixed(2)}/h',
                              style: const TextStyle(fontSize: 14, color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Highly trained and experienced close protection officer with over 15 years in high-risk environments. Specialized in threat assessment, defensive driving, and unarmed combat. Discreet and professional.',
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Skills & Expertise',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Close Protection',
                'Threat Assessment',
                'Defensive Driving',
                'First Aid',
                'Firearms Training',
                'Crowd Control',
                'Surveillance',
                'Emergency Response'
              ].map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.yellow,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Certifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...agent.certifications.map((c) => Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined, color: AppColors.yellow),
                  const SizedBox(width: 12),
                  Expanded(child: Text(c)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            const Text(
              'Rates & Availability',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Taux horaire'),
                        Text(
                          '\$50/hour',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Taux journalier'),
                        Text(
                          '\$400/jour',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Temps de réponse'),
                        Text(
                          'Within 30 min',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BookingConfirmScreen(agent: agent)),
                ),
                child: const Text('Réserver maintenant'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

