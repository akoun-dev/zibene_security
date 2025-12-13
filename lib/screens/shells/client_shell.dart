import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';
import '../user/client_home_screen.dart';
import '../user/agents_list_screen.dart';
import '../user/bookings_screen.dart';
import '../user/booking_form_screen.dart';
import '../user/profile_screen.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int index = 0;
  DateTime? lastBackPressed;

  Future<bool> _onWillPop() async {
    // Si on n'est pas sur le premier onglet, revenir à l'onglet précédent
    if (index != 0) {
      setState(() => index = 0);
      return false; // Empêcher la sortie
    }

    // Gérer le double tap pour sortir (pattern Android)
    final now = DateTime.now();
    if (lastBackPressed == null ||
        now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
      lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('app_exit_double_tap'.t(context)),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.yellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false; // Empêcher la sortie au premier tap
    }

    // Au deuxième tap, montrer la confirmation
    return await _showExitConfirmation();
  }

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('exit_app_title'.t(context)),
          content: Text('exit_app_confirmation'.t(context)),
          backgroundColor: const Color(0xFF2A2A2A),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'cancel'.t(context),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: Text('exit_app_confirm'.t(context)),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ClientHomeScreen(),
      const AgentsListScreen(),
      const BookingsScreen(),
      const UserProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          SystemNavigator.pop(); // Ferme vraiment l'application
        }
      },
      child: Scaffold(
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF111111),
          selectedIndex: index,
          indicatorColor: AppColors.yellow.withValues(alpha: 0.15),
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: 'home'.t(context)),
            NavigationDestination(icon: const Icon(Icons.people_alt_outlined), selectedIcon: const Icon(Icons.people_alt), label: 'Agents'),
            NavigationDestination(icon: const Icon(Icons.bookmark_border), selectedIcon: const Icon(Icons.bookmark), label: 'bookings'.t(context)),
            NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: 'profile'.t(context)),
          ],
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
      ),
    );
  }
}

