import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/welcome_screen.dart';
import 'shells/admin_shell.dart';
import 'shells/client_shell.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialiser le provider d'authentification
    await authProvider.init();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si l'utilisateur n'est pas authentifié, afficher l'écran de bienvenue
    if (!authProvider.isAuthenticated) {
      return const WelcomeScreen();
    }

    // Redirection en fonction du rôle
    if (authProvider.isAdmin) {
      debugPrint('Redirecting to admin shell from wrapper');
      return const AdminShell();
    } else {
      debugPrint('Redirecting to client shell from wrapper');
      return const ClientShell();
    }
  }
}