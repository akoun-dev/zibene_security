import 'package:flutter/foundation.dart';
import '../services/seed_service.dart';

class SeedRunner {
  static Future<void> runQuickSeed() async {
    debugPrint('🌱 LANCEMENT RAPIDE DES DONNÉES SEED...');

    try {
      // Vérifier l'état actuel
      final hasData = await SeedService.hasSeedData();
      final stats = await SeedService.getSeedStats();

      debugPrint('État actuel: hasData=$hasData, stats=$stats');

      if (hasData) {
        debugPrint('⚠️ Les données seed existent déjà. Utilisez resetSeedData() pour les réinitialiser.');
        return;
      }

      // Créer les données
      debugPrint('📊 Création des données seed...');
      final success = await SeedService.seedAll();

      if (success) {
        debugPrint('✅ Données seed créées avec succès !');

        // Afficher les nouvelles statistiques
        final newStats = await SeedService.getSeedStats();
        debugPrint('📈 Nouvelles statistiques: $newStats');
      } else {
        debugPrint('❌ Erreur lors de la création des données seed');
      }

    } catch (e) {
      debugPrint('💥 Erreur lors du seed rapide: $e');
    }
  }

  static Future<void> runFullReset() async {
    debugPrint('🔄 RÉINITIALISATION COMPLÈTE DES DONNÉES SEED...');

    try {
      final success = await SeedService.resetSeedData();

      if (success) {
        debugPrint('✅ Réinitialisation réussie !');

        final stats = await SeedService.getSeedStats();
        debugPrint('📈 Statistiques après réinitialisation: $stats');
      } else {
        debugPrint('❌ Erreur lors de la réinitialisation');
      }

    } catch (e) {
      debugPrint('💥 Erreur lors de la réinitialisation: $e');
    }
  }

  static Future<void> runStatsCheck() async {
    debugPrint('📊 VÉRIFICATION DES STATISTIQUES...');

    try {
      final hasData = await SeedService.hasSeedData();
      final stats = await SeedService.getSeedStats();

      debugPrint('📈 Données seed présentes: $hasData');
      debugPrint('📊 Agents: ${stats['agents']}');
      debugPrint('📋 Profils: ${stats['profiles']}');

    } catch (e) {
      debugPrint('💥 Erreur lors de la vérification: $e');
    }
  }
}