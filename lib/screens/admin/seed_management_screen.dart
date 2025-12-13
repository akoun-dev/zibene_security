import 'package:flutter/material.dart';
import '../../services/seed_service.dart';
import '../../utils/theme.dart';

class SeedManagementScreen extends StatefulWidget {
  const SeedManagementScreen({super.key});

  @override
  State<SeedManagementScreen> createState() => _SeedManagementScreenState();
}

class _SeedManagementScreenState extends State<SeedManagementScreen> {
  bool _isLoading = false;
  bool _hasData = false;
  Map<String, int> _stats = {'agents': 0, 'profiles': 0};
  String? _operationResult;

  @override
  void initState() {
    super.initState();
    _checkDataStatus();
  }

  Future<void> _checkDataStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasData = await SeedService.hasSeedData();
      final stats = await SeedService.getSeedStats();

      setState(() {
        _hasData = hasData;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _operationResult = 'Erreur: $e';
      });
    }
  }

  Future<void> _seedAgents() async {
    setState(() {
      _isLoading = true;
      _operationResult = null;
    });

    try {
      final success = await SeedService.seedTestUsers();

      if (success) {
        _operationResult = 'Utilisateurs de test créés avec succès !';
        await _checkDataStatus(); // Rafraîchir les stats
      } else {
        _operationResult = 'Erreur lors de la création des utilisateurs de test';
      }
    } catch (e) {
      _operationResult = 'Erreur: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _seedProfiles() async {
    setState(() {
      _isLoading = true;
      _operationResult = null;
    });

    try {
      final success = await SeedService.seedTestBookings();

      if (success) {
        _operationResult = 'Réservations de test créées avec succès !';
        await _checkDataStatus(); // Rafraîchir les stats
      } else {
        _operationResult = 'Erreur lors de la création des réservations de test';
      }
    } catch (e) {
      _operationResult = 'Erreur: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _seedAll() async {
    setState(() {
      _isLoading = true;
      _operationResult = null;
    });

    try {
      final success = await SeedService.seedAll();

      if (success) {
        _operationResult = 'Toutes les données seed créées avec succès !';
        await _checkDataStatus(); // Rafraîchir les stats
      } else {
        _operationResult = 'Erreur lors de la création des données seed';
      }
    } catch (e) {
      _operationResult = 'Erreur: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearData() async {
    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚠️ Confirmation de suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer TOUTES les données seed ?\n\n'
            'Cette action est IRRÉVERSIBLE et supprimera :\n'
            '• Tous les agents\n'
            '• Tous les profils agents\n\n'
            'Cette action ne peut pas être annulée.',
            style: TextStyle(color: Colors.white70),
          ),
          backgroundColor: const Color(0xFF2A2A2A),
          titleTextStyle: const TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer tout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _operationResult = null;
    });

    try {
      final success = await SeedService.clearSeedData();

      if (success) {
        _operationResult = 'Données seed supprimées avec succès !';
        await _checkDataStatus(); // Rafraîchir les stats
      } else {
        _operationResult = 'Erreur lors de la suppression des données';
      }
    } catch (e) {
      _operationResult = 'Erreur: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetData() async {
    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🔄 Confirmation de réinitialisation'),
          content: const Text(
            'Êtes-vous sûr de vouloir RÉINITIALISER toutes les données seed ?\n\n'
            'Cette action va :\n'
            '• Supprimer toutes les données existantes\n'
            '• Recréer les données seed fraîches\n\n'
            'Cette action ne peut pas être annulée.',
            style: TextStyle(color: Colors.white70),
          ),
          backgroundColor: const Color(0xFF2A2A2A),
          titleTextStyle: const TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _operationResult = null;
    });

    try {
      final success = await SeedService.resetSeedData();

      if (success) {
        _operationResult = 'Données seed réinitialisées avec succès !';
        await _checkDataStatus(); // Rafraîchir les stats
      } else {
        _operationResult = 'Erreur lors de la réinitialisation des données';
      }
    } catch (e) {
      _operationResult = 'Erreur: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des données Seed'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section État
            _buildStatusSection(),

            const SizedBox(height: 24),

            // Section Actions
            _buildActionsSection(),

            const SizedBox(height: 24),

            // Section Résultat
            if (_operationResult != null) ...[
              _buildResultSection(),
              const SizedBox(height: 24),
            ],

            // Section Danger
            _buildDangerSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasData ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _hasData ? Icons.check_circle : Icons.info,
                color: _hasData ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'État des données Seed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Vérification en cours...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            )
          else ...[
            Text(
              _hasData ? '✅ Données seed présentes' : '❌ Aucune donnée seed trouvée',
              style: TextStyle(
                color: _hasData ? Colors.green : Colors.orange,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agents: ${_stats['agents']} | Profils: ${_stats['profiles']}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _seedAgents,
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Créer agents'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: Colors.black,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _seedProfiles,
              icon: const Icon(Icons.badge, size: 18),
              label: const Text('Créer profils'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: Colors.black,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _seedAll,
              icon: const Icon(Icons.cloud_upload, size: 18),
              label: const Text('Tout créer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    final isSuccess = _operationResult!.contains('succès');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _operationResult!,
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.red,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _operationResult = null),
            icon: const Icon(Icons.close, size: 18),
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚠️ Actions dangereuses',
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: const Text(
            'Les actions suivantes sont IRRÉVERSIBLES et affecteront toutes les données seed.',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _clearData,
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text('Supprimer tout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _resetData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réinitialiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}