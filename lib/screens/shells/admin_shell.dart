import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/users_screen.dart';
import '../admin/bookings_management_screen.dart';
import '../admin/reports_screen.dart';
import '../admin/alerts_screen.dart';
import '../admin/system_monitor_screen.dart';
import '../admin/roles_permissions_screen.dart';
import '../admin/notifications_compose_screen.dart';
import '../admin/activity_log_screen.dart';
import '../admin/seed_management_screen.dart';
import '../auth/login_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AdminDashboardScreen(),
      const UsersScreen(),
      const BookingsManagementScreen(),
      const ReportsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('admin'.t(context)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              ListTile(title: Text('admin_tools'.t(context))),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text('alerts'.t(context)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.monitor_heart_outlined),
                title: Text('system_monitor'.t(context)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SystemMonitorScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: Text('roles_permissions'.t(context)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RolesPermissionsScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.mark_email_unread_outlined),
                title: Text('send_notification'.t(context)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsComposeScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: Text('activity_log'.t(context)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ActivityLogScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dataset),
                title: Text('Gestion Seed'),
                onTap: () {
                  debugPrint('Navigation vers Gestion Seed...');
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SeedManagementScreen()),
                  );
                },
              ),
              const Divider(),
              // Section Paramètres et Déconnexion
              const ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Paramètres'),
                enabled: false, // Pour l'instant désactivé
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF111111),
        selectedIndex: index,
        indicatorColor: AppColors.yellow.withValues(alpha: 0.15),
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), label: 'dashboard'.t(context)),
          NavigationDestination(icon: const Icon(Icons.people_alt_outlined), label: 'users'.t(context)),
          NavigationDestination(icon: const Icon(Icons.bookmark_border_outlined), label: 'bookings'.t(context)),
          NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), label: 'reports'.t(context)),
        ],
      ),
    );
  }

  // Méthode pour afficher le dialogue de confirmation de déconnexion
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fermer le dialogue
                await _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour gérer la déconnexion
  Future<void> _logout(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Afficher un indicateur de chargement
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déconnexion en cours...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Effectuer la déconnexion
      await authProvider.signOut();

      // Naviguer vers l'écran de login
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

