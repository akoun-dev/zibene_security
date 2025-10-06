import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/user/client_home_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/shells/client_shell.dart';

class ServiceDeRoutage {
  static const String routeConnexion = '/connexion';
  static const String routeInscription = '/inscription';
  static const String routeAccueilClient = '/client/accueil';
  static const String routeAccueilAgent = '/agent/accueil';
  static const String routeAccueilAdmin = '/admin/accueil';
  static const String routeShellPrincipal = '/principal';

  // Générateur de routes pour la navigation basée sur les rôles
  static Route<dynamic> genererRoute(RouteSettings parametres) {
    switch (parametres.name) {
      case routeConnexion:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: parametres,
        );
      
      case routeInscription:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: parametres,
        );
      
      case routeAccueilClient:
        return MaterialPageRoute(
          builder: (_) => const ClientHomeScreen(),
          settings: parametres,
        );
      
      case routeAccueilAgent:
        return MaterialPageRoute(
          builder: (_) => const ClientHomeScreen(), // Temporairement, utiliser accueil client
          settings: parametres,
        );
      
      case routeAccueilAdmin:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
          settings: parametres,
        );
      
      case routeShellPrincipal:
        return MaterialPageRoute(
          builder: (_) => const ClientShell(), // Utiliser client shell comme shell principal
          settings: parametres,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: parametres,
        );
    }
  }

  // Obtenir la route d'accueil appropriée en fonction du rôle utilisateur
  static String obtenirRouteAccueil(String? role) {
    switch (role?.toLowerCase()) {
      case 'client':
        return routeAccueilClient;
      case 'agent':
        return routeAccueilAgent;
      case 'admin':
        return routeAccueilAdmin;
      default:
        return routeConnexion;
    }
  }

  // Naviguer vers l'écran approprié en fonction du rôle utilisateur
  static Future<void> naviguerVersAccueilParRole(
    BuildContext contexte, {
    String? role,
    bool remplacerTout = false,
    Map<String, dynamic>? arguments,
  }) async {
    final route = obtenirRouteAccueil(role);
    
    if (remplacerTout) {
      await Navigator.of(contexte).pushNamedAndRemoveUntil(
        route,
        (route) => false,
        arguments: arguments,
      );
    } else {
      await Navigator.of(contexte).pushNamed(
        route,
        arguments: arguments,
      );
    }
  }

  // Vérifier si l'utilisateur a la permission d'accéder à une route
  static bool aPermission(String? roleUtilisateur, String routeRequise) {
    if (roleUtilisateur == null) return false;
    
    switch (routeRequise) {
      case routeAccueilClient:
        return roleUtilisateur.toLowerCase() == 'client';
      case routeAccueilAgent:
        return roleUtilisateur.toLowerCase() == 'agent';
      case routeAccueilAdmin:
        return roleUtilisateur.toLowerCase() == 'admin';
      case routeShellPrincipal:
        return ['client', 'agent', 'admin'].contains(roleUtilisateur.toLowerCase());
      default:
        return true; // Routes publiques
    }
  }

  // Obtenir le nom de la route à partir des paramètres
  static String? obtenirNomRoute(RouteSettings parametres) {
    return parametres.name;
  }

  // Vérifier si la route actuelle nécessite une authentification
  static bool necessiteAuthentification(String? nomRoute) {
    if (nomRoute == null) return false;
    
    return [
      routeAccueilClient,
      routeAccueilAgent,
      routeAccueilAdmin,
      routeShellPrincipal,
    ].contains(nomRoute);
  }

  // Gérer l'accès non autorisé
  static void gererAccesNonAutorise(BuildContext contexte) {
    Navigator.of(contexte).pushNamedAndRemoveUntil(
      routeConnexion,
      (route) => false,
    );
  }

  // Naviguer avec validation de rôle
  static Future<bool> naviguerAvecValidationRole(
    BuildContext contexte,
    String nomRoute, {
    String? roleUtilisateur,
    Map<String, dynamic>? arguments,
  }) async {
    if (necessiteAuthentification(nomRoute) && !aPermission(roleUtilisateur, nomRoute)) {
      gererAccesNonAutorise(contexte);
      return false;
    }
    
    try {
      await Navigator.of(contexte).pushNamed(
        nomRoute,
        arguments: arguments,
      );
      return true;
    } catch (e) {
      debugPrint('Erreur de navigation: $e');
      return false;
    }
  }

  // Obtenir toutes les routes disponibles pour un rôle
  static List<String> obtenirRoutesDisponibles(String? role) {
    switch (role?.toLowerCase()) {
      case 'client':
        return [routeConnexion, routeInscription, routeAccueilClient, routeShellPrincipal];
      case 'agent':
        return [routeConnexion, routeInscription, routeAccueilAgent, routeShellPrincipal];
      case 'admin':
        return [
          routeConnexion,
          routeInscription,
          routeAccueilAdmin,
          routeShellPrincipal,
          // L'admin peut accéder à toutes les routes
          routeAccueilClient,
          routeAccueilAgent,
        ];
      default:
        return [routeConnexion, routeInscription];
    }
  }

  // Vérifier si la route est dans les routes disponibles de l'utilisateur
  static bool estRouteDisponible(String? roleUtilisateur, String nomRoute) {
    final routesDisponibles = obtenirRoutesDisponibles(roleUtilisateur);
    return routesDisponibles.contains(nomRoute);
  }

  // Obtenir la description de la route pour le débogage
  static Map<String, dynamic> obtenirInformationsRoute(String nomRoute) {
    return {
      'nom': nomRoute,
      'necessite_authentification': necessiteAuthentification(nomRoute),
      'role_requis': _obtenirRoleRequis(nomRoute),
      'est_publique': !necessiteAuthentification(nomRoute),
    };
  }

  // Obtenir le rôle requis pour une route
  static String? _obtenirRoleRequis(String nomRoute) {
    switch (nomRoute) {
      case routeAccueilClient:
        return 'client';
      case routeAccueilAgent:
        return 'agent';
      case routeAccueilAdmin:
        return 'admin';
      default:
        return null;
    }
  }
}
