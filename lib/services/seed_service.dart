import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class SeedService {
  static bool _isSeeding = false;

  // Vérifier si les données seed existent déjà
  static Future<bool> hasSeedData() async {
    try {
      if (!FirebaseService.isInitialized) {
        debugPrint('SeedService: Firebase non initialisé');
        return false;
      }

      debugPrint('SeedService: Vérification des données existantes...');

      // Vérifier si des utilisateurs existent déjà
      final usersSnapshot = await FirebaseService.usersCollection.get();
      final hasUsers = usersSnapshot.docs.isNotEmpty;

      debugPrint('SeedService: Utilisateurs existants: $hasUsers (${usersSnapshot.docs.length})');
      return hasUsers;
    } catch (e) {
      debugPrint('SeedService: Erreur lors de la vérification des données: $e');
      return false;
    }
  }

  // Insérer les données seed des utilisateurs de test
  static Future<bool> seedTestUsers() async {
    if (_isSeeding) {
      debugPrint('SeedService: Seed déjà en cours...');
      return false;
    }

    if (!FirebaseService.isInitialized) {
      debugPrint('SeedService: Firebase non initialisé');
      return false;
    }

    _isSeeding = true;
    debugPrint('=== DÉBUT SEED UTILISATEURS ===');

    try {
      final testUsers = [
        {
          'id': 'test_client_1',
          'full_name': 'John Doe',
          'email': 'john.doe@test.com',
          'phone': '+1234567890',
          'role': 'client',
          'is_active': true,
          'is_approved': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'test_admin_1',
          'full_name': 'Admin User',
          'email': 'admin@test.com',
          'phone': '+0987654321',
          'role': 'admin',
          'is_active': true,
          'is_approved': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      debugPrint('SeedService: Insertion de ${testUsers.length} utilisateurs...');

      int successCount = 0;
      int errorCount = 0;

      for (final userData in testUsers) {
        try {
          await FirebaseService.insertData(
            FirebaseService.usersCollection,
            userData,
          );
          successCount++;
          debugPrint('SeedService: Utilisateur ${userData['full_name']} créé avec succès');
        } catch (e) {
          errorCount++;
          debugPrint('SeedService: Erreur création utilisateur ${userData['full_name']}: $e');
        }
      }

      debugPrint('=== FIN SEED UTILISATEURS ===');
      debugPrint('SeedService: Succès: $successCount, Erreurs: $errorCount');

      _isSeeding = false;
      return successCount > 0;
    } catch (e) {
      debugPrint('SeedService: Erreur globale lors du seed: $e');
      _isSeeding = false;
      return false;
    }
  }

  // Insérer des données de test pour les réservations
  static Future<bool> seedTestBookings() async {
    if (!FirebaseService.isInitialized) {
      debugPrint('SeedService: Firebase non initialisé pour les réservations');
      return false;
    }

    debugPrint('=== DÉBUT SEED RÉSERVATIONS ===');

    try {
      final testBookings = [
        {
          'id': 'booking_test_1',
          'client_id': 'test_client_1',
          'start_time': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(const Duration(days: 1, hours: 4)).toIso8601String(),
          'location': '123 Test Street',
          'service_type': 'Protection Test',
          'cost': 250.0,
          'status': 'pending',
          'notes': 'Test booking',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'booking_test_2',
          'client_id': 'test_client_1',
          'start_time': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
          'end_time': DateTime.now().add(const Duration(days: 2, hours: 6)).toIso8601String(),
          'location': '456 Test Avenue',
          'service_type': 'Security Event',
          'cost': 400.0,
          'status': 'confirmed',
          'notes': 'Event test booking',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      debugPrint('SeedService: Insertion de ${testBookings.length} réservations...');

      int successCount = 0;
      int errorCount = 0;

      for (final bookingData in testBookings) {
        try {
          await FirebaseService.insertData(
            FirebaseService.bookingsCollection,
            bookingData,
          );
          successCount++;
          debugPrint('SeedService: Réservation ${bookingData['id']} créée avec succès');
        } catch (e) {
          errorCount++;
          debugPrint('SeedService: Erreur création réservation ${bookingData['id']}: $e');
        }
      }

      debugPrint('=== FIN SEED RÉSERVATIONS ===');
      debugPrint('SeedService: Réservations - Succès: $successCount, Erreurs: $errorCount');

      return successCount > 0;
    } catch (e) {
      debugPrint('SeedService: Erreur globale lors du seed des réservations: $e');
      return false;
    }
  }

  // Insérer toutes les données seed
  static Future<bool> seedAll() async {
    debugPrint('=== DÉBUT SEED COMPLET ===');

    try {
      // Seed des utilisateurs de test
      final usersSuccess = await seedTestUsers();

      // Seed des réservations de test
      final bookingsSuccess = await seedTestBookings();

      debugPrint('=== FIN SEED COMPLET ===');
      debugPrint('SeedService: Utilisateurs: ${usersSuccess ? '✓' : '✗'}');
      debugPrint('SeedService: Réservations: ${bookingsSuccess ? '✓' : '✗'}');

      return usersSuccess && bookingsSuccess;
    } catch (e) {
      debugPrint('SeedService: Erreur lors du seed complet: $e');
      return false;
    }
  }

  // Vider toutes les données seed (attention: suppression permanente)
  static Future<bool> clearSeedData() async {
    if (!FirebaseService.isInitialized) {
      debugPrint('SeedService: Firebase non initialisé');
      return false;
    }

    debugPrint('=== DÉBUT NETTOYAGE SEED ===');

    try {
      // Supprimer tous les utilisateurs de test
      final usersSnapshot = await FirebaseService.usersCollection.get();
      int deletedUsers = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['id']?.toString().startsWith('test_') == true) {
          try {
            await doc.reference.delete();
            deletedUsers++;
          } catch (e) {
            debugPrint('SeedService: Erreur suppression utilisateur ${doc.id}: $e');
          }
        }
      }

      // Supprimer toutes les réservations de test
      final bookingsSnapshot = await FirebaseService.bookingsCollection.get();
      int deletedBookings = 0;

      for (final doc in bookingsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['id']?.toString().startsWith('booking_test_') == true) {
          try {
            await doc.reference.delete();
            deletedBookings++;
          } catch (e) {
            debugPrint('SeedService: Erreur suppression réservation ${doc.id}: $e');
          }
        }
      }

      debugPrint('=== FIN NETTOYAGE SEED ===');
      debugPrint('SeedService: Utilisateurs supprimés: $deletedUsers');
      debugPrint('SeedService: Réservations supprimées: $deletedBookings');

      return true;
    } catch (e) {
      debugPrint('SeedService: Erreur lors du nettoyage: $e');
      return false;
    }
  }

  // Réinitialiser complètement (vider + recréer)
  static Future<bool> resetSeedData() async {
    debugPrint('=== DÉBUT RÉINITIALISATION SEED ===');

    final clearSuccess = await clearSeedData();
    if (!clearSuccess) {
      debugPrint('SeedService: Échec du nettoyage');
      return false;
    }

    // Attendre un peu pour que les suppressions se propagent
    await Future.delayed(const Duration(seconds: 2));

    final seedSuccess = await seedAll();

    debugPrint('=== FIN RÉINITIALISATION SEED ===');
    debugPrint('SeedService: Réinitialisation ${seedSuccess ? 'réussie' : 'échouée'}');

    return seedSuccess;
  }

  // Obtenir des statistiques sur les données seed
  static Future<Map<String, int>> getSeedStats() async {
    if (!FirebaseService.isInitialized) {
      return {'users': 0, 'bookings': 0};
    }

    try {
      debugPrint('SeedService: Récupération des statistiques...');

      // Utiliser get() au lieu de count() pour éviter les permissions d'agrégation
      final usersSnapshot = await FirebaseService.usersCollection.get();
      final bookingsSnapshot = await FirebaseService.bookingsCollection.get();

      final testUsers = usersSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['id']?.toString().startsWith('test_') == true;
      }).length;

      final testBookings = bookingsSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['id']?.toString().startsWith('booking_test_') == true;
      }).length;

      final stats = {
        'users': testUsers,
        'bookings': testBookings,
      };

      debugPrint('SeedService: Statistiques récupérées: $stats');
      return stats;
    } catch (e) {
      debugPrint('SeedService: Erreur lors de la récupération des statistiques: $e');
      return {'users': 0, 'bookings': 0};
    }
  }
}