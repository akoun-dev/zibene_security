import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class AdminService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    try {
      _isInitialized = FirebaseService.isInitialized;
      debugPrint('AdminService initialized: $_isInitialized');
    } catch (e) {
      debugPrint('AdminService initialization failed: $e');
      _isInitialized = false;
    }
  }

  static bool get isInitialized => _isInitialized;

  // Vérifier si l'utilisateur connecté est un admin en se basant sur les custom claims OU sur la collection users
  static Future<bool> isAdmin() async {
    try {
      if (!_isInitialized) {
        debugPrint('AdminService: Not initialized');
        return false;
      }

      final currentUser = FirebaseService.auth.currentUser;
      if (currentUser == null) {
        debugPrint('AdminService: No Firebase user');
        return false;
      }

      debugPrint('AdminService: Checking admin status for user ${currentUser.uid}');

      // Méthode 1: Vérifier les custom claims Firebase
      try {
        final idTokenResult = await currentUser.getIdTokenResult();
        final claims = idTokenResult.claims;
        final roleFromClaims = claims?['role'];

        debugPrint('AdminService: Role from custom claims: $roleFromClaims');

        if (roleFromClaims == 'admin') {
          debugPrint('AdminService: User is admin (custom claims)');
          return true;
        }
      } catch (e) {
        debugPrint('AdminService: Error checking custom claims: $e');
      }

      // Méthode 2: Vérifier dans la collection users (fallback)
      try {
        debugPrint('AdminService: Checking role in users collection...');
        final userDoc = await FirebaseService.getDataById(
          FirebaseService.usersCollection,
          currentUser.uid,
        );

        if (userDoc != null) {
          final userData = userDoc as Map<String, dynamic>;
          final roleFromDb = userData['role'];
          debugPrint('AdminService: Role from database: $roleFromDb');

          if (roleFromDb == 'admin') {
            debugPrint('AdminService: User is admin (database check)');
            return true;
          }
        } else {
          debugPrint('AdminService: User document not found in database');
        }
      } catch (e) {
        debugPrint('AdminService: Error checking database role: $e');
      }

      debugPrint('AdminService: User is NOT admin');
      return false;
    } catch (e) {
      debugPrint('AdminService: Error checking admin status: $e');
      return false;
    }
  }

  // Vérifier si l'utilisateur a le rôle admin basé sur les données locales (fallback rapide)
  static bool isUserAdmin(String userId) {
    try {
      // Cette méthode est un fallback basé sur les données locales
      // Elle est moins fiable mais plus rapide
      // TODO: Implémenter une vérification locale basée sur le cache

      debugPrint('AdminService: Local admin check for user: $userId');
      return false; // Par défaut, retourne false
    } catch (e) {
      debugPrint('AdminService: Error in local admin check: $e');
      return false;
    }
  }

  // Créer ou mettre à jour les custom claims d'un utilisateur
  static Future<bool> setAdminRole(String userId, bool isAdmin) async {
    try {
      if (!_isInitialized) {
        debugPrint('AdminService: Cannot set admin role - service not initialized');
        return false;
      }

      // Cette fonction nécessite les permissions d'admin pour modifier les custom claims
      // Dans un vrai projet, cette opération devrait être effectuée via Firebase Admin SDK ou Cloud Functions

      debugPrint('AdminService: WARNING - setAdminRole not implemented with client-side Firebase SDK');
      debugPrint('AdminService: Admin role should be set via Firebase Admin SDK or Cloud Functions');

      return false;
    } catch (e) {
      debugPrint('AdminService: Error setting admin role: $e');
      return false;
    }
  }

  // Créer un admin dans la base de données
  static Future<bool> createAdmin({
    required String email,
    required String name,
    required String password,
    required String phone,
  }) async {
    try {
      if (!_isInitialized) {
        debugPrint('AdminService: Cannot create admin - service not initialized');
        return false;
      }

      debugPrint('AdminService: Creating admin user for email: $email');

      // TODO: Implémenter la création d'utilisateur admin
      // Cette fonction devrait:
      // 1. Créer l'utilisateur Firebase Auth
      // 2. Créer le document utilisateur avec role: 'admin'
      // 3. Définir les custom claims admin

      debugPrint('AdminService: Admin creation not implemented');
      return false;
    } catch (e) {
      debugPrint('AdminService: Error creating admin: $e');
      return false;
    }
  }

  // Obtenir la liste de tous les admins
  static Future<List<Map<String, dynamic>>> getAdminList() async {
    try {
      if (!_isInitialized) {
        debugPrint('AdminService: Cannot get admin list - service not initialized');
        return [];
      }

      debugPrint('AdminService: Getting admin list...');

      final snapshot = await FirebaseService.usersCollection
          .where('role', isEqualTo: 'admin')
          .get();

      final adminList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      debugPrint('AdminService: Found ${adminList.length} admins');
      return adminList;
    } catch (e) {
      debugPrint('AdminService: Error getting admin list: $e');
      return [];
    }
  }

  // Vérifier si l'utilisateur a accès administrateur
  static Future<bool> hasAdminAccess() async {
    return await isAdmin();
  }
}