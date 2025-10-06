import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';
import '../user/client_home_screen.dart';
import '../user/agents_search_screen.dart';
import '../user/bookings_screen.dart';
import '../user/profile_screen.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ClientHomeScreen(),
      const AgentsSearchScreen(),
      const BookingsScreen(),
      const UserProfileScreen(),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF111111),
        selectedIndex: index,
        indicatorColor: AppColors.yellow.withValues(alpha: 0.15),
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: 'home'.t(context)),
          NavigationDestination(icon: const Icon(Icons.shield_outlined), selectedIcon: const Icon(Icons.shield), label: 'agents'.t(context)),
          NavigationDestination(icon: const Icon(Icons.bookmark_border), selectedIcon: const Icon(Icons.bookmark), label: 'bookings'.t(context)),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: 'profile'.t(context)),
        ],
      ),
    );
  }
}

