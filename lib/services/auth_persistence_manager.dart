import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'persistence_service.dart';

/// Types de persistance disponibles
enum TypePersistance {
  local,    // Persiste même après fermeture de l'application
  session,  // Persiste uniquement dans la session actuelle
  none,     // Pas de persistance (mémoire uniquement)
}

/// Gestionnaire de persistance d'authentification avancé
/// Supporte trois types de persistance: LOCAL, SESSION, NONE
class AuthPersistenceManager {
  static const String _cleTypePersistance = 'type_persistance_auth';
  static const String _cleSessionActive = 'session_active';
  static const String _cleDureeSession = 'duree_session';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ServiceDePersistance _serviceDePersistance = ServiceDePersistance();

  /// Constructeur
  AuthPersistenceManager() {
    _initialiserEcouteursAuth();
  }

  /// Initialiser les écouteurs d'état d'authentification
  void _initialiserEcouteursAuth() {
    // Écouter les changements d'état d'authentification
    _auth.authStateChanges().listen((User? utilisateur) {
      if (utilisateur != null) {
        debugPrint('État d\'authentification changé: ${utilisateur.email} est connecté');
        _onUserConnected(utilisateur);
      } else {
        debugPrint('État d\'authentification changé: utilisateur déconnecté');
        _onUserDisconnected();
      }
    });

    // Écouter les changements de jeton d'ID
    _auth.idTokenChanges().listen((User? utilisateur) {
      if (utilisateur != null) {
        debugPrint('Jeton d\'ID mis à jour pour: ${utilisateur.email}');
        _onTokenRefreshed(utilisateur);
      }
    });
  }

  /// Définir le type de persistance
  Future<bool> definirTypePersistance(TypePersistance type) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convertir le type en chaîne pour le stockage
      final typeString = type.toString().split('.').last;
      await prefs.setString(_cleTypePersistance, typeString);

      // Appliquer la persistance Firebase uniquement sur web
      if (kIsWeb) {
        Persistence firebasePersistence;
        switch (type) {
          case TypePersistance.local:
            firebasePersistence = Persistence.LOCAL;
            break;
          case TypePersistance.session:
            firebasePersistence = Persistence.SESSION;
            break;
          case TypePersistance.none:
            firebasePersistence = Persistence.NONE;
            break;
        }

        await _auth.setPersistence(firebasePersistence);
        debugPrint('Type de persistance Firebase défini sur: $typeString');
      } else {
        debugPrint('Type de persistance locale défini sur: $typeString (mobile)');
      }

      return true;
    } catch (e) {
      debugPrint('Erreur lors de la définition du type de persistance: $e');
      return false;
    }
  }

  /// Obtenir le type de persistance actuel
  Future<TypePersistance> obtenirTypePersistance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typeString = prefs.getString(_cleTypePersistance) ?? 'local';

      switch (typeString) {
        case 'local':
          return TypePersistance.local;
        case 'session':
          return TypePersistance.session;
        case 'none':
          return TypePersistance.none;
        default:
          return TypePersistance.local;
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'obtention du type de persistance: $e');
      return TypePersistance.local;
    }
  }

  /// Sauvegarder la session avec le type de persistance spécifié
  Future<void> sauvegarderSessionAvecPersistance({
    required User utilisateur,
    required Map<String, dynamic> donneesUtilisateur,
    TypePersistance? typePersistance,
    Duration? dureeSession,
  }) async {
    try {
      // Utiliser le type de persistance actuel si non spécifié
      typePersistance ??= await obtenirTypePersistance();

      final prefs = await SharedPreferences.getInstance();

      // Sauvegarder les informations de session
      await _serviceDePersistance.sauvegarderSessionUtilisateur(
        utilisateur: utilisateur,
        donneesUtilisateur: donneesUtilisateur,
      );

      // Sauvegarder le type de persistance
      await prefs.setString(_cleTypePersistance, typePersistance.toString().split('.').last);

      // Sauvegarder la durée de session si spécifiée
      if (dureeSession != null) {
        await prefs.setInt(_cleDureeSession, dureeSession.inSeconds);
        final expiration = DateTime.now().add(dureeSession);
        await prefs.setString('session_expiration', expiration.toIso8601String());
      }

      // Marquer la session comme active
      await prefs.setBool(_cleSessionActive, true);

      debugPrint('Session sauvegardée avec persistance ${typePersistance.toString()}');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de la session avec persistance: $e');
      rethrow;
    }
  }

  /// Restaurer la session selon le type de persistance
  Future<Map<String, dynamic>?> restaurerSessionAvecPersistance() async {
    try {
      final typePersistance = await obtenirTypePersistance();
      final prefs = await SharedPreferences.getInstance();

      // Vérifier si la session est active
      final sessionActive = prefs.getBool(_cleSessionActive) ?? false;
      if (!sessionActive) {
        return null;
      }

      // Vérifier l'expiration de la session
      final expirationString = prefs.getString('session_expiration');
      if (expirationString != null) {
        final expiration = DateTime.parse(expirationString);
        if (DateTime.now().isAfter(expiration)) {
          await effacerSessionAvecPersistance();
          return null;
        }
      }

      // Restaurer selon le type de persistance
      switch (typePersistance) {
        case TypePersistance.local:
          return await _restaurerSessionLocale();
        case TypePersistance.session:
          return await _restaurerSessionSession();
        case TypePersistance.none:
          return await _restaurerSessionMemoire();
      }
    } catch (e) {
      debugPrint('Erreur lors de la restauration de la session avec persistance: $e');
      return null;
    }
  }

  /// Restaurer session locale (persistente)
  Future<Map<String, dynamic>?> _restaurerSessionLocale() async {
    try {
      return await _serviceDePersistance.restaurerSessionAutomatiquement();
    } catch (e) {
      debugPrint('Erreur lors de la restauration de la session locale: $e');
      return null;
    }
  }

  /// Restaurer session de session
  Future<Map<String, dynamic>?> _restaurerSessionSession() async {
    try {
      // Pour la persistance de session, vérifier si l'onglet/la session est toujours actif
      final utilisateur = _auth.currentUser;
      if (utilisateur == null) {
        return null;
      }

      // Vérifier si le jeton est valide
      await utilisateur.reload();
      final jetonValide = await utilisateur.getIdToken() != null;

      if (!jetonValide) {
        return null;
      }

      // Obtenir les données utilisateur
      final documentUtilisateur = await _firestore.collection('users').doc(utilisateur.uid).get();
      if (!documentUtilisateur.exists) {
        return null;
      }

      final donneesUtilisateur = documentUtilisateur.data() as Map<String, dynamic>;

      return {
        'succes': true,
        'utilisateur': utilisateur,
        'donnees_utilisateur': donneesUtilisateur,
        'message': 'Session de session restaurée',
      };
    } catch (e) {
      debugPrint('Erreur lors de la restauration de la session de session: $e');
      return null;
    }
  }

  /// Restaurer session mémoire (aucune persistance)
  Future<Map<String, dynamic>?> _restaurerSessionMemoire() async {
    try {
      // Pour la persistance NONE, uniquement vérifier l'état actuel en mémoire
      final utilisateur = _auth.currentUser;
      if (utilisateur == null) {
        return null;
      }

      return {
        'succes': true,
        'utilisateur': utilisateur,
        'donnees_utilisateur': null, // Données non persistantes
        'message': 'Session mémoire restaurée',
      };
    } catch (e) {
      debugPrint('Erreur lors de la restauration de la session mémoire: $e');
      return null;
    }
  }

  /// Effacer la session selon le type de persistance
  Future<void> effacerSessionAvecPersistance() async {
    try {
      final typePersistance = await obtenirTypePersistance();
      final prefs = await SharedPreferences.getInstance();

      // Marquer la session comme inactive
      await prefs.setBool(_cleSessionActive, false);

      // Effacer les données selon le type de persistance
      switch (typePersistance) {
        case TypePersistance.local:
          await _serviceDePersistance.effacerSessionUtilisateur();
          break;
        case TypePersistance.session:
          await _effacerSessionSession();
          break;
        case TypePersistance.none:
          await _effacerSessionMemoire();
          break;
      }

      debugPrint('Session effacée pour le type de persistance: $typePersistance');
    } catch (e) {
      debugPrint('Erreur lors de l\'effacement de la session avec persistance: $e');
    }
  }

  /// Effacer session de session
  Future<void> _effacerSessionSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_expiration');
      await prefs.remove(_cleDureeSession);
      debugPrint('Session de session effacée');
    } catch (e) {
      debugPrint('Erreur lors de l\'effacement de la session de session: $e');
    }
  }

  /// Effacer session mémoire
  Future<void> _effacerSessionMemoire() async {
    try {
      // Pour la persistance NONE, simplement déconnecter de Firebase
      await _auth.signOut();
      debugPrint('Session mémoire effacée');
    } catch (e) {
      debugPrint('Erreur lors de l\'effacement de la session mémoire: $e');
    }
  }

  /// Vérifier si la session est valide
  Future<bool> sessionEstValide() async {
    try {
      final utilisateur = _auth.currentUser;
      if (utilisateur == null) {
        return false;
      }

      // Vérifier si le jeton est valide
      await utilisateur.reload();
      final jeton = await utilisateur.getIdToken();

      if (jeton == null) {
        return false;
      }

      // Vérifier selon le type de persistance
      final typePersistance = await obtenirTypePersistance();

      switch (typePersistance) {
        case TypePersistance.local:
          return await _serviceDePersistance.validerSessionActuelle();
        case TypePersistance.session:
          return await _verifierSessionSessionValide();
        case TypePersistance.none:
          return true; // Toujours valide si en mémoire
      }
    } catch (e) {
      debugPrint('Erreur lors de la validation de la session: $e');
      return false;
    }
  }

  /// Vérifier si la session de session est valide
  Future<bool> _verifierSessionSessionValide() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expirationString = prefs.getString('session_expiration');

      if (expirationString != null) {
        final expiration = DateTime.parse(expirationString);
        return DateTime.now().isBefore(expiration);
      }

      return true; // Pas d'expiration définie, considérée comme valide
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la session de session: $e');
      return false;
    }
  }

  /// Obtenir les informations de persistance
  Future<Map<String, dynamic>> obtenirInformationsPersistance() async {
    try {
      final typePersistance = await obtenirTypePersistance();
      final sessionValide = await sessionEstValide();
      final utilisateur = _auth.currentUser;

      return {
        'type_persistance': typePersistance.toString().split('.').last,
        'session_valide': sessionValide,
        'utilisateur_connecte': utilisateur != null,
        'email_utilisateur': utilisateur?.email,
        'derniere_verification': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'erreur': e.toString(),
        'type_persistance': 'inconnu',
        'session_valide': false,
        'utilisateur_connecte': false,
      };
    }
  }

  /// Gestionnaire de connexion utilisateur
  void _onUserConnected(User utilisateur) async {
    try {
      final typePersistance = await obtenirTypePersistance();
      debugPrint('Utilisateur connecté avec persistance: $typePersistance');

      // Sauvegarder la session selon le type de persistance
      final documentUtilisateur = await _firestore.collection('users').doc(utilisateur.uid).get();
      if (documentUtilisateur.exists) {
        final donneesUtilisateur = documentUtilisateur.data() as Map<String, dynamic>;
        await sauvegarderSessionAvecPersistance(
          utilisateur: utilisateur,
          donneesUtilisateur: donneesUtilisateur,
          typePersistance: typePersistance,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la gestion de la connexion utilisateur: $e');
    }
  }

  /// Gestionnaire de déconnexion utilisateur
  void _onUserDisconnected() async {
    try {
      await effacerSessionAvecPersistance();
      debugPrint('Utilisateur déconnecté, session effacée');
    } catch (e) {
      debugPrint('Erreur lors de la gestion de la déconnexion utilisateur: $e');
    }
  }

  /// Gestionnaire de rafraîchissement de jeton
  void _onTokenRefreshed(User utilisateur) async {
    try {
      final typePersistance = await obtenirTypePersistance();
      if (typePersistance == TypePersistance.local) {
        // Mettre à jour le jeton dans la persistance locale
        final documentUtilisateur = await _firestore.collection('users').doc(utilisateur.uid).get();
        if (documentUtilisateur.exists) {
          final donneesUtilisateur = documentUtilisateur.data() as Map<String, dynamic>;
          await sauvegarderSessionAvecPersistance(
            utilisateur: utilisateur,
            donneesUtilisateur: donneesUtilisateur,
            typePersistance: typePersistance,
          );
        }
      }
      debugPrint('Jeton rafraîchi pour: ${utilisateur.email}');
    } catch (e) {
      debugPrint('Erreur lors de la gestion du rafraîchissement de jeton: $e');
    }
  }

  /// Définir une durée de session personnalisée
  Future<bool> definirDureeSession(Duration duree) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cleDureeSession, duree.inSeconds);

      // Calculer la nouvelle expiration
      final expiration = DateTime.now().add(duree);
      await prefs.setString('session_expiration', expiration.toIso8601String());

      debugPrint('Durée de session définie sur: ${duree.inHours} heures');
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la définition de la durée de session: $e');
      return false;
    }
  }

  /// Prolonger la session actuelle
  Future<bool> prolongerSession(Duration dureeSupplementaire) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expirationString = prefs.getString('session_expiration');

      DateTime nouvelleExpiration;
      if (expirationString != null) {
        final expirationActuelle = DateTime.parse(expirationString);
        nouvelleExpiration = expirationActuelle.add(dureeSupplementaire);
      } else {
        nouvelleExpiration = DateTime.now().add(dureeSupplementaire);
      }

      await prefs.setString('session_expiration', nouvelleExpiration.toIso8601String());
      debugPrint('Session prolongée jusqu\'au: $nouvelleExpiration');

      return true;
    } catch (e) {
      debugPrint('Erreur lors de la prolongation de la session: $e');
      return false;
    }
  }
}
