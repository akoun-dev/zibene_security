import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceDePersistance {
  static const String _cleSessionUtilisateur = 'session_utilisateur';
  static const String _cleJetonAuth = 'jeton_auth';
  static const String _cleDonneesUtilisateur = 'donnees_utilisateur';
  static const String _cleDerniereConnexion = 'derniere_connexion';
  static const String _cleParametresApp = 'parametres_app';
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sauvegarder les données de session utilisateur localement
  Future<void> sauvegarderSessionUtilisateur({
    required User utilisateur,
    required Map<String, dynamic> donneesUtilisateur,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtenir le jeton d'authentification
      final jetonAuth = await utilisateur.getIdToken(true);
      
      // Sauvegarder les données de session
      await prefs.setString(_cleSessionUtilisateur, utilisateur.uid);
      await prefs.setString(_cleJetonAuth, jetonAuth ?? '');
      await prefs.setString(_cleDonneesUtilisateur, donneesUtilisateur.toString());
      await prefs.setString(_cleDerniereConnexion, DateTime.now().toIso8601String());
      
      // Sauvegarder les préférences utilisateur
      await prefs.setBool('mode_sombre', donneesUtilisateur['dark_mode'] ?? false);
      await prefs.setString('langue', donneesUtilisateur['language'] ?? 'fr');
      await prefs.setString('role_utilisateur', donneesUtilisateur['role'] ?? 'client');
      
      debugPrint('Session utilisateur sauvegardée avec succès pour ${utilisateur.email}');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de la session utilisateur: $e');
      rethrow;
    }
  }

  // Charger les données de session utilisateur
  Future<Map<String, dynamic>?> chargerSessionUtilisateur() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final idUtilisateur = prefs.getString(_cleSessionUtilisateur);
      final jetonAuth = prefs.getString(_cleJetonAuth);
      final derniereConnexion = prefs.getString(_cleDerniereConnexion);
      
      if (idUtilisateur == null || jetonAuth == null) {
        return null;
      }
      
      // Vérifier si la session est toujours valide (moins de 30 jours)
      if (derniereConnexion != null) {
        final dateDerniereConnexion = DateTime.parse(derniereConnexion);
        final ilYATrenteJours = DateTime.now().subtract(const Duration(days: 30));
        
        if (dateDerniereConnexion.isBefore(ilYATrenteJours)) {
          await effacerSessionUtilisateur();
          return null;
        }
      }
      
      return {
        'id_utilisateur': idUtilisateur,
        'jeton_auth': jetonAuth,
        'derniere_connexion': derniereConnexion,
        'mode_sombre': prefs.getBool('mode_sombre') ?? false,
        'langue': prefs.getString('langue') ?? 'fr',
        'role_utilisateur': prefs.getString('role_utilisateur') ?? 'client',
      };
    } catch (e) {
      debugPrint('Erreur lors du chargement de la session utilisateur: $e');
      return null;
    }
  }

  // Effacer les données de session utilisateur
  Future<void> effacerSessionUtilisateur() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_cleSessionUtilisateur);
      await prefs.remove(_cleJetonAuth);
      await prefs.remove(_cleDonneesUtilisateur);
      await prefs.remove(_cleDerniereConnexion);
      
      // Garder les paramètres de l'application mais effacer les paramètres spécifiques à l'utilisateur
      await prefs.remove('mode_sombre');
      await prefs.remove('langue');
      await prefs.remove('role_utilisateur');
      
      debugPrint('Session utilisateur effacée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'effacement de la session utilisateur: $e');
      rethrow;
    }
  }

  // Sauvegarder les paramètres de l'application
  Future<void> sauvegarderParametresApp(Map<String, dynamic> parametres) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_cleParametresApp, parametres.toString());
      
      // Sauvegarder les paramètres individuels pour un accès facile
      if (parametres.containsKey('dark_mode')) {
        await prefs.setBool('mode_sombre', parametres['dark_mode']);
      }
      if (parametres.containsKey('language')) {
        await prefs.setString('langue', parametres['language']);
      }
      if (parametres.containsKey('notifications_enabled')) {
        await prefs.setBool('notifications_activees', parametres['notifications_enabled']);
      }
      
      debugPrint('Paramètres de l\'application sauvegardés avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des paramètres de l\'application: $e');
      rethrow;
    }
  }

  // Charger les paramètres de l'application
  Future<Map<String, dynamic>> chargerParametresApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'mode_sombre': prefs.getBool('mode_sombre') ?? false,
        'langue': prefs.getString('langue') ?? 'fr',
        'notifications_activees': prefs.getBool('notifications_activees') ?? true,
        'derniere_mise_a_jour': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Erreur lors du chargement des paramètres de l\'application: $e');
      return {
        'mode_sombre': false,
        'langue': 'fr',
        'notifications_activees': true,
        'derniere_mise_a_jour': DateTime.now().toIso8601String(),
      };
    }
  }

  // Vérifier si l'utilisateur a une session persistante
  Future<bool> aSessionPersistante() async {
    try {
      final session = await chargerSessionUtilisateur();
      return session != null;
    } catch (e) {
      return false;
    }
  }

  // Valider la session actuelle
  Future<bool> validerSessionActuelle() async {
    try {
      final utilisateur = _auth.currentUser;
      if (utilisateur == null) {
        return false;
      }
      
      // Vérifier si le jeton est toujours valide
      await utilisateur.reload();
      final jeton = await utilisateur.getIdToken(true);
      
      if (jeton == null) {
        return false;
      }
      
      // Vérifier si la session locale correspond à la session Firebase
      final sessionLocale = await chargerSessionUtilisateur();
      if (sessionLocale == null || sessionLocale['id_utilisateur'] != utilisateur.uid) {
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la validation de la session: $e');
      return false;
    }
  }

  // Restaurer automatiquement la session si disponible
  Future<Map<String, dynamic>?> restaurerSessionAutomatiquement() async {
    try {
      final aSession = await aSessionPersistante();
      if (!aSession) {
        return null;
      }
      
      final estValide = await validerSessionActuelle();
      if (!estValide) {
        await effacerSessionUtilisateur();
        return null;
      }
      
      final utilisateur = _auth.currentUser;
      if (utilisateur == null) {
        return null;
      }
      
      // Obtenir les données utilisateur fraîches de Firestore
      final documentUtilisateur = await _firestore.collection('users').doc(utilisateur.uid).get();
      if (!documentUtilisateur.exists) {
        await effacerSessionUtilisateur();
        return null;
      }
      
      final donneesUtilisateur = documentUtilisateur.data() as Map<String, dynamic>;
      
      // Mettre à jour la session locale avec des données fraîches
      await sauvegarderSessionUtilisateur(utilisateur: utilisateur, donneesUtilisateur: donneesUtilisateur);
      
      return {
        'succes': true,
        'utilisateur': utilisateur,
        'donnees_utilisateur': donneesUtilisateur,
        'message': 'Session restaurée automatiquement',
      };
    } catch (e) {
      debugPrint('Erreur lors de la restauration automatique de la session: $e');
      await effacerSessionUtilisateur();
      return null;
    }
  }

  // Obtenir les informations de session
  Future<Map<String, dynamic>> obtenirInformationsSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final session = await chargerSessionUtilisateur();
      
      return {
        'a_session': session != null,
        'donnees_session': session,
        'cles_prefs': prefs.getKeys(),
        'utilisateur_firebase': _auth.currentUser?.email,
        'derniere_connexion': session?['derniere_connexion'],
      };
    } catch (e) {
      return {
        'a_session': false,
        'erreur': e.toString(),
      };
    }
  }

  // Effacer toutes les données de l'application (pour déconnexion ou réinitialisation)
  Future<void> effacerToutesLesDonneesApp() async {
    try {
      await effacerSessionUtilisateur();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      debugPrint('Toutes les données de l\'application effacées avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'effacement des données de l\'application: $e');
      rethrow;
    }
  }
}
