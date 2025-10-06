import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'persistence_service.dart';
import 'route_service.dart';

class InitialiseurApp {
  static final InitialiseurApp _instance = InitialiseurApp._internal();
  final ServiceAuthentification _serviceAuthentification = ServiceAuthentification();
  final ServiceDePersistance _serviceDePersistance = ServiceDePersistance();

  factory InitialiseurApp() {
    return _instance;
  }

  InitialiseurApp._internal();

  // Initialiser l'application et vérifier la session persistante
  Future<Map<String, dynamic>> initialiserApp() async {
    try {
      debugPrint('Début de l\'initialisation de l\'application...');
      
      // Vérifier s'il y a une session persistante
      final aSessionPersistante = await _serviceAuthentification.aSessionPersistante();
      
      if (aSessionPersistante) {
        debugPrint('Session persistante trouvée, tentative de restauration...');
        
        // Essayer de restaurer la session
        final resultatSession = await _serviceAuthentification.restaurerSessionAutomatiquement();
        
        if (resultatSession != null && resultatSession['succes'] == true) {
          debugPrint('Session restaurée avec succès');
          return {
            'succes': true,
            'session_restauree': true,
            'utilisateur': resultatSession['utilisateur'],
            'donnees_utilisateur': resultatSession['donnees_utilisateur'],
            'message': 'Session restaurée automatiquement',
          };
        } else {
          debugPrint('Échec de la restauration de la session, effacement des données invalides');
          await _serviceAuthentification.effacerSessionUtilisateur();
          return {
            'succes': true,
            'session_restauree': false,
            'message': 'Session invalide effacée',
          };
        }
      } else {
        debugPrint('Aucune session persistante trouvée');
        return {
          'succes': true,
          'session_restauree': false,
          'message': 'Aucune session persistante trouvée',
        };
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de l\'application: $e');
      return {
        'succes': false,
        'session_restauree': false,
        'erreur': e.toString(),
        'message': 'Erreur lors de l\'initialisation de l\'application',
      };
    }
  }

  // Obtenir le statut de persistance pour le débogage
  Future<Map<String, dynamic>> obtenirStatutPersistance() async {
    try {
      final statutAuth = await _serviceAuthentification.verifierStatutPersistance();
      final infosSession = await _serviceDePersistance.obtenirInformationsSession();
      
      return {
        'statut_auth': statutAuth,
        'infos_session': infosSession,
        'horodatage': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'erreur': e.toString(),
        'horodatage': DateTime.now().toIso8601String(),
      };
    }
  }

  // Forcer l'effacement de toutes les données de l'application (pour test ou réinitialisation)
  Future<void> effacerToutesLesDonneesApp() async {
    try {
      debugPrint('Effacement de toutes les données de l\'application...');
      await _serviceDePersistance.effacerToutesLesDonneesApp();
      debugPrint('Toutes les données de l\'application effacées avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'effacement des données de l\'application: $e');
      rethrow;
    }
  }

  // Vérifier si l'utilisateur est authentifié avec une session valide
  Future<bool> estUtilisateurAuthentifie() async {
    try {
      final utilisateur = _serviceAuthentification.currentUser;
      if (utilisateur == null) {
        return false;
      }

      // Vérifier si la session locale correspond à la session Firebase
      final estValide = await _serviceDePersistance.validerSessionActuelle();
      
      return estValide;
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut d\'authentification: $e');
      return false;
    }
  }

  // Obtenir les données utilisateur actuelles avec validation de session
  Future<Map<String, dynamic>?> obtenirDonneesUtilisateurActuelles() async {
    try {
      final estAuthentifie = await estUtilisateurAuthentifie();
      if (!estAuthentifie) {
        return null;
      }

      final utilisateur = _serviceAuthentification.currentUser;
      if (utilisateur == null) {
        return null;
      }

      // Obtenir les données utilisateur fraîches de Firestore
      final roleUtilisateur = await _serviceAuthentification.getUserRole(utilisateur.uid);
      final estApprouve = await _serviceAuthentification.isUserApproved(utilisateur.uid);

      return {
        'utilisateur': utilisateur,
        'id_utilisateur': utilisateur.uid,
        'email': utilisateur.email,
        'nom_affichage': _serviceAuthentification.displayName,
        'email_verifie': utilisateur.emailVerified,
        'role': roleUtilisateur,
        'est_approuve': estApprouve,
        'session_valide': true,
      };
    } catch (e) {
      debugPrint('Erreur lors de l\'obtention des données utilisateur actuelles: $e');
      return null;
    }
  }

  // Naviguer vers l'écran d'accueil approprié en fonction du rôle utilisateur
  Future<void> naviguerVersAccueilParRole(BuildContext contexte) async {
    try {
      final donneesUtilisateur = await obtenirDonneesUtilisateurActuelles();
      
      if (donneesUtilisateur == null) {
        // Aucun utilisateur authentifié, naviguer vers connexion
        await ServiceDeRoutage.naviguerVersAccueilParRole(
          contexte,
          role: null,
          remplacerTout: true,
        );
        return;
      }

      final roleUtilisateur = donneesUtilisateur['role'] as String?;
      final estApprouve = donneesUtilisateur['est_approuve'] as bool? ?? false;
      
      // Vérifier si l'utilisateur est approuvé (pour les agents)
      if (roleUtilisateur == 'agent' && !estApprouve) {
        // Agent non approuvé, afficher écran d'attente ou naviguer vers connexion
        await ServiceDeRoutage.naviguerVersAccueilParRole(
          contexte,
          role: null,
          remplacerTout: true,
        );
        return;
      }

      // Naviguer vers l'accueil approprié en fonction du rôle
      await ServiceDeRoutage.naviguerVersAccueilParRole(
        contexte,
        role: roleUtilisateur,
        remplacerTout: true,
        arguments: donneesUtilisateur,
      );
      
      debugPrint('Navigation vers l\'accueil réussie pour le rôle: $roleUtilisateur');
    } catch (e) {
      debugPrint('Erreur lors de la navigation vers l\'accueil par rôle: $e');
      // Fallback vers écran de connexion
      await ServiceDeRoutage.naviguerVersAccueilParRole(
        contexte,
        role: null,
        remplacerTout: true,
      );
    }
  }

  // Gérer le démarrage de l'application avec navigation basée sur les rôles
  Future<Map<String, dynamic>> gererDemarrageApp(BuildContext contexte) async {
    try {
      // D'abord, initialiser l'application et vérifier les sessions persistantes
      final resultatInitialisation = await initialiserApp();
      
      if (!resultatInitialisation['succes']) {
        return {
          'succes': false,
          'message': 'Échec de l\'initialisation',
          'erreur': resultatInitialisation['erreur'],
        };
      }

      // Si la session a été restaurée, obtenir les données utilisateur et naviguer
      if (resultatInitialisation['session_restauree'] == true) {
        final donneesUtilisateur = await obtenirDonneesUtilisateurActuelles();
        
        if (donneesUtilisateur != null) {
          final roleUtilisateur = donneesUtilisateur['role'] as String?;
          final estApprouve = donneesUtilisateur['est_approuve'] as bool? ?? false;
          
          // Vérifier le statut d'approbation pour les agents
          if (roleUtilisateur == 'agent' && !estApprouve) {
            return {
              'succes': true,
              'session_restauree': true,
              'utilisateur_approuve': false,
              'role_utilisateur': roleUtilisateur,
              'message': 'Compte agent en attente d\'approbation',
              'naviguer_vers': ServiceDeRoutage.routeConnexion,
            };
          }
          
          // Naviguer vers l'accueil basé sur le rôle
          await ServiceDeRoutage.naviguerVersAccueilParRole(
            contexte,
            role: roleUtilisateur,
            remplacerTout: true,
            arguments: donneesUtilisateur,
          );
          
          return {
            'succes': true,
            'session_restauree': true,
            'utilisateur_approuve': true,
            'role_utilisateur': roleUtilisateur,
            'message': 'Session restaurée et navigation réussie',
            'naviguer_vers': ServiceDeRoutage.obtenirRouteAccueil(roleUtilisateur),
          };
        }
      }

      // Aucune session restaurée ou session invalide, naviguer vers connexion
      await ServiceDeRoutage.naviguerVersAccueilParRole(
        contexte,
        role: null,
        remplacerTout: true,
      );
      
      return {
        'succes': true,
        'session_restauree': false,
        'message': 'Aucune session à restaurer, navigation vers connexion',
        'naviguer_vers': ServiceDeRoutage.routeConnexion,
      };
    } catch (e) {
      debugPrint('Erreur lors de la gestion du démarrage de l\'application: $e');
      
      // Fallback vers écran de connexion
      await ServiceDeRoutage.naviguerVersAccueilParRole(
        contexte,
        role: null,
        remplacerTout: true,
      );
      
      return {
        'succes': false,
        'message': 'Erreur lors du démarrage de l\'application',
        'erreur': e.toString(),
        'naviguer_vers': ServiceDeRoutage.routeConnexion,
      };
    }
  }

  // Obtenir le rôle utilisateur et les permissions
  Future<Map<String, dynamic>> obtenirPermissionsUtilisateur() async {
    try {
      final donneesUtilisateur = await obtenirDonneesUtilisateurActuelles();
      
      if (donneesUtilisateur == null) {
        return {
          'authentifie': false,
          'role': null,
          'permissions': [],
        };
      }

      final roleUtilisateur = donneesUtilisateur['role'] as String?;
      final estApprouve = donneesUtilisateur['est_approuve'] as bool? ?? false;
      
      // Définir les permissions en fonction du rôle
      List<String> permissions = [];
      
      switch (roleUtilisateur?.toLowerCase()) {
        case 'client':
          permissions = [
            'voir_agents',
            'reserver_agents',
            'voir_reservations_proprio',
            'gerer_profil',
            'effectuer_paiements',
          ];
          break;
        case 'agent':
          if (estApprouve) {
            permissions = [
              'voir_profil_proprio',
              'gerer_profil_proprio',
              'voir_reservations_attribuees',
              'mettre_a_jour_statut_reservation',
              'recevoir_notifications',
            ];
          }
          break;
        case 'admin':
          permissions = [
            'voir_tous_utilisateurs',
            'gerer_utilisateurs',
            'approuver_agents',
            'voir_toutes_reservations',
            'gerer_reservations',
            'voir_rapports',
            'gerer_systeme',
            'voir_tous_profils',
          ];
          break;
      }

      return {
        'authentifie': true,
        'role': roleUtilisateur,
        'est_approuve': estApprouve,
        'permissions': permissions,
        'donnees_utilisateur': donneesUtilisateur,
      };
    } catch (e) {
      debugPrint('Erreur lors de l\'obtention des permissions utilisateur: $e');
      return {
        'authentifie': false,
        'role': null,
        'permissions': [],
        'erreur': e.toString(),
      };
    }
  }

  // Vérifier si l'utilisateur a une permission spécifique
  Future<bool> aPermission(String permission) async {
    try {
      final donneesPermissions = await obtenirPermissionsUtilisateur();
      final permissions = donneesPermissions['permissions'] as List<String>? ?? [];
      
      return permissions.contains(permission);
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la permission: $e');
      return false;
    }
  }
}
