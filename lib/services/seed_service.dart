import 'package:flutter/foundation.dart';
import 'firebase_service.dart';
import '../data/agent_seed_data.dart';

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

      // Vérifier si des agents existent déjà
      final agentsSnapshot = await FirebaseService.agentsCollection.get();
      final hasAgents = agentsSnapshot.docs.isNotEmpty;

      debugPrint('SeedService: Agents existants: $hasAgents (${agentsSnapshot.docs.length})');
      return hasAgents;
    } catch (e) {
      debugPrint('SeedService: Erreur lors de la vérification des données: $e');
      return false;
    }
  }

  // Insérer les données seed des agents
  static Future<bool> seedAgents() async {
    if (_isSeeding) {
      debugPrint('SeedService: Seed déjà en cours...');
      return false;
    }

    if (!FirebaseService.isInitialized) {
      debugPrint('SeedService: Firebase non initialisé');
      return false;
    }

    _isSeeding = true;
    debugPrint('=== DÉBUT SEED AGENTS ===');

    try {
      final agents = AgentSeedData.getAgents();
      debugPrint('SeedService: Insertion de ${agents.length} agents...');

      int successCount = 0;
      int errorCount = 0;

      for (final agentData in agents) {
        try {
          await FirebaseService.insertData(
            FirebaseService.agentsCollection,
            agentData,
          );
          successCount++;
          debugPrint('SeedService: Agent ${agentData['name']} créé avec succès');
        } catch (e) {
          errorCount++;
          debugPrint('SeedService: Erreur création agent ${agentData['name']}: $e');
        }
      }

      debugPrint('=== FIN SEED AGENTS ===');
      debugPrint('SeedService: Succès: $successCount, Erreurs: $errorCount');

      _isSeeding = false;
      return successCount > 0;
    } catch (e) {
      debugPrint('SeedService: Erreur globale lors du seed: $e');
      _isSeeding = false;
      return false;
    }
  }

  // Insérer les profils détaillés des agents
  static Future<bool> seedAgentProfiles() async {
    if (!FirebaseService.isInitialized) {
      debugPrint('SeedService: Firebase non initialisé pour les profils');
      return false;
    }

    debugPrint('=== DÉBUT SEED PROFILS AGENTS ===');

    try {
      final profiles = AgentSeedData.getAgentProfiles();
      debugPrint('SeedService: Insertion de ${profiles.length} profils agents...');

      int successCount = 0;
      int errorCount = 0;

      for (final profileData in profiles) {
        try {
          // Créer le document dans la collection agent_profiles
          await FirebaseService.insertData(
            FirebaseService.agentProfilesCollection,
            profileData,
          );
          successCount++;
          debugPrint('SeedService: Profil agent ${profileData['user_id']} créé avec succès');
        } catch (e) {
          errorCount++;
          debugPrint('SeedService: Erreur création profil ${profileData['user_id']}: $e');
        }
      }

      debugPrint('=== FIN SEED PROFILS AGENTS ===');
      debugPrint('SeedService: Profils - Succès: $successCount, Erreurs: $errorCount');

      return successCount > 0;
    } catch (e) {
      debugPrint('SeedService: Erreur globale lors du seed des profils: $e');
      return false;
    }
  }

  // Insérer toutes les données seed
  static Future<bool> seedAll() async {
    debugPrint('=== DÉBUT SEED COMPLET ===');

    try {
      // Seed des agents de base
      final agentsSuccess = await seedAgents();

      // Seed des profils détaillés
      final profilesSuccess = await seedAgentProfiles();

      debugPrint('=== FIN SEED COMPLET ===');
      debugPrint('SeedService: Agents: ${agentsSuccess ? '✓' : '✗'}');
      debugPrint('SeedService: Profils: ${profilesSuccess ? '✓' : '✗'}');

      return agentsSuccess && profilesSuccess;
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
      // Supprimer tous les agents
      final agentsSnapshot = await FirebaseService.agentsCollection.get();
      int deletedAgents = 0;

      for (final doc in agentsSnapshot.docs) {
        try {
          await doc.reference.delete();
          deletedAgents++;
        } catch (e) {
          debugPrint('SeedService: Erreur suppression agent ${doc.id}: $e');
        }
      }

      // Supprimer tous les profils agents
      final profilesSnapshot = await FirebaseService.agentProfilesCollection.get();
      int deletedProfiles = 0;

      for (final doc in profilesSnapshot.docs) {
        try {
          await doc.reference.delete();
          deletedProfiles++;
        } catch (e) {
          debugPrint('SeedService: Erreur suppression profil ${doc.id}: $e');
        }
      }

      debugPrint('=== FIN NETTOYAGE SEED ===');
      debugPrint('SeedService: Agents supprimés: $deletedAgents');
      debugPrint('SeedService: Profils supprimés: $deletedProfiles');

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
      return {'agents': 0, 'profiles': 0};
    }

    try {
      debugPrint('SeedService: Récupération des statistiques...');

      // Utiliser get() au lieu de count() pour éviter les permissions d'agrégation
      final agentsSnapshot = await FirebaseService.agentsCollection.get();
      final profilesSnapshot = await FirebaseService.agentProfilesCollection.get();

      final stats = {
        'agents': agentsSnapshot.docs.length,
        'profiles': profilesSnapshot.docs.length,
      };

      debugPrint('SeedService: Statistiques récupérées: $stats');
      return stats;
    } catch (e) {
      debugPrint('SeedService: Erreur lors de la récupération des statistiques: $e');
      return {'agents': 0, 'profiles': 0};
    }
  }
}