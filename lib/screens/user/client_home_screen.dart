import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';
import '../../utils/responsive_utils.dart';
import '../../providers/user_provider.dart';
import '../../providers/booking_provider.dart';
import 'bookings_screen.dart';
import 'booking_form_screen.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final user = userProvider.currentUser;

    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userProvider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userProvider.error!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => userProvider.refreshUser(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'welcome_back'.t(context),
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 16, desktopSize: 18),
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 0.3),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobileSize: 22, tabletSize: 24, desktopSize: 26),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Notifications',
                  hint: 'Voir vos notifications',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.yellow,
                      semanticLabel: 'Notifications',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'need_security_now'.t(context),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'book_certified_agent_minutes'.t(context),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    label: 'Réserver un agent maintenant',
                    hint: 'Rechercher et réserver un agent de sécurité',
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Redirection vers la page de création de réservation
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const BookingFormScreen()),
                          );
                        },
                        child: Text('Réserver un service'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 2),
            Text(
              'quick_stats'.t(context),
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobileSize: 16, tabletSize: 18, desktopSize: 20),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
            Semantics(
              container: true,
              label: 'Statistiques rapides',
              child: Row(
                children: [
                  Expanded(child: _StatCard(title: 'active_users'.t(context), value: '0', trend: '+5%', semanticLabel: 'Utilisateurs actifs')),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context)),
                  Expanded(child: _StatCard(title: 'upcoming'.t(context), value: bookingProvider.bookings.where((b) => b.clientId == user.id).length.toString(), trend: '+2%', semanticLabel: 'Réservations à venir')),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 2),
            Text(
              'quick_actions'.t(context),
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobileSize: 16, tabletSize: 18, desktopSize: 20),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
            Semantics(
              container: true,
              label: 'Actions rapides',
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.calendar_today,
                      label: 'view_bookings'.t(context),
                      semanticLabel: 'Voir mes réservations',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BookingsScreen()),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context)),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.bookmark_border,
                      label: 'my_bookings'.t(context),
                      semanticLabel: 'Mes réservations',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BookingsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final String? semanticLabel;

  const _StatCard({required this.title, required this.value, required this.trend, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel ?? title,
      value: '$value, tendance $trend',
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 0.7),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobileSize: 28, tabletSize: 32, desktopSize: 36),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 0.5),
              Text(
                trend,
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobileSize: 12, tabletSize: 13, desktopSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? semanticLabel;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.semanticLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      hint: 'Bouton d\'action rapide',
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.yellow,
          side: const BorderSide(color: AppColors.yellow),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.getResponsiveButtonHeight(context) * 0.33,
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: ResponsiveUtils.getResponsiveFontSize(context, mobileSize: 24, tabletSize: 28, desktopSize: 32),
              semanticLabel: semanticLabel ?? label,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 0.7),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
