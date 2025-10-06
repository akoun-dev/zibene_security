import 'package:flutter/material.dart';
import '../../services/auth_persistence_manager.dart';
import '../../utils/theme.dart';

class PersistenceSettingsScreen extends StatefulWidget {
  const PersistenceSettingsScreen({super.key});

  @override
  State<PersistenceSettingsScreen> createState() => _PersistenceSettingsScreenState();
}

class _PersistenceSettingsScreenState extends State<PersistenceSettingsScreen> {
  final AuthPersistenceManager _persistenceManager = AuthPersistenceManager();
  TypePersistance _typePersistanceActuel = TypePersistance.local;
  bool _estEnChargement = false;

  @override
  void initState() {
    super.initState();
    _chargerTypePersistance();
  }

  Future<void> _chargerTypePersistance() async {
    setState(() {
      _estEnChargement = true;
    });

    try {
      final type = await _persistenceManager.obtenirTypePersistance();
      setState(() {
        _typePersistanceActuel = type;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement du type de persistance: $e');
    } finally {
      setState(() {
        _estEnChargement = false;
      });
    }
  }

  Future<void> _definirTypePersistance(TypePersistance type) async {
    setState(() {
      _estEnChargement = true;
    });

    try {
      final succes = await _persistenceManager.definirTypePersistance(type);
      if (succes) {
        setState(() {
          _typePersistanceActuel = type;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Type de persistance mis à jour: ${_getTypePersistanceNom(type)}'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Échec de la mise à jour du type de persistance'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la définition du type de persistance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      setState(() {
        _estEnChargement = false;
      });
    }
  }

  String _getTypePersistanceNom(TypePersistance type) {
    switch (type) {
      case TypePersistance.local:
        return 'Locale (persistante)';
      case TypePersistance.session:
        return 'Session (onglet actuel)';
      case TypePersistance.none:
        return 'Aucune (mémoire)';
    }
  }

  String _getTypePersistanceDescription(TypePersistance type) {
    switch (type) {
      case TypePersistance.local:
        return 'La session persiste même après la fermeture de l\'application. Idéal pour une utilisation personnelle.';
      case TypePersistance.session:
        return 'La session persiste uniquement dans l\'onglet actuel. Parfait pour les appareils partagés.';
      case TypePersistance.none:
        return 'Aucune persistance. Vous devrez vous reconnecter à chaque ouverture. Maximum de sécurité.';
    }
  }

  IconData _getTypePersistanceIcon(TypePersistance type) {
    switch (type) {
      case TypePersistance.local:
        return Icons.storage;
      case TypePersistance.session:
        return Icons.tab;
      case TypePersistance.none:
        return Icons.memory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de persistance'),
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.white,
      ),
      body: _estEnChargement
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Choisissez comment votre session d\'authentification doit persister:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Options de persistance
                ...TypePersistance.values.map((type) => _buildPersistenceOption(type)),

                const SizedBox(height: 32),

                // Informations supplémentaires
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations importantes:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          icon: Icons.security,
                          title: 'Sécurité',
                          description: 'Choisissez "Aucune" pour une sécurité maximale sur les appareils publics.',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoItem(
                          icon: Icons.devices,
                          title: 'Appareils partagés',
                          description: 'Utilisez "Session" pour les ordinateurs ou tablettes partagés.',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoItem(
                          icon: Icons.person,
                          title: 'Usage personnel',
                          description: 'Utilisez "Locale" pour une expérience utilisateur optimale.',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton de test
                OutlinedButton(
                  onPressed: () async {
                    final infos = await _persistenceManager.obtenirInformationsPersistance();
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Informations de persistance'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildInfoDialog('Type de persistance', infos['type_persistance'] ?? 'Inconnu'),
                                const SizedBox(height: 8),
                                _buildInfoDialog('Session valide', infos['session_valide'] ? 'Oui' : 'Non'),
                                const SizedBox(height: 8),
                                _buildInfoDialog('Utilisateur connecté', infos['utilisateur_connecte'] ? 'Oui' : 'Non'),
                                const SizedBox(height: 8),
                                if (infos['email_utilisateur'] != null)
                                  _buildInfoDialog('Email utilisateur', infos['email_utilisateur']),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Fermer'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Vérifier l\'état de la persistance'),
                ),
              ],
            ),
    );
  }

  Widget _buildPersistenceOption(TypePersistance type) {
    final isSelected = _typePersistanceActuel == type;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _definirTypePersistance(type),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.yellow.withValues(alpha: 0.1) : AppColors.mediumGray.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getTypePersistanceIcon(type),
                  color: isSelected ? AppColors.yellow : AppColors.mediumGray,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypePersistanceNom(type),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.yellow : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTypePersistanceDescription(type),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? AppColors.yellow : AppColors.mediumGray,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.yellow,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoDialog(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}